//
//  TIoTCoreXP2PBridge.m
//  TIoTLinkKitDemo
//
//

#import "TIoTCoreXP2PBridge.h"
#include <string.h>

NSFileHandle *p2pOutLogFile;

const char* XP2PMsgHandle(const char *idd, XP2PType type, const char* msg) {
    if (idd == nullptr) {
        return nullptr;
    }
    NSString *message = [NSString stringWithCString:msg encoding:[NSString defaultCStringEncoding]];
    NSLog(@"XP2P log: %@\n", message);
    
    if (type == XP2PTypeLog) {
        BOOL logEnable = [TIoTCoreXP2PBridge sharedInstance].logEnable;
        if (logEnable) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [p2pOutLogFile writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
            });
        }
    }
    
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
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [p2pOutLogFile synchronizeFile];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"xp2disconnect" object:nil userInfo:@{@"id": DeviceName}];
        });
    }else if (type == XP2PTypeDetectReady) {
        NSLog(@"XP2P log: ready %@\n", message);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [p2pOutLogFile synchronizeFile];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"xp2preconnect" object:nil userInfo:@{@"id": DeviceName}];
        });
    }
    else if (type == XP2PTypeDeviceMsgArrived) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"revice device msg: %@", message);
//        });
    }
    
    return nullptr;
}

void XP2PDataMsgHandle(const char *idd, uint8_t* recv_buf, size_t recv_len) {
    id<TIoTCoreXP2PBridgeDelegate> delegate = [TIoTCoreXP2PBridge sharedInstance].delegate;
    if ([delegate respondsToSelector:@selector(getVideoPacket:len:)]) {
        [delegate getVideoPacket:recv_buf len:recv_len];
    }
}


@interface TIoTCoreXP2PBridge ()<AWAVCaptureDelegate>
@property (nonatomic, strong) NSString *dev_name;
@property (nonatomic, assign) BOOL isSending;
@end

@implementation TIoTCoreXP2PBridge {
    
    AWSystemAVCapture *systemAvCapture;

    dispatch_source_t timer;
    void *_serverHandle;
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
    setUserCallbackToXp2p(XP2PDataMsgHandle, XP2PMsgHandle);
    
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
    setUserCallbackToXp2p(XP2PDataMsgHandle, XP2PMsgHandle);
    
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
    AWAudioConfig *config = [[AWAudioConfig alloc] init];
    [self sendVoiceToServer:dev_name channel:channel_number audioConfig:config];
}

- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(AWAudioConfig *)audio_onfig{
    
    self.isSending = YES;
    
    self.dev_name = dev_name;
    const char *channel = [channel_number UTF8String];
    _serverHandle = runSendService(dev_name.UTF8String, channel, false); //发送数据前需要告知http proxy
    
    systemAvCapture = [[AWSystemAVCapture alloc] initWithAudioConfig:audio_onfig];
    systemAvCapture.delegate = self;
    systemAvCapture.audioEncoderType = AWAudioEncoderTypeHWAACLC;
    [systemAvCapture startCapture];
}

- (XP2PErrCode)stopVoiceToServer {
    self.isSending = NO;
    
    [systemAvCapture stopCapture];
    systemAvCapture.delegate = nil;
    
    int errorcode = stopSendService(self.dev_name.UTF8String, nullptr);
    
    [p2pOutLogFile synchronizeFile];
    return (XP2PErrCode)errorcode;
}

- (void)stopService:(NSString *)dev_name {
    [self stopVoiceToServer];
    stopService(dev_name.UTF8String);
    
    [p2pOutLogFile synchronizeFile];
}

#pragma mark -AWAVCaptureDelegate
- (void)capture:(uint8_t *)data len:(size_t)size {
    if (self.isSending) {
        dataSend(self.dev_name.UTF8String, data, size);
    }
}


+ (NSString *)getSDKVersion {    
    return [NSString stringWithUTF8String:VIDEOSDKVERSION];
}

+ (void)recordstream:(NSString *)dev_name {
    startRecordPlayerStream(dev_name.UTF8String);
}
@end
