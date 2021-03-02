//
//  TIoTCoreXP2PBridge.m
//  TIoTLinkKitDemo
//
//  Created by eagleychen on 2020/12/14.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTCoreXP2PBridge.h"
#include <string.h>
#include "AppWrapper.h"
#import "AWSystemAVCapture.h"

//type=0:close通知； type=1:日志； type=2:json; type=3:文件开关; type=4:文件路径;
char* XP2PMsgHandle(int type, const char* msg) {
    if (type == 1) {
        
        NSString *nsFormat = [NSString stringWithUTF8String:msg];
        NSLog(@"%@", nsFormat);
    }else if (type == 3) {
        
        BOOL isWriteFile = [TIoTCoreXP2PBridge sharedInstance].writeFile;
        return (char*)(isWriteFile?"1":"0");
    }else if (type == 4) {
        
        NSString *fileName = @"video.data";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = paths.firstObject;
        NSString *saveFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
        return (char *)saveFilePath.UTF8String;
    }else {
        printf("XP2P log: %s\n", msg);
    }

//    return (char *)nsFormat.UTF8String;
    return nullptr;
}

void XP2PDataMsgHandle(uint8_t* recv_buf, size_t recv_len) {
    id<TIoTCoreXP2PBridgeDelegate> delegate = [TIoTCoreXP2PBridge sharedInstance].delegate;
    if ([delegate respondsToSelector:@selector(getVideoPacket:len:)]) {
        [delegate getVideoPacket:recv_buf len:recv_len];
    }
}


@interface TIoTCoreXP2PBridge ()<AWAVCaptureDelegate>
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
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeVoiceChat options:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil ];
        [audioSession setActive:YES error:nil];
#ifndef DEBUG
        [TIoTCoreXP2PBridge redirectNSLog];
#endif
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


- (void)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name {
    CFTimeInterval startTime = CACurrentMediaTime();
//注册回调
    setUserCallbackToXp2p(XP2PDataMsgHandle, XP2PMsgHandle);
    
    //1.配置IOT_P2P SDK
    setQcloudApiCred([sec_id UTF8String], [sec_key UTF8String]);
    setDeviceInfo([pro_id UTF8String], [dev_name UTF8String]);
    setXp2pInfoAttributes("_sys_xp2p_info");
    startServiceWithXp2pInfo("");
    
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    NSLog(@"%@", [NSString stringWithFormat:@"****** %@ ended: %g seconds ******\n",NSStringFromSelector(_cmd),elapsedTime]);
}

- (NSString *)getUrlForHttpFlv {
    const char *httpflv =  delegateHttpFlv();
    NSLog(@"httpflv---%s",httpflv);
    return [NSString stringWithCString:httpflv encoding:[NSString defaultCStringEncoding]];
}

- (void)getCommandRequestWithAsync:(NSString *)cmd timeout:(uint64_t)timeout completion:(void (^ __nullable)(NSString * jsonList))completion{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        char *buf = nullptr;
        size_t len = 0;
        getCommandRequestWithSync(cmd.UTF8String, &buf, &len, timeout);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion([NSString stringWithUTF8String:buf]);
            }
        });
    });
}

- (void)startAvRecvService:(NSString *)cmd {
    startAvRecvService(cmd.UTF8String);
}

- (void)stopAvRecvService {
    stopAvRecvService(nullptr);
}

- (void)sendVoiceToServer {
    
    _serverHandle = runSendService(); //发送数据前需要告知http proxy
    
    AWAudioConfig *config = [[AWAudioConfig alloc] init];
    systemAvCapture = [[AWSystemAVCapture alloc] initWithAudioConfig:config];
    systemAvCapture.delegate = self;
    systemAvCapture.audioEncoderType = AWAudioEncoderTypeSWFAAC;
    [systemAvCapture startCapture];
}

- (void)stopVoiceToServer {

    [systemAvCapture stopCapture];
    systemAvCapture.delegate = nil;
}

- (void)stopService {
    [self stopVoiceToServer];
    stopService();
}

#pragma mark -AWAVCaptureDelegate
- (void)capture:(uint8_t *)data len:(size_t)size {
    dataSend(data, size);
}


+ (NSString *)getSDKVersion {    
    return [NSString stringWithUTF8String:VIDEOSDKVERSION];
}
@end
