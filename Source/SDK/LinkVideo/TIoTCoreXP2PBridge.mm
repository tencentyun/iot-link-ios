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

FILE *p2pOutLogFile;
//NSFileHandle *fileHandle;

@interface TIoTCoreXP2PBridge ()<TIoTAVCaptionFLVDelegate, TRTCCloudDelegate>
@property (nonatomic, strong) NSString *dev_name;
@property (nonatomic, assign) BOOL isSending;
@property (nonatomic, strong) AVCaptureSessionPreset resolution;
@property (nonatomic, strong) NSTimer *getBufTimer;
@property (nonatomic, strong)TIoTCoreAudioConfig *audioConfig;
@property (nonatomic, strong)TIoTCoreVideoConfig *videoConfig;
- (void)cancelTimer;
@end

const char* XP2PMsgHandle(const char *idd, XP2PType type, const char* msg) {
    if (idd == nullptr) {
        return nullptr;
    }
    
    BOOL logEnable = [TIoTCoreXP2PBridge sharedInstance].logEnable;
    if (logEnable) {
        printf("XP2P log: %s\n", msg);
    }
    
    if (type == XP2PTypeLog) {
        if (logEnable) {
            fwrite(msg, 1, strlen(msg)>300?300:strlen(msg), p2pOutLogFile);
        }
    }
    
    @autoreleasepool {
        
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
            [[TIoTCoreXP2PBridge sharedInstance] cancelTimer];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationDisconnect object:nil userInfo:@{@"id": DeviceName}];
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
    
    [self startAppWith:pro_id dev_name:dev_name];
    return XP2P_ERR_NONE;
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
    if (!self.params) {
        NSLog(@"⚠️⚠️⚠️⚠️⚠️⚠️⚠️请在startApp之前，提前设置params参数。例如：[TIoTCoreXP2PBridge sharedInstance].params = XXX;");
    }
    
    TRTCVideoEncParam *videoEncParam = [[TRTCVideoEncParam alloc] init];
    videoEncParam.videoResolution = TRTCVideoResolution_320_240;
    videoEncParam.videoFps = 15;
    videoEncParam.videoBitrate = 250;
    videoEncParam.resMode = TRTCVideoResolutionModePortrait;
    videoEncParam.enableAdjustRes = true;
    [[TRTCCloud sharedInstance] setVideoEncoderParam:videoEncParam];
    
    [TRTCCloud sharedInstance].delegate = self;
    [[TRTCCloud sharedInstance] enterRoom:self.params appScene:TRTCAppSceneVideoCall];
    return XP2P_ERR_NONE;
    
    
//    setStunServerToXp2p("11.11.11.11", 111);
    //注册回调
    setUserCallbackToXp2p(XP2PDataMsgHandle, XP2PMsgHandle, XP2PReviceDeviceCustomMsgHandle);
    
    //1.配置IOT_P2P SDK
    self.dev_name = dev_name;
    int ret = startService(dev_name.UTF8String, pro_id.UTF8String, dev_name.UTF8String);
    return (XP2PErrCode)ret;
}

- (XP2PErrCode)setXp2pInfo:(NSString *)dev_name sec_id:(NSString *)sec_id sec_key:(NSString *)sec_key  xp2pinfo:(NSString *)xp2pinfo {
    return XP2P_ERR_NONE;
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
//    [[TRTCCloud sharedInstance] startRemoteView:<#(nonnull NSString *)#> streamType:<#(TRTCVideoStreamType)#> view:<#(nullable TXView *)#>];
    return @"";
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
    NSData *cmddata = [cmd?:@"" dataUsingEncoding:NSUTF8StringEncoding];
    [[TRTCCloud sharedInstance] sendCustomCmdMsg:1 data:cmddata reliable:YES ordered:YES];
    if (completion) {
        NSString *jsondata = @"[{\"status\":\"0\",\"appConnectNum\":\"2\"}]";
        completion(jsondata);
    }
    return;
    
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
    return;
    startAvRecvService(dev_name.UTF8String, cmd.UTF8String, false);
}

- (XP2PErrCode)stopAvRecvService:(NSString *)dev_name {
    return XP2P_ERR_NONE;
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

- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTCoreAudioConfig *)audio_config videoConfig:(TIoTCoreVideoConfig *)video_config {
//    NSString *audioFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"testVideoStreamfile.flv"];
//    [[NSFileManager defaultManager] removeItemAtPath:audioFile error:nil];
//    [[NSFileManager defaultManager] createFileAtPath:audioFile contents:nil attributes:nil];
//    fileHandle = [NSFileHandle fileHandleForWritingAtPath:audioFile];
    self.audioConfig = audio_config;
    self.videoConfig = video_config;
    [[TRTCCloud sharedInstance] startLocalPreview:(video_config.videoPosition == AVCaptureDevicePositionFront)?YES:NO view:video_config.localView];
    [[TRTCCloud sharedInstance] startLocalAudio:TRTCAudioQualitySpeech];
    return;
    
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
    
    systemAvCapture.delegate = self;
    [systemAvCapture startCapture];
    
    _p2p_wl_avg_ctx = {0};
    _p2p_wl_avg_ctx.len = MAX_AVG_LENGTH;
    //每次send时，先销毁之前已存在timer，保证多次send内部只持有一个timer
    [self cancelTimer];
    if (video_config.localView != nil) {
        _getBufTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getSendBufSize) userInfo:nil repeats:YES];
    }
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
    [[TRTCCloud sharedInstance] updateLocalView:localView];
    return;
    systemAvCapture.videoLocalView = localView;
    [systemAvCapture refreshLocalPreviewView];
}

- (void)changeCameraPositon {
    TXDeviceManager *device = [[TRTCCloud sharedInstance] getDeviceManager];
    [device switchCamera:device.isFrontCamera?NO:YES];
    return;
    [systemAvCapture changeCameraPositon];
}
- (XP2PErrCode)stopVoiceToServer {
    [[TRTCCloud sharedInstance] stopLocalAudio];
    [[TRTCCloud sharedInstance] stopLocalPreview];
    return XP2P_ERR_NONE;
    
    [self cancelTimer];
        
    self.isSending = NO;
    
    systemAvCapture.delegate = nil;
    systemAvCapture.videoLocalView = nil;
    [systemAvCapture stopCapture];
    
    int errorcode = stopSendService(self.dev_name.UTF8String, nullptr);
    
    return (XP2PErrCode)errorcode;
}

- (void)setAudioRoute:(BOOL)isHandsFree {
    [[TRTCCloud sharedInstance] setAudioRoute:isHandsFree ? TRTCAudioModeSpeakerphone : TRTCAudioModeEarpiece];
}

- (void)muteLocalAudio:(BOOL)mute {
    [[TRTCCloud sharedInstance] muteLocalAudio:mute];
}

- (void)stopService:(NSString *)dev_name {
    [self stopVoiceToServer];
    [[TRTCCloud sharedInstance] stopAllRemoteView];
    [[TRTCCloud sharedInstance] exitRoom];
    return;
    [self stopVoiceToServer];
    stopService(dev_name.UTF8String);
    
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

+ (NSString *)getSDKVersion {
    return [NSString stringWithUTF8String:VIDEOSDKVERSION];
}

+ (void)recordstream:(NSString *)dev_name {
    startRecordPlayerStream(dev_name.UTF8String);
}

+ (int)getStreamLinkMode:(NSString *)dev_name {
    return getStreamLinkMode(dev_name.UTF8String);
}





#pragma mark -TRTCCloudDelegate
- (void)onEnterRoom:(NSInteger)result {
    if (result > 0) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationReady object:nil userInfo:nil];
//        });
    }
}

- (void)onRemoteUserEnterRoom:(NSString *)userId {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationReady object:nil userInfo:nil];
    });
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    //0表示用户主动退出房间，1表示用户超时退出，2表示被踢出房间，3表示主播因切换到观众退出房间。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TIoTCoreXP2PBridgeNotificationDisconnect object:nil userInfo:nil];
    });
    
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    if (available) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TRTCCloud sharedInstance] startRemoteView:userId streamType:TRTCVideoStreamTypeSmall view:self.videoConfig.remoteView];
        });
    }
}

- (void)onRecvCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID seq:(UInt32)seq message:(NSData *)message {
    id<TIoTCoreXP2PBridgeDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(reviceDeviceMsgWithID:data:)]) {
        NSString *response = [delegate reviceDeviceMsgWithID:userId data:message];
        /*
        if (response) {
            NSUInteger length = strlen(response.UTF8String);
            char *response_msg = (char *)malloc(length + 1);
            strncpy(response_msg, response.UTF8String, length);
            response_msg[length] = '\0';
            
            return response_msg;
        }*/
    }
}

- (void)onFirstVideoFrame:(NSString *)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height {
    id<TIoTCoreXP2PBridgeDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(onFirstVideoFrame)]) {
        [delegate onFirstVideoFrame];
    }
}
@end
