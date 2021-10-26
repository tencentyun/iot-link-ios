//
//  TIoTCoreXP2PBridge.m
//  TIoTLinkKitDemo
//
//

#import "TIoTCoreXP2PBridge.h"
#include <string.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelOff;
#endif

const char* XP2PMsgHandle(const char *idd, XP2PType type, const char* msg) {
    if (idd == nullptr) {
        return nullptr;
    }
    
    if (type == XP2PTypeLog) {
        BOOL logEnable = [TIoTCoreXP2PBridge sharedInstance].logEnable;
        if (logEnable) {
            NSString *nsFormat = [NSString stringWithUTF8String:msg];
            DDLogInfo(@"%@", nsFormat);
        }
    }else if (type == XP2PTypeSaveFileOn) {
        
        BOOL isWriteFile = [TIoTCoreXP2PBridge sharedInstance].writeFile;
        return (isWriteFile?"1":"0");
    }else if (type == XP2PTypeSaveFileUrl) {
        
        NSString *fileName = @"video.data";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = paths.firstObject;
        NSString *saveFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
        return saveFilePath.UTF8String;
        
    }else if (type == XP2PTypeDisconnect || type == XP2PTypeDetectError) {
        DDLogWarn(@"XP2P log: disconnect %s\n", msg);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *DeviceName = [NSString stringWithUTF8String:idd];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"xp2disconnect" object:nil userInfo:@{@"id": DeviceName}];
            
        });
    }else if (type == XP2PTypeDetectReady) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *DeviceName = [NSString stringWithUTF8String:idd];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"xp2preconnect" object:nil userInfo:@{@"id": DeviceName}];
        });
    }
    else {
        DDLogInfo(@"XP2P log: %s\n", msg);
    }

//    return (char *)nsFormat.UTF8String;
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
#ifndef DEBUG
        [TIoTCoreXP2PBridge redirectNSLog];
#endif
        //默认打开log开关
        _logEnable = YES;
    }
    return self;
}

+ (void)redirectNSLog {
    
    NSString *fileName = @"TTLog.log";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths.firstObject;
    NSString *saveFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
//    [[NSFileManager defaultManager] removeItemAtPath:saveFilePath error:nil];

    freopen([saveFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([saveFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}


- (XP2PErrCode)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name {
//    setStunServerToXp2p("11.11.11.11", 111);
    return [self startAppWith:sec_id sec_key:sec_key pro_id:pro_id dev_name:dev_name xp2pinfo:@""];
}

- (XP2PErrCode)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name xp2pinfo:(NSString *)xp2pinfo {
    //注册回调
    setUserCallbackToXp2p(XP2PDataMsgHandle, XP2PMsgHandle);
    
    //1.配置IOT_P2P SDK
    self.dev_name = dev_name;
    setQcloudApiCred([sec_id UTF8String], [sec_key UTF8String]); //正式版app发布时候需要去掉，避免泄露secretid和secretkey，此处仅为演示
    return (XP2PErrCode)startServiceWithXp2pInfo(dev_name.UTF8String, [pro_id UTF8String], [dev_name UTF8String], [xp2pinfo UTF8String]);
}

- (NSString *)getUrlForHttpFlv:(NSString *)dev_name {
    const char *httpflv =  delegateHttpFlv(dev_name.UTF8String);
    DDLogInfo(@"httpflv---%s",httpflv);
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
    
    return (XP2PErrCode)stopSendService(self.dev_name.UTF8String, nullptr);
}

- (void)stopService:(NSString *)dev_name {
    [self stopVoiceToServer];
    stopService(dev_name.UTF8String);
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

//+ (void)recordstream:(NSString *)dev_name {
//    startRecordPlayerStream(dev_name.UTF8String);
//}
@end
