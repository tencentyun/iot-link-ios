//
//  TIoTCoreXP2PBridge.m
//  TIoTLinkKitDemo
//
//

#import "TIoTCoreXP2PBridge.h"
#include <string.h>

NSNotificationName const TIoTCoreXP2PBridgeNotificationDisconnect   = @"xp2disconnect"; //p2p通道断开
NSNotificationName const TIoTCoreXP2PBridgeNotificationReady        = @"xp2preconnect"; //app本地已ready，表示探测完成，可以发起请求了
NSNotificationName const TIoTCoreXP2PBridgeNotificationDeviceMsg    = @"XP2PTypeDeviceMsgArrived"; //收到设备端的请求数据
NSNotificationName const TIoTCoreXP2PBridgeNotificationStreamEnd    = @"XP2PTypeStreamEnd"; // 设备主动停止推流，或者由于达到设备最大连接数，拒绝推流

NSFileHandle *p2pOutLogFile;
NSFileHandle *fileHandle;

@interface TIoTCoreXP2PBridge ()<TIoTAVCaptionFLVDelegate>
@property (nonatomic, strong) NSString *dev_name;
@property (nonatomic, assign) BOOL isSending;
@property (nonatomic, strong) AVCaptureSessionPreset resolution;
@property (nonatomic, strong) NSTimer *getBufTimer;
- (void)cancelTimer;
@end

const char* XP2PMsgHandle(const char *idd, XP2PType type, const char* msg) {
    if (idd == nullptr) {
        return nullptr;
    }
    NSString *message = [NSString stringWithCString:msg encoding:[NSString defaultCStringEncoding]];
//    BOOL logEnable = [TIoTCoreXP2PBridge sharedInstance].logEnable;
//    if (logEnable) {
//        NSLog(@"XP2P log: %@\n", message);
//    }
//    
//    if (type == XP2PTypeLog) {
//        if (logEnable) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [p2pOutLogFile writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
//            });
//        }
//    }
    
    NSString *DeviceName = [NSString stringWithCString:idd encoding:[NSString defaultCStringEncoding]]?:@"";
    
    if (type == XP2PTypeSaveFileOn) {
        
        BOOL isWriteFile = [TIoTCoreXP2PBridge sharedInstance].writeFile;
        return (isWriteFile?"1":"0");
    }else if (type == XP2PTypeSaveFileUrl) {
        
        NSString *fileName = @"video.data";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = paths.firstObject;
        NSString *saveFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
        return saveFilePath.UTF8String;
        
    }else if (type == XP2PTypeDisconnect || type == XP2PTypeDetectError) {
        NSLog(@"XP2P log: disconnect %@\n", message);
        [[TIoTCoreXP2PBridge sharedInstance] cancelTimer];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [p2pOutLogFile synchronizeFile];
            [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationDisconnect object:nil userInfo:@{@"id": DeviceName}];
        });
    }else if (type == XP2PTypeDetectReady) {
        NSLog(@"XP2P log: ready %@\n", message);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [p2pOutLogFile synchronizeFile];
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
        NSLog(@"设备自定义信令未回复内容: %@", message);
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
        if ([delegate respondsToSelector:@selector(reviceEventMsgWithID:eventType:)]) {
            [delegate reviceEventMsgWithID:DeviceName eventType:type];
        }
    });
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

    NSString *DeviceName = [NSString stringWithCString:idd encoding:[NSString defaultCStringEncoding]]?:@"";
    NSData *DeviceData = [NSData dataWithBytes:recv_buf length:recv_len];

    id<TIoTCoreXP2PBridgeDelegate> delegate = [TIoTCoreXP2PBridge sharedInstance].delegate;
    if ([delegate respondsToSelector:@selector(reviceDeviceMsgWithID:data:)]) {
        NSString *response = [delegate reviceDeviceMsgWithID:DeviceName data:DeviceData];
        
        if (response) {
            NSUInteger length = strlen(response.UTF8String);
            char *response_msg = (char *)malloc(length + 1);
            strncpy(response_msg, response.UTF8String, length);
            response_msg[length] = '\0';
            
            return response_msg;
        }
    }
    return NULL;
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
        //默认打开log开关
        _logEnable = YES;
        
        NSString *logFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TIoTXP2P.log"];
        [[NSFileManager defaultManager] removeItemAtPath:logFile error:nil];
        [[NSFileManager defaultManager] createFileAtPath:logFile contents:nil attributes:nil];
        p2pOutLogFile = [NSFileHandle fileHandleForWritingAtPath:logFile];
    }
    return self;
}


- (XP2PErrCode)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name {
    return [self startAppWith:sec_id sec_key:sec_key pro_id:pro_id dev_name:dev_name xp2pinfo:@""];
}
- (XP2PErrCode)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name xp2pinfo:(NSString *)xp2pinfo {
    //注册回调
    setUserCallbackToXp2p(XP2PDataMsgHandle, XP2PMsgHandle, XP2PReviceDeviceCustomMsgHandle);
    
    //1.配置IOT_P2P SDK
    self.dev_name = dev_name;
    setQcloudApiCred([sec_id UTF8String], [sec_key UTF8String]); //正式版app发布时候需要去掉，避免泄露secretid和secretkey，此处仅为演示
    int ret = startService(dev_name.UTF8String, pro_id.UTF8String, dev_name.UTF8String);
    setDeviceXp2pInfo(dev_name.UTF8String, xp2pinfo.UTF8String);
    return (XP2PErrCode)ret;
}



- (XP2PErrCode)startAppWith:(NSString *)pro_id dev_name:(NSString *)dev_name {
//    setStunServerToXp2p("11.11.11.11", 111);
    //注册回调
    setUserCallbackToXp2p(XP2PDataMsgHandle, XP2PMsgHandle, XP2PReviceDeviceCustomMsgHandle);
    
    //1.配置IOT_P2P SDK
    self.dev_name = dev_name;
    int ret = startService(dev_name.UTF8String, pro_id.UTF8String, dev_name.UTF8String);
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
    NSString *audioFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"testVideoStreamfile.flv"];
    [[NSFileManager defaultManager] removeItemAtPath:audioFile error:nil];
    [[NSFileManager defaultManager] createFileAtPath:audioFile contents:nil attributes:nil];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:audioFile];
    
    self.isSending = YES;
    
    self.dev_name = dev_name;
    const char *channel = [channel_number UTF8String];
    _serverHandle = runSendService(dev_name.UTF8String, channel, false); //发送数据前需要告知http proxy
    
    
    if (systemAvCapture == nil) {
        systemAvCapture = [[TIoTAVCaptionFLV alloc] initWithAudioConfig:audio_rate];
        systemAvCapture.videoLocalView = localView;
        systemAvCapture.isEchoCancel = YES;
    }
    systemAvCapture.devicePosition = videoPosition;
    systemAvCapture.videoLocalView = localView;
    [systemAvCapture setResolutionRatio:self.resolution];
    [systemAvCapture preStart];//配置声音和视频
    
    systemAvCapture.delegate = self;
    [systemAvCapture startCapture];
    
    _p2p_wl_avg_ctx = {0};
    _p2p_wl_avg_ctx.len = MAX_AVG_LENGTH;
    //每次send时，先销毁之前已存在timer，保证多次send内部只持有一个timer
    [self cancelTimer];
    _getBufTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getSendBufSize) userInfo:nil repeats:YES];
}



- (void)getSendBufSize {
    
    int32_t bufsize = (int32_t)getStreamBufSize(self.dev_name.UTF8String);
    
    
    int32_t p2p_wl_avg = avg_max_min(&_p2p_wl_avg_ctx, bufsize);
    
    int32_t now_video_rate = systemAvCapture.getVideoBitRate;
    
//    for (int i =0; i < _p2p_wl_avg_ctx.len; i++) {
//        printf("\n stream_buf_con==%d \n",_p2p_wl_avg_ctx.buf[i]);
//    }
    NSLog(@"send_bufsize==%d, now_video_rate==%d, avg_index==%d",bufsize, now_video_rate, p2p_wl_avg);
    
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
    
    [p2pOutLogFile synchronizeFile];
    return (XP2PErrCode)errorcode;
}

- (void)stopService:(NSString *)dev_name {
    [self stopVoiceToServer];
    stopService(dev_name.UTF8String);
    
    [p2pOutLogFile synchronizeFile];
    //关闭文件
    [fileHandle closeFile];
    fileHandle = NULL;
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

+ (NSString *)getSDKVersion {
    return [NSString stringWithUTF8String:VIDEOSDKVERSION];
}

+ (void)recordstream:(NSString *)dev_name {
    startRecordPlayerStream(dev_name.UTF8String);
}

+ (int)getStreamLinkMode:(NSString *)dev_name {
    return getStreamLinkMode(dev_name.UTF8String);
}
@end
