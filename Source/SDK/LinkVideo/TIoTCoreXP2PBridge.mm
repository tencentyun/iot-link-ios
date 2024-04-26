//
//  TIoTCoreXP2PBridge.m
//  TIoTLinkKitDemo
//
//

#import "TIoTCoreXP2PBridge.h"
#include <string.h>

NSNotificationName const TIoTCoreXP2PBridgeNotificationDisconnect   = @"xp2disconnect"; //p2p通道断开
NSNotificationName const TIoTCoreXP2PBridgeNotificationReady        = @"xp2preconnect"; //app本地已ready，表示探测完成，可以发起请求了
NSNotificationName const TIoTCoreXP2PBridgeNotificationDetectError  = @"xp2detecterror"; //探测失败，网络不正常表示探测完成，可以发起请求了
NSNotificationName const TIoTCoreXP2PBridgeNotificationDeviceMsg    = @"XP2PTypeDeviceMsgArrived"; //收到设备端的请求数据
NSNotificationName const TIoTCoreXP2PBridgeNotificationStreamEnd    = @"XP2PTypeStreamEnd"; // 设备主动停止推流，或者由于达到设备最大连接数，拒绝推流

FILE *p2pOutLogFile;
//NSFileHandle *fileHandle;

@interface TIoTCoreXP2PBridge ()<TIoTAVCaptionFLVDelegate>
@property (nonatomic, strong) NSString *dev_name;
@property (nonatomic, strong) NSString *pro_id;
@property (nonatomic, assign) BOOL isSending;
@property (nonatomic, strong) AVCaptureSessionPreset resolution;
@property (nonatomic, strong) NSTimer *getBufTimer;
@property (nonatomic, assign) NSInteger startTime;
- (void)cancelTimer;
- (void)doTick:(data_report_t)data_buf;
@end

const char* XP2PMsgHandle(const char *idd, XP2PType type, const char* msg) {
    
    BOOL logEnable = [TIoTCoreXP2PBridge sharedInstance].logEnable;
    if (logEnable) {
        printf("XP2Plog: %s", msg);
    }
    
    if (type == XP2PTypeLog) {
        if (logEnable) {
            fwrite(msg, 1, strlen(msg)>300?300:strlen(msg), p2pOutLogFile);
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
        
        NSString *logFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TIoTXP2P.log"];
        [[NSFileManager defaultManager] removeItemAtPath:logFile error:nil];
        [[NSFileManager defaultManager] createFileAtPath:logFile contents:nil attributes:nil];
        p2pOutLogFile = fopen(logFile.UTF8String, "wb");
    }
    return self;
}


- (XP2PErrCode)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name {
    return [self startAppWith:sec_id sec_key:sec_key pro_id:pro_id dev_name:dev_name xp2pinfo:@""];
}
- (XP2PErrCode)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name xp2pinfo:(NSString *)xp2pinfo {
    setQcloudApiCred([sec_id UTF8String], [sec_key UTF8String]); //正式版app发布时候需要去掉，避免泄露secretid和secretkey，此处仅为演示
    int ret = [self startAppWith:pro_id dev_name:dev_name type:XP2P_PROTOCOL_AUTO];
    setDeviceXp2pInfo(dev_name.UTF8String, xp2pinfo.UTF8String);
    return (XP2PErrCode)ret;
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

- (XP2PErrCode)startAppWith:(NSString *)pro_id dev_name:(NSString *)dev_name {
    return [self startAppWith:pro_id dev_name:dev_name type:XP2P_PROTOCOL_AUTO];
}
- (XP2PErrCode)startAppWith:(NSString *)pro_id dev_name:(NSString *)dev_name type:(XP2PProtocolType)type{
    //    setStunServerToXp2p("11.11.11.11", 111);
    //    setLogEnable(false, false);
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
    
    //1.配置IOT_P2P SDK
    self.pro_id = pro_id;
    self.dev_name = dev_name;
    int ret = startService(dev_name.UTF8String, pro_id.UTF8String, dev_name.UTF8String, type);
    return (XP2PErrCode)ret;
}

- (XP2PErrCode)setXp2pInfo:(NSString *)dev_name sec_id:(NSString *)sec_id sec_key:(NSString *)sec_key  xp2pinfo:(NSString *)xp2pinfo {
    
    if (xp2pinfo == nil || [xp2pinfo isEqualToString:@""]) {
        if ((sec_id == nil || [sec_id isEqualToString:@""])   ||  (sec_key == nil || [sec_key isEqualToString:@""])) {
            NSLog(@"请输入正确的scretId和secretKey，或者xp2pInfo");
            return XP2P_ERR_INIT_PRM;
        }
        setQcloudApiCred([sec_id UTF8String], [sec_key UTF8String]); //正式版app发布时候不需要传入secretid和secretkey，避免泄露secretid和secretkey，此处仅为演示
    }

    int ret = setDeviceXp2pInfo(dev_name.UTF8String, xp2pinfo.UTF8String);
    
    self.startTime = [[TIoTCoreXP2PBridge getNowTimeTimestamp] integerValue];
    [self reportUserList:0 status:@"start"];
    return (XP2PErrCode)ret;
}

- (NSString *)getUrlForHttpFlv:(NSString *)dev_name {
    const char *httpflv =  delegateHttpFlv(dev_name.UTF8String);
    NSLog(@"httpflv---%s",httpflv);
    if (httpflv) {
        return [NSString stringWithCString:httpflv encoding:[NSString defaultCStringEncoding]];
    }
    return @"";
}


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

- (void)getCommandRequestWithAsync:(NSString *)dev_name cmd:(NSString *)cmd timeout:(uint64_t)timeout completion:(void (^ __nullable)(NSString * jsonList))completion{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        unsigned char *bbuf = nullptr;
        size_t len = 0;
        NSString *tempCmd = cmd?:@"";
        NSData *data = [tempCmd dataUsingEncoding:NSUTF8StringEncoding];
        size_t cmdLen = data.length;
        
//        getCommandRequestWithSync(dev_name.UTF8String, cmd.UTF8String, &buf, &len, timeout);
        postCommandRequestSync(dev_name.UTF8String, (const unsigned char *)cmd.UTF8String, cmdLen, &bbuf, &len, timeout);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion && bbuf) {
                completion([NSString stringWithUTF8String:(char *)bbuf]);
            }
        });
    });
}

- (void)startAvRecvService:(NSString *)dev_name cmd:(NSString *)cmd {
    startAvRecvService(dev_name.UTF8String, cmd.UTF8String, false);
}

- (XP2PErrCode)stopAvRecvService:(NSString *)dev_name {
    return (XP2PErrCode)stopAvRecvService(dev_name.UTF8String, nullptr);
}

- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number {
    [self sendVoiceToServer:dev_name channel:channel_number audioConfig:TIoTAVCaptionFLVAudio_8];
}

- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate{
    [self sendVoiceToServer:dev_name channel:channel_number audioConfig:audio_rate withLocalPreviewView:nil];
}

- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate withLocalPreviewView:(UIView *)localView {
    [self sendVoiceToServer:dev_name channel:channel_number audioConfig:audio_rate withLocalPreviewView:localView videoPosition:AVCaptureDevicePositionBack];
}

- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate withLocalPreviewView:(UIView *)localView videoPosition:(AVCaptureDevicePosition)videoPosition {
    [self sendVoiceToServer:dev_name channel:channel_number audioConfig:audio_rate withLocalPreviewView:localView videoPosition:videoPosition isEchoCancel:NO];
}

- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate withLocalPreviewView:(UIView *)localView videoPosition:(AVCaptureDevicePosition)videoPosition isEchoCancel:(BOOL)isEchoCancel {
    TIoTCoreAudioConfig *audio_config = [TIoTCoreAudioConfig new];
    audio_config.sampleRate = audio_rate;
    audio_config.channels = 1;
    audio_config.isEchoCancel = isEchoCancel;
    audio_config.pitch = 0;
    
    TIoTCoreVideoConfig *video_config = [TIoTCoreVideoConfig new];
    video_config.localView = localView;
    video_config.videoPosition = videoPosition;
    [self sendVoiceToServer:dev_name channel:channel_number audioConfig:audio_config videoConfig:video_config];
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

- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTCoreAudioConfig *)audio_config videoConfig:(TIoTCoreVideoConfig *)video_config {
//    [self setupAVAudioSession:audio_config];
//    NSString *audioFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"testVideoStreamfile.flv"];
//    [[NSFileManager defaultManager] removeItemAtPath:audioFile error:nil];
//    [[NSFileManager defaultManager] createFileAtPath:audioFile contents:nil attributes:nil];
//    fileHandle = [NSFileHandle fileHandleForWritingAtPath:audioFile];
    audio_config.channels = 1;
    self.isSending = YES;
    
    self.dev_name = dev_name;
    const char *channel = [channel_number UTF8String];
    _serverHandle = runSendService(dev_name.UTF8String, channel, false); //发送数据前需要告知http proxy
    
    
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
        bufsize = (int32_t)getStreamBufSize(self.dev_name.UTF8String);
    }
    return bufsize;
}

- (void)getSendBufSize {
    
    int32_t bufsize = (int32_t)getStreamBufSize(self.dev_name.UTF8String);
    
    
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
    
    int errorcode = stopSendService(self.dev_name.UTF8String, nullptr);
    return (XP2PErrCode)errorcode;
}

- (void)stopService:(NSString *)dev_name {
    [self stopVoiceToServer];
    stopService(dev_name.UTF8String);
    
    [self reportUserList:0 status:@"end"];
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
        dataSend(self.dev_name.UTF8String, data, size);
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
    if (data_buf.report_size < 2) {
        return;
    }

    NSData *body = [NSData dataWithBytes:data_buf.report_buf length:data_buf.report_size];
    NSURL *urlString = [NSURL URLWithString:@"http://log.qvb.qcloud.com/reporter/vlive"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlString cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSLog(@"log event: %@",response);
        }
    }];
    [task resume];
    
    [self reportUserList:data_buf.xntp_size status:@"bytecount"];
}

- (void)reportUserList:(size_t)xntp_size status:(NSString *)status {
    
    static NSString *reqid = [[NSUUID UUID] UUIDString];
    NSMutableDictionary *accessParam = [NSMutableDictionary dictionary];
    [accessParam setValue:@"P2PReport" forKey:@"Action"];
    [accessParam setValue:@"byteCount" forKey:@"Status"];
    [accessParam setValue:@"live" forKey:@"DataAction"];
    [accessParam setValue:reqid forKey:@"UniqueId"];
    [accessParam setValue:@(self.startTime) forKey:@"StartTime"];
    [accessParam setValue:@([[TIoTCoreXP2PBridge getNowTimeTimestamp] integerValue]) forKey:@"Time"];
    [accessParam setValue:@"ios" forKey:@"System"];
    [accessParam setValue:@"app" forKey:@"Platform"];
    [accessParam setValue:[self getAppUUID] forKey:@"Uuid"];
    [accessParam setValue:[self getAppUUID] forKey:@"UserId"];
    [accessParam setValue:self.pro_id forKey:@"ProductId"];
    [accessParam setValue:self.dev_name forKey:@"DeviceName"];
    [accessParam setValue:@(xntp_size) forKey:@"ByteCount"];
    [accessParam setValue:@(1) forKey:@"Channel"];
    NSURL *url = [NSURL URLWithString:@"https://applog.iotcloud.tencentiotcloud.com/api/xp2p_ops/applog"];
    NSMutableURLRequest *reqlog = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [reqlog setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    reqlog.HTTPMethod = @"POST";
    reqlog.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];;
    NSURLSessionDataTask *tasklog = [[NSURLSession sharedSession] dataTaskWithRequest:reqlog completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSLog(@"app log: %@",response);
        }
    }];
    [tasklog resume];
}
+ (NSString *)getSDKVersion {
    return [NSString stringWithUTF8String:VIDEOSDKVERSION];
}

+ (void)recordstream:(NSString *)dev_name {
    startRecordPlayerStream(dev_name.UTF8String);
}

+ (int)getStreamLinkMode:(NSString *)dev_name {
    return getStreamLinkMode(dev_name.UTF8String);
}

+(NSString *)getNowTimeTimestamp {
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];
    return timeSp;
}

@end
