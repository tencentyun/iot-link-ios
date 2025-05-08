//
//  TIoTCoreXP2PBridge.m
//  TIoTLinkKitDemo
//
//

#import "TIoTCoreXP2PBridge.h"
#import "TIoTCoreLogger.h"
#include <string.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

NSNotificationName const TIoTCoreXP2PBridgeNotificationDisconnect   = @"xp2disconnect"; //p2p通道断开
NSNotificationName const TIoTCoreXP2PBridgeNotificationReady        = @"xp2preconnect"; //app本地已ready，表示探测完成，可以发起请求了
NSNotificationName const TIoTCoreXP2PBridgeNotificationDetectError  = @"xp2detecterror"; //探测失败，网络不正常表示探测完成，可以发起请求了
NSNotificationName const TIoTCoreXP2PBridgeNotificationDeviceMsg    = @"XP2PTypeDeviceMsgArrived"; //收到设备端的请求数据
NSNotificationName const TIoTCoreXP2PBridgeNotificationStreamEnd    = @"XP2PTypeStreamEnd"; // 设备主动停止推流，或者由于达到设备最大连接数，拒绝推流

FILE *p2pOutLogFile;
//NSFileHandle *fileHandle;
static BOOL p2p_log_enabled = NO;
static BOOL ops_report_enabled = YES;
@interface TIoTP2PAPPConfig ()
@property (nonatomic, strong)NSString *userid;
@property (nonatomic, strong)NSString *pro_id;
@property (nonatomic, strong)NSString *dev_name;
@end
@implementation TIoTP2PAPPConfig
@end


@interface TIoTCoreXP2PBridge ()<TIoTAVCaptionFLVDelegate>
@property (nonatomic, strong) NSString *talk_dev_name;
@property (nonatomic, strong) TIoTP2PAPPConfig *appConfig;
@property (nonatomic, assign) BOOL isSending;
@property (nonatomic, strong) AVCaptureSessionPreset resolution;
@property (nonatomic, strong) NSTimer *getBufTimer;
@property (nonatomic, strong) NSMutableDictionary *uniReqStartTime;
@property (nonatomic, strong) TIoTCoreLogger *logger;
@property (nonatomic, assign) CFTimeInterval start_voice_time;
- (void)cancelTimer;
- (void)doTick:(data_report_t)data_buf;
@end

const char* XP2PMsgHandle(const char *idd, XP2PType type, const char* msg) {
    
    BOOL logEnable = [TIoTCoreXP2PBridge sharedInstance].logEnable;
    if (logEnable) {
        printf("XP2Plog: %s", msg);
    }
    
    if (type == XP2PTypeLog) {
        if (p2p_log_enabled) {
//            fwrite(msg, 1, strlen(msg)>300?300:strlen(msg), p2pOutLogFile);
            [[TIoTCoreXP2PBridge sharedInstance].logger addLog:[NSString stringWithCString:msg encoding:NSASCIIStringEncoding]];
        }
        return nullptr;
    }else if (type == XP2PTypeSaveFileOn) {
        
        BOOL isWriteFile = [TIoTCoreXP2PBridge sharedInstance].writeFile;
        return (isWriteFile?"1":"0");
    }else if (type == XP2PTypeSaveFileUrl) {
        
        NSString *fileName = @"video.data";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = paths.firstObject;
        NSString *saveFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
        return saveFilePath.UTF8String;
    }
    
    @autoreleasepool {
        
        NSString *DeviceName = [NSString stringWithCString:idd encoding:[NSString defaultCStringEncoding]]?:@"";
        
        if (type == XP2PTypeDisconnect) {
            [[TIoTCoreXP2PBridge sharedInstance] cancelTimer];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationDisconnect object:nil userInfo:@{@"id": DeviceName}];
            });
        }else if (type == XP2PTypeDetectError) {
            [[TIoTCoreXP2PBridge sharedInstance] cancelTimer];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationDetectError object:nil userInfo:@{@"id": DeviceName}];
            });
        }else if (type == XP2PTypeDetectReady) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationReady object:nil userInfo:@{@"id": DeviceName}];
            });
        }
        else if (type == XP2PTypeDeviceMsgArrived) {
            // 设备端向App发消息,
            //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //            [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationDeviceMsg object:nil userInfo:@{@"id": DeviceName, @"msg": message}];
            //        });
        }
        else if (type == XP2PTypeCmdNOReturn) {
            //设备自定义信令未回复内容
            printf("设备自定义信令未回复内容: %s", msg);
        }
        else if (type == XP2PTypeStreamRefush) {
            printf("校验失败,info撞库防止串流: %s", msg);
        }
        else if (type == XP2PTypeStreamEnd) {
            // 设备主动停止推流，或者由于达到设备最大连接数，拒绝推流
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationStreamEnd object:nil userInfo:@{@"id": DeviceName}];
            });
        }
        else if (type == XP2PTypeDownloadEnd) {
            // 设备主动停止推流，或者由于达到设备最大连接数，拒绝推流
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationStreamEnd object:nil userInfo:@{@"id": DeviceName}];
            });
        }
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            id<TIoTCoreXP2PBridgeDelegate> delegate = [TIoTCoreXP2PBridge sharedInstance].delegate;
            if ([delegate respondsToSelector:@selector(reviceEventMsgWithID:eventType:msg:)]) {
                [delegate reviceEventMsgWithID:DeviceName eventType:type msg:msg];
            }
        });
    }
    return nullptr;
}

void XP2PDataMsgHandle(const char *idd, uint8_t* recv_buf, size_t recv_len) {
    NSString *DeviceName = [NSString stringWithCString:idd encoding:[NSString defaultCStringEncoding]]?:@"";
    id<TIoTCoreXP2PBridgeDelegate> delegate = [TIoTCoreXP2PBridge sharedInstance].delegate;
    if ([delegate respondsToSelector:@selector(getVideoPacketWithID:data:len:)]) {
        [delegate getVideoPacketWithID:DeviceName data:recv_buf len:recv_len];
    }
}

char* XP2PReviceDeviceCustomMsgHandle(const char *idd, uint8_t* recv_buf, size_t recv_len) {
    char *msg = (char *)recv_buf;
    printf("device feedback ==> %s\n",msg);

    NSString *response = @"{\"status\":0}"; //默认返回值
    
    id<TIoTCoreXP2PBridgeDelegate> delegate = [TIoTCoreXP2PBridge sharedInstance].delegate;
    if ([delegate respondsToSelector:@selector(reviceDeviceMsgWithID:data:)]) {
        
        NSString *DeviceName = [NSString stringWithCString:idd encoding:[NSString defaultCStringEncoding]]?:@"";
        NSData *DeviceData = [NSData dataWithBytes:recv_buf length:recv_len];
        NSString *res = [delegate reviceDeviceMsgWithID:DeviceName data:DeviceData];
        if (res) {
            response = res;
        }
    }
    
    NSUInteger length = strlen(response.UTF8String);
    char *response_msg = (char *)malloc(length + 1);
    strncpy(response_msg, response.UTF8String, length);
    response_msg[length] = '\0';
    
    return response_msg;
}

void XP2PReciveLogReportDataHandle(const char *idd, data_report_t data_buf) {
//    NSString *DeviceName = [NSString stringWithCString:idd encoding:[NSString defaultCStringEncoding]]?:@"";
    [[TIoTCoreXP2PBridge sharedInstance] doTick:data_buf];
}


typedef char *(*device_data_recv_handle_t)(const char *id, uint8_t *recv_buf, size_t recv_len);

#define MAX_AVG_LENGTH 10
typedef struct {
    int32_t buf[MAX_AVG_LENGTH];
    int32_t len;
    int32_t index;
} avg_context;

static int32_t avg_max_min(avg_context *avg_ctx, int32_t val)
{
    int32_t sum = 0;
    int32_t max = INT32_MIN;
    int32_t min = INT32_MAX;
    int32_t i = 0;

    avg_ctx->buf[avg_ctx->index] = val;
    avg_ctx->index = (avg_ctx->index + 1) % avg_ctx->len;

    for (i = 0; i < avg_ctx->len; i++)
    {
        sum += avg_ctx->buf[i];
        if (avg_ctx->buf[i] > max) {
            max = avg_ctx->buf[i];
        }
        if (avg_ctx->buf[i] < min) {
            min = avg_ctx->buf[i];
        }
    }
    sum = sum - max - min;

    return sum / (avg_ctx->len - 2);
}



@implementation TIoTCoreXP2PBridge {
    
    TIoTAVCaptionFLV *systemAvCapture;

    dispatch_source_t timer;
    void *_serverHandle;
    
    avg_context _p2p_wl_avg_ctx;
}

+ (instancetype)sharedInstance {
  static TIoTCoreXP2PBridge *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[TIoTCoreXP2PBridge alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init {
    self =  [super init];
    if (self) {
        //默认关log开关
        _logEnable = NO;
        _start_voice_time = 0;
        
        NSString *logFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TIoTXP2P.log"];
        [[NSFileManager defaultManager] removeItemAtPath:logFile error:nil];
        [[NSFileManager defaultManager] createFileAtPath:logFile contents:nil attributes:nil];
        p2pOutLogFile = fopen(logFile.UTF8String, "wb");
        
        _uniReqStartTime = [NSMutableDictionary dictionary];
        
        [self getAppLogConfig];
    }
    return self;
}

- (const char *)dicConvertString:(NSDictionary *)dic {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&error];
    NSString *jsonString = @"";
    if (!error) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString.UTF8String;
}

// 判断版本号是否小于 2.4.49
BOOL isVersionLessThanTarget(NSString *version, NSString *targetVersion) {
    // 将版本号拆分为数组
    NSArray *versionComponents = [version componentsSeparatedByString:@"."];
    NSArray *targetComponents = [targetVersion componentsSeparatedByString:@"."];
    
    // 逐个比较版本号
    for (NSInteger i = 0; i < MIN(versionComponents.count, targetComponents.count); i++) {
        NSInteger versionPart = [versionComponents[i] integerValue];
        NSInteger targetPart = [targetComponents[i] integerValue];
        
        if (versionPart < targetPart) {
            return YES; // 当前部分小于目标部分
        } else if (versionPart > targetPart) {
            return NO; // 当前部分大于目标部分
        }
    }
    
    // 如果前面的部分都相等，就返回不小于（NO表示大于等于）
    return NO;
}

// 提取 % 后面的子字符串并判断版本
BOOL checkVersionAfterPercent(NSString *input) {
    // 查找 % 的位置
    NSRange percentRange = [input rangeOfString:@"%"];
    if (percentRange.location == NSNotFound) {
        NSLog(@"未找到 % 符号");
        return NO;
    }
    
    // 提取 % 后面的子字符串
    NSString *versionString = [input substringFromIndex:percentRange.location + 1];
    
    // 判断版本是否小于 2.4.49
    return isVersionLessThanTarget(versionString, @"2.4.49");
}

- (XP2PErrCode)startAppWith:(NSString *)pro_id dev_name:(NSString *)dev_name appconfig:(TIoTP2PAPPConfig *)appconfig {
    appconfig.userid = [self getAppUUID];
    appconfig.pro_id = pro_id;
    appconfig.dev_name = dev_name;
    self.appConfig = appconfig;
    
    if (!appconfig || appconfig.appkey.length < 1 || appconfig.appsecret.length < 1 || appconfig.userid.length < 1) {
        NSLog(@"请输入正确的appconfig");
        return XP2P_ERR_INIT_PRM;
    }
    if (appconfig.xp2pinfo.length < 1) {
        NSLog(@"请输入正确的xp2pInfo");
        return XP2P_ERR_INIT_PRM;
    }
    BOOL result = checkVersionAfterPercent(appconfig.xp2pinfo);
    if (result) {
        appconfig.autoConfigFromDevice = NO;
    }
    
    
    [self appGetUserConfig:appconfig]; //get config
    
    NSString *bundleid = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]?:@"";
    NSString *nsstr_user_id = [self getAppUUID];
    setContentDetail([self dicConvertString:@{@"str_user_id":nsstr_user_id, @"version":@"video-v2.4.30_beta1", @"str_package_name": bundleid}],
                     [self dicConvertString:@{@"punch_cost": @510}],
                     XP2PReciveLogReportDataHandle);
    
    NSString *fileName = @"stun.txt";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths.firstObject;
    NSString *saveFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    setStunServerToXp2p(saveFilePath.UTF8String, 20002);
    //注册回调
    setUserCallbackToXp2p(XP2PDataMsgHandle, XP2PMsgHandle, XP2PReviceDeviceCustomMsgHandle);
    
    //启动logger
    if (self.logger == nil) {
        self.logger = [[TIoTCoreLogger alloc] init];
        self.logger.appuuid = nsstr_user_id;
        self.logger.version = [TIoTCoreXP2PBridge getSDKVersion];
        [self.logger startLogging];
    }
    
    // 配置是否启用双中转
    setCrossStunTurn(false);
    
    //1.配置IOT_P2P SDK
    
    int ret = XP2P_ERR_NONE;
    
    if (appconfig.autoConfigFromDevice) {
        [self appGeDeviceConfig:appconfig]; //get config
        
    }else {
        app_config_t config_ = {
            .server = "",
            .ip = "",
            .port = 20002,
            .type = appconfig.type
        };
        
        if (appconfig.crossStunTurn) {
            setCrossStunTurn(true);
        }

        // 拼接新的参数
        NSString *combinedId = [NSString stringWithFormat:@"%@/%@", pro_id, dev_name];
        ret = startService(combinedId.UTF8String, pro_id.UTF8String, dev_name.UTF8String, config_);
        setDeviceXp2pInfo(combinedId.UTF8String, appconfig.xp2pinfo.UTF8String);
    }
    
    return (XP2PErrCode)ret;
}

NSString *createSortedQueryString(NSMutableDictionary *params) {
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *keyValuePairs = [NSMutableArray array];
    for (NSString *key in sortedKeys) {
        NSString *value = [params objectForKey:key];
        NSString *keyValuePair = [NSString stringWithFormat:@"%@=%@", key, value];
        [keyValuePairs addObject:keyValuePair];
    }
    NSString *queryString = [keyValuePairs componentsJoinedByString:@"&"];
    return queryString;
}
- (NSString *)signMessage:(NSString *)message withSecret:(NSString *)secret {
    @try {
        // Base64 解码
        const char *cKey  = [secret cStringUsingEncoding:NSASCIIStringEncoding];
        const char *cData = [message cStringUsingEncoding:NSASCIIStringEncoding];
        if (cKey == NULL || cData == NULL) {
            return nil;
        }
        //sha1
        unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

        NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

        NSString *hash = [HMAC base64EncodedStringWithOptions:0];//将加密结果进行一次BASE64编码。
        return hash;
    } @catch (NSException *exception) {
        NSLog(@"签名错误：%@", exception);
    }
    return nil;
}

- (void)appGetUserConfig:(TIoTP2PAPPConfig *)appconfig {
    NSMutableDictionary *accessParam = [NSMutableDictionary dictionary];
    [accessParam setValue:@"AppDescribeLogLevel" forKey:@"Action"];
    [accessParam setValue:@([[TIoTCoreXP2PBridge getNowTimeTimestampSec] integerValue]) forKey:@"Timestamp"];
    [accessParam setValue:@(arc4random()) forKey:@"Nonce"];
    [accessParam setValue:appconfig.appkey forKey:@"AppKey"];
    [accessParam setValue:appconfig.userid forKey:@"UserId"];
    [accessParam setValue:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    
    NSString *content = createSortedQueryString(accessParam);
    NSString *signature = [self signMessage:content withSecret:appconfig.appsecret];
    [accessParam setValue:signature forKey:@"Signature"];
    
    
    NSURL *url = [NSURL URLWithString:@"https://iot.cloud.tencent.com/api/exploreropen/appapi"];
    NSMutableURLRequest *reqlog = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [reqlog setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    reqlog.HTTPMethod = @"POST";
    reqlog.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];;
    NSURLSessionDataTask *tasklog = [[NSURLSession sharedSession] dataTaskWithRequest:reqlog completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *jsonerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
//            NSLog(@"log serverapi:content===>%@, param==>%@, data===>%@",content,accessParam,dic);
            [self setAppLogConfig:[[dic objectForKey:@"data"] objectForKey:@"Data"]];
        }
    }];
    [tasklog resume];
}

- (void)appGeDeviceConfig:(TIoTP2PAPPConfig *)appconfig {
    NSMutableDictionary *accessParam = [NSMutableDictionary dictionary];
    [accessParam setValue:@"AppDescribeConfigureDeviceP2P" forKey:@"Action"];
    [accessParam setValue:@([[TIoTCoreXP2PBridge getNowTimeTimestampSec] integerValue]) forKey:@"Timestamp"];
    [accessParam setValue:@(arc4random()) forKey:@"Nonce"];
    [accessParam setValue:appconfig.appkey forKey:@"AppKey"];
    [accessParam setValue:appconfig.pro_id forKey:@"ProductId"];
    [accessParam setValue:appconfig.dev_name forKey:@"DeviceName"];
    [accessParam setValue:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    
    NSString *content = createSortedQueryString(accessParam);
    NSString *signature = [self signMessage:content withSecret:appconfig.appsecret];
    [accessParam setValue:signature forKey:@"Signature"];
    
    
    NSURL *url = [NSURL URLWithString:@"https://iot.cloud.tencent.com/api/exploreropen/appapi"];
    NSMutableURLRequest *reqlog = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [reqlog setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    reqlog.HTTPMethod = @"POST";
    reqlog.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];;
    NSURLSessionDataTask *tasklog = [[NSURLSession sharedSession] dataTaskWithRequest:reqlog completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        app_config_t config_ = {
            .server = "",
            .ip = "",
            .port = 20002,
            .type = appconfig.type,
            .cross = false
        };
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *jsonerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
//            NSLog(@"log serverapi:content===>%@, param==>%@, data===>%@",content,accessParam,dic);
            NSDictionary *deviceconfig = [[dic objectForKey:@"data"] objectForKey:@"Config"];
            
            bool enableCrossStunTurn = [[deviceconfig objectForKey:@"EnableCrossStunTurn"] boolValue];
            int stunPort = [[deviceconfig objectForKey:@"StunPort"] intValue];
            NSString *stunHost = [deviceconfig objectForKey:@"StunHost"];
            NSString *stunIP = [deviceconfig objectForKey:@"StunIP"];
            NSString *protocol = [deviceconfig objectForKey:@"Protocol"];
            
            config_.cross = enableCrossStunTurn;
            if (stunPort) {
                config_.port = stunPort;
            }
            if (stunHost.length > 0) {
                config_.server = stunHost.UTF8String;
            }
            if (stunIP.length > 0) {
                config_.ip = stunIP.UTF8String;
            }
            if ([protocol isEqualToString:@"TCP"]) {
                config_.type = XP2P_PROTOCOL_TCP;
            }else {
                config_.type = XP2P_PROTOCOL_AUTO;
            }
        }
        
        
        if (config_.cross) {
            setCrossStunTurn(true);
        }
        
        NSString *combinedId = [NSString stringWithFormat:@"%@/%@", appconfig.pro_id, appconfig.dev_name];

        startService(combinedId.UTF8String, appconfig.pro_id.UTF8String, appconfig.dev_name.UTF8String, config_);
        setDeviceXp2pInfo(combinedId.UTF8String, appconfig.xp2pinfo.UTF8String);
    }];
    [tasklog resume];
}

- (NSString *)getUrlForHttpFlv:(NSString *)combinedId {
    const char *httpflv =  delegateHttpFlv(combinedId.UTF8String);
    NSLog(@"httpflv---%s",httpflv);
    if (httpflv) {
        return [NSString stringWithCString:httpflv encoding:[NSString defaultCStringEncoding]];
    }
    return @"";
}

/*
- (XP2PErrCode)startLanAppWith:(NSString *)pro_id dev_name:(NSString *)dev_name remote_host:(NSString *)remote_host remote_port:(NSString *)remote_port {
    setUserCallbackToXp2p(XP2PDataMsgHandle, XP2PMsgHandle, XP2PReviceDeviceCustomMsgHandle);
    
    self.dev_name = dev_name;
    int ret = startLanService(dev_name.UTF8String, pro_id.UTF8String, dev_name.UTF8String, remote_host.UTF8String, remote_port.UTF8String);
    return (XP2PErrCode)ret;
}

- (NSString *)getLanUrlForHttpFlv:(NSString *)dev_name {
    const char *httpflv =  getLanUrl(dev_name.UTF8String);
    NSLog(@"httpflv---%s",httpflv);
    if (httpflv) {
        return [NSString stringWithCString:httpflv encoding:[NSString defaultCStringEncoding]];
    }
    return @"";
}

- (int)getLanProxyPort:(NSString *)dev_name {
    int proxyPort = getLanProxyPort(dev_name.UTF8String);
    return proxyPort;
}
*/

- (void)getCommandRequestWithAsync:(NSString *)combinedId cmd:(NSString *)cmd timeout:(uint64_t)timeout completion:(void (^ __nullable)(NSString * jsonList))completion{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        unsigned char *bbuf = nullptr;
        size_t len = 0;
        NSString *tempCmd = cmd?:@"";
        NSData *data = [tempCmd dataUsingEncoding:NSUTF8StringEncoding];
        size_t cmdLen = data.length;
        
//        getCommandRequestWithSync(dev_name.UTF8String, cmd.UTF8String, &buf, &len, timeout);
        postCommandRequestSync(combinedId.UTF8String, (const unsigned char *)cmd.UTF8String, cmdLen, &bbuf, &len, timeout);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion && bbuf) {
                completion([NSString stringWithUTF8String:(char *)bbuf]);
            }
        });
    });
}

- (void)startAvRecvService:(NSString *)combinedId cmd:(NSString *)cmd {
    startAvRecvService(combinedId.UTF8String, cmd.UTF8String, false);
}

- (XP2PErrCode)stopAvRecvService:(NSString *)combinedId {
    return (XP2PErrCode)stopAvRecvService(combinedId.UTF8String, nullptr);
}

- (void)sendVoiceToServer:(NSString *)combinedId channel:(NSString *)channel_number {
    [self sendVoiceToServer:combinedId channel:channel_number audioConfig:TIoTAVCaptionFLVAudio_8];
}

- (void)sendVoiceToServer:(NSString *)combinedId channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate{
    [self sendVoiceToServer:combinedId channel:channel_number audioConfig:audio_rate withLocalPreviewView:nil];
}

- (void)sendVoiceToServer:(NSString *)combinedId channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate withLocalPreviewView:(UIView *)localView {
    [self sendVoiceToServer:combinedId channel:channel_number audioConfig:audio_rate withLocalPreviewView:localView videoPosition:AVCaptureDevicePositionBack];
}

- (void)sendVoiceToServer:(NSString *)combinedId channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate withLocalPreviewView:(UIView *)localView videoPosition:(AVCaptureDevicePosition)videoPosition {
    [self sendVoiceToServer:combinedId channel:channel_number audioConfig:audio_rate withLocalPreviewView:localView videoPosition:videoPosition isEchoCancel:NO];
}

- (void)sendVoiceToServer:(NSString *)combinedId channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate withLocalPreviewView:(UIView *)localView videoPosition:(AVCaptureDevicePosition)videoPosition isEchoCancel:(BOOL)isEchoCancel {
    TIoTCoreAudioConfig *audio_config = [TIoTCoreAudioConfig new];
    audio_config.sampleRate = audio_rate;
    audio_config.channels = 1;
    audio_config.isEchoCancel = isEchoCancel;
    audio_config.pitch = 0;
    
    TIoTCoreVideoConfig *video_config = [TIoTCoreVideoConfig new];
    video_config.localView = localView;
    video_config.videoPosition = videoPosition;
    [self sendVoiceToServer:combinedId channel:channel_number audioConfig:audio_config videoConfig:video_config];
}

- (void)setupAVAudioSession:(TIoTCoreAudioConfig *)audio_config {
    AVAudioSession *avsession = [AVAudioSession sharedInstance];
    [avsession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [avsession setPreferredSampleRate:16000 error:nil];
    [avsession setPreferredInputNumberOfChannels:audio_config.channels error:nil];
    
    //16khz * 1channel * notEcho = 640frame 设置为0.03
    NSTimeInterval duration = 0.015;
    if (audio_config.isEchoCancel) {
        duration = duration*2; //回音消除打开会减少采样
    }
    if (audio_config.channels == 2) {
        duration = duration/2;
    }
    [avsession setPreferredIOBufferDuration:duration error:nil];
    [avsession setActive:YES error:nil];
}

- (void)sendVoiceToServer:(NSString *)combinedId channel:(NSString *)channel_number audioConfig:(TIoTCoreAudioConfig *)audio_config videoConfig:(TIoTCoreVideoConfig *)video_config {
//    [self setupAVAudioSession:audio_config];
//    NSString *audioFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"testVideoStreamfile.flv"];
//    [[NSFileManager defaultManager] removeItemAtPath:audioFile error:nil];
//    [[NSFileManager defaultManager] createFileAtPath:audioFile contents:nil attributes:nil];
//    fileHandle = [NSFileHandle fileHandleForWritingAtPath:audioFile];
    CFTimeInterval timestamp = CACurrentMediaTime();
    if ((timestamp - self.start_voice_time)<1.5) {
        return;
    }
    self.start_voice_time = timestamp;
    
    audio_config.channels = 1;
    self.isSending = YES;
    
    self.talk_dev_name = combinedId;
    const char *channel = [channel_number UTF8String];
    _serverHandle = runSendService(combinedId.UTF8String, channel, false); //发送数据前需要告知http proxy
    
    
    if (systemAvCapture == nil) {
        systemAvCapture = [[TIoTAVCaptionFLV alloc] initWithAudioConfig:audio_config.sampleRate channel:audio_config.channels];
        systemAvCapture.videoLocalView = video_config.localView;
        systemAvCapture.isEchoCancel = audio_config.isEchoCancel;
    }
    systemAvCapture.audioConfig = audio_config;
    systemAvCapture.videoConfig = video_config;
    systemAvCapture.pitch = audio_config.pitch;
    systemAvCapture.devicePosition = video_config.videoPosition;
    systemAvCapture.videoLocalView = video_config.localView;
    [systemAvCapture setResolutionRatio:self.resolution];
    [systemAvCapture preStart];//配置声音和视频
    [systemAvCapture setVideoBitRate:video_config.bitRate];
    
    systemAvCapture.delegate = self;
    [systemAvCapture startCapture];
    
    if (video_config.isExternal) {
        return;//走外部自适应码率逻辑，提供getSendingBufSize获取实时发送水位大小
    }
    _p2p_wl_avg_ctx = {0};
    _p2p_wl_avg_ctx.len = MAX_AVG_LENGTH;
    //每次send时，先销毁之前已存在timer，保证多次send内部只持有一个timer
    [self cancelTimer];
    if (video_config.localView != nil) {
        _getBufTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getSendBufSize) userInfo:nil repeats:YES];
    }
}


- (int32_t)getSendingBufSize {
    int32_t bufsize = 0;
    if (self.isSending) {
        bufsize = (int32_t)getStreamBufSize(self.talk_dev_name.UTF8String);
    }
    return bufsize;
}

- (void)getSendBufSize {
    
    int32_t bufsize = (int32_t)getStreamBufSize(self.talk_dev_name.UTF8String);
    
    
    int32_t p2p_wl_avg = avg_max_min(&_p2p_wl_avg_ctx, bufsize);
    
    int32_t now_video_rate = systemAvCapture.getVideoBitRate;
    
//    for (int i =0; i < _p2p_wl_avg_ctx.len; i++) {
//        printf("\n stream_buf_con==%d \n",_p2p_wl_avg_ctx.buf[i]);
//    }
//    NSLog(@"send_bufsize==%d, now_video_rate==%d, avg_index==%d",bufsize, now_video_rate, p2p_wl_avg);
    
    // 降码率
    // 当发现p2p的水线超过一定值时，降低视频码率，这是一个经验值，一般来说要大于 [视频码率/2]
    // 实测设置为 80%视频码率 到 120%视频码率 比较理想
    // 在10组数据中，获取到平均值，并将平均水位与当前码率比对。
    
    
    int32_t video_rate_byte = (now_video_rate / 8) * 3 / 4;
    if (p2p_wl_avg > video_rate_byte) {
        
        [systemAvCapture setVideoBitRate:video_rate_byte];
        
    }else if (p2p_wl_avg <  (now_video_rate / 8) / 3) {
    
    // 升码率
    // 测试发现升码率的速度慢一些效果更好
    // p2p水线经验值一般小于[视频码率/2]，网络良好的情况会小于 [视频码率/3] 甚至更低
        [systemAvCapture setVideoBitRate:now_video_rate + 5];
    }
}
//设置分辨率，需在开启通话前设置
- (void)resolutionRatio:(AVCaptureSessionPreset)resolutionValue {
    self.resolution = resolutionValue;
}

- (void)refreshLocalView:(UIView *)localView {
    systemAvCapture.videoLocalView = localView;
    [systemAvCapture refreshLocalPreviewView];
}

- (void)changeCameraPositon {
    [systemAvCapture changeCameraPositon];
}
- (XP2PErrCode)stopVoiceToServer {
    
    [self cancelTimer];
        
    self.isSending = NO;
    
    systemAvCapture.delegate = nil;
    systemAvCapture.videoLocalView = nil;
    [systemAvCapture stopCapture];
    
    int errorcode = stopSendService(self.talk_dev_name.UTF8String, nullptr);
    return (XP2PErrCode)errorcode;
}

- (void)stopService:(NSString *)combinedId {
    [self stopVoiceToServer];
    stopService(combinedId.UTF8String);
    
//    [self.logger stopLogging];
    //关闭文件
//    [fileHandle closeFile];
//    fileHandle = NULL;
}

- (void)cancelTimer {
    if (_getBufTimer) {
        [_getBufTimer invalidate];
        _getBufTimer = nil;
    }
}
#pragma mark -AWAVCaptureDelegate
- (void)capture:(uint8_t *)data len:(size_t)size {
    if (self.isSending) {
//        NSLog(@"vide stream data:%s  size:%zu",data,size);
        dataSend(self.talk_dev_name.UTF8String, data, size);
//        NSData *dataTag = [NSData dataWithBytes:data length:size];
//        [fileHandle writeData:dataTag];
    }
}

// 发布外部视频数据(自定义采集，自定义编码，h264数据)
- (void)SendExternalVideoPacket:(NSData *)videoPacket {
    if (self.isSending && systemAvCapture.videoConfig.isExternal) {
        encodeFlvData(1, videoPacket);
    }else {
        NSLog(@"没有开启推流服务，请调用 sendVoiceToServer 并打开isExternal");
    }
}
// 发布外部视频数据(自定义采集，自定义编码，aac数据)
- (void)SendExternalAudioPacket:(NSData *)audioPacket {
    if (self.isSending && systemAvCapture.audioConfig.isExternal) {
        encodeFlvData(0, audioPacket);
    }else {
        NSLog(@"没有开启推流服务，请调用 sendVoiceToServer 并打开isExternal");
    }
}
 
- (void)setRemoteAudioFrame:(void *)pcmdata len:(int)pcmlen {
    if (self.isSending) {
        [systemAvCapture setRemoteAudioFrame:pcmdata len:pcmlen];
    }
}

static NSString *_appUUIDUnitlKeyChainKey = @"__TYC_XDP_UUID_Unitl_Key_Chain_APPUUID";
- (NSString *)getAppUUID {
    NSString *uuidString = [self readKeychainValue:_appUUIDUnitlKeyChainKey];
    NSString *nsstr_user_id;
    if (uuidString.length) {
        nsstr_user_id = uuidString;
    }else{
        const char* str_user_id = getUserID();
        nsstr_user_id = [NSString stringWithCString:str_user_id encoding:NSASCIIStringEncoding];
        
        [self saveKeychainValue:nsstr_user_id key:_appUUIDUnitlKeyChainKey];
    }
    return nsstr_user_id;
}

- (NSMutableDictionary *)getKeychainQuery:(NSString *)service{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)kSecClassGenericPassword,
            (__bridge_transfer id)kSecClass,service,
            (__bridge_transfer id)kSecAttrService,service,
            (__bridge_transfer id)kSecAttrAccount,
            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,
            (__bridge_transfer id)kSecAttrAccessible,
            nil];
}

- (void)saveKeychainValue:(NSString *)sValue key:(NSString *)sKey{
    NSMutableDictionary * keychainQuery = [self getKeychainQuery:sKey];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:sValue] forKey:(__bridge_transfer id)kSecValueData];
    
    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
    
}

- (NSString *)readKeychainValue:(NSString *)sKey
{
    NSString *ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:sKey];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = (NSString *)[NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", sKey, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

- (void)doTick:(data_report_t)data_buf {
    [self reportUserList:data_buf];
    return;
    if (data_buf.report_size < 2) {
        return;
    }

    NSData *body = [NSData dataWithBytes:data_buf.report_buf length:data_buf.report_size];
    NSURL *urlString = [NSURL URLWithString:@"https://log.qvb.qcloud.com/reporter/vlive"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlString cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
//            NSLog(@"log event: %@",response);
        }
    }];
    [task resume];
}

- (void)reportUserList:(data_report_t)report {
    if (!ops_report_enabled) {
        return;
    }
    NSString *reqid = [NSString stringWithCString:(const char *)report.uniqueId encoding:NSASCIIStringEncoding];
    NSString *status = [NSString stringWithCString:(const char *)report.status encoding:NSASCIIStringEncoding];
    NSString *dataaction = [NSString stringWithCString:(const char *)report.data_action encoding:NSASCIIStringEncoding];
    NSString *appPeerName = @"";
    if (report.appPeerName != NULL) {
        appPeerName = [NSString stringWithCString:(const char *)report.appPeerName encoding:NSASCIIStringEncoding];
    }
    NSString *deviceP2PInfo = @"";
    if (report.deviceP2PInfo != NULL) {
        deviceP2PInfo = [NSString stringWithCString:(const char *)report.deviceP2PInfo encoding:NSASCIIStringEncoding];
    }
    if ([status isEqualToString:@"start"]) {
        [self.uniReqStartTime setObject:[TIoTCoreXP2PBridge getNowTimeTimestamp] forKey:reqid];
    }
    
    NSInteger startTime = [[self.uniReqStartTime objectForKey:reqid] integerValue];
    if (startTime == 0) {
        return;
    }
    
    NSMutableDictionary *accessParam = [NSMutableDictionary dictionary];
    [accessParam setValue:@"P2PReport" forKey:@"Action"];
    [accessParam setValue:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    [accessParam setValue:status forKey:@"Status"];
    [accessParam setValue:dataaction forKey:@"DataAction"];
    [accessParam setValue:reqid forKey:@"UniqueId"];
    [accessParam setValue:@(startTime) forKey:@"StartTime"];
    [accessParam setValue:@([[TIoTCoreXP2PBridge getNowTimeTimestamp] integerValue]) forKey:@"Time"];
    [accessParam setValue:@"ios" forKey:@"System"];
    [accessParam setValue:@"app" forKey:@"Platform"];
    [accessParam setValue:[self getAppUUID] forKey:@"Uuid"];
    [accessParam setValue:[self getAppUUID] forKey:@"UserId"];
    [accessParam setValue:self.appConfig.pro_id forKey:@"ProductId"];
    [accessParam setValue:self.appConfig.dev_name forKey:@"DeviceName"];
    [accessParam setValue:@(report.live_size) forKey:@"ByteCount"];
    [accessParam setValue:@(0) forKey:@"Channel"];
    [accessParam setValue:appPeerName forKey:@"AppPeerNameFromApp"];
    [accessParam setValue:deviceP2PInfo forKey:@"DeviceP2PInfoFromApp"];
    [accessParam setValue:@(report.appUpByte) forKey:@"AppUpByte"];
    [accessParam setValue:@(report.appDownByte) forKey:@"AppDownByte"];
    [accessParam setValue:[TIoTCoreXP2PBridge getSDKVersion] forKey:@"AppVersion"];
    if ([status isEqualToString:@"fail"]) {
        [accessParam setValue:@"err" forKey:@"AppResult"];
        [accessParam setValue:@(report.errorcode) forKey:@"AppFailMsg"];
        
    }else {
        [accessParam setValue:@"succ" forKey:@"AppResult"];
    }
    NSString *appConnectIp = @"";
    if (report.appConnectIp != NULL) {
        appConnectIp = [NSString stringWithCString:(const char *)report.appConnectIp encoding:NSASCIIStringEncoding];
    }
    [accessParam setValue:appConnectIp forKey:@"AppConnectIp"];
    
    NSURL *url = [NSURL URLWithString:@"https://applog.iotcloud.tencentiotcloud.com/api/xp2p_ops/applog"];
    NSMutableURLRequest *reqlog = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [reqlog setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    reqlog.HTTPMethod = @"POST";
    reqlog.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];;
    NSURLSessionDataTask *tasklog = [[NSURLSession sharedSession] dataTaskWithRequest:reqlog completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
//            NSLog(@"app log: %@---req-%@",response, accessParam);
        }
    }];
    [tasklog resume];
    
    if ([status isEqualToString:@"end"] || [status isEqualToString:@"fail"]) {
        [self.uniReqStartTime removeObjectForKey:reqid];
    }
}

- (void)getAppLogConfig {
    NSString * tmp_p2p_log_enabled = [self readKeychainValue:@"p2p_log_enabled"];
    NSString * tmp_ops_report_enabled = [self readKeychainValue:@"ops_report_enabled"];
    
    if (tmp_p2p_log_enabled) {
        p2p_log_enabled = tmp_p2p_log_enabled.boolValue;
    }
    if (tmp_ops_report_enabled) {
        ops_report_enabled = tmp_ops_report_enabled.boolValue;
    }
}
- (void)setAppLogConfig:(NSDictionary *)appconfig {
    NSString * tmp_p2p_log_enabled = [appconfig objectForKey:@"P2PLogEnabled"];
    NSString * tmp_ops_report_enabled = [appconfig objectForKey:@"OpsLogEnabled"];

    [self saveKeychainValue:tmp_p2p_log_enabled key:@"p2p_log_enabled"];
    [self saveKeychainValue:tmp_ops_report_enabled key:@"ops_report_enabled"];
}

+ (NSString *)getSDKVersion {
    return [NSString stringWithUTF8String:VIDEOSDKVERSION];
}

+ (void)recordstream:(NSString *)combinedId {
    startRecordPlayerStream(combinedId.UTF8String);
}

+ (int)getStreamLinkMode:(NSString *)combinedId {
    return getStreamLinkMode(combinedId.UTF8String);
}

+(NSString *)getNowTimeTimestamp {
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];
    return timeSp;
}
+(NSString *)getNowTimeTimestampSec {
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}
@end
