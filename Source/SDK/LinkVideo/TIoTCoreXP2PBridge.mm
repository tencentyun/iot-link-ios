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

void TTTTLogMessageFunc(int type, char *format) {
        
    if (type == 1) {
        
        NSString *nsFormat = [NSString stringWithUTF8String:format];
        NSLog(@"%@", nsFormat);
    }else {
        printf("Parameter is: %s\n", format);
    }
}

void TTTTNativeVideoData(uint8_t *data, size_t len) {
    id<TIoTCoreXP2PBridgeDelegate> delegate = [TIoTCoreXP2PBridge sharedInstance].delegate;
    if ([delegate respondsToSelector:@selector(getVideoPacket:len:)]) {
        [delegate getVideoPacket:data len:len];
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
//注册log回调
    setNativeCallback(TTTTLogMessageFunc);
    setNativeCallback(TTTTNativeVideoData);
    
    //1.配置IOT_P2P SDK
    setQcloudApiCred([sec_id UTF8String], [sec_key UTF8String]);
    setDeviceInfo([pro_id UTF8String], [dev_name UTF8String]);
    setXp2pInfoAttributes("_sys_xp2p_info");
    startServiceWithXp2pInfo("");
}

- (NSString *)getUrlForHttpFlv {
    std::string httpflv =  delegateHttpFlv();
    NSLog(@"httpflv---%s",httpflv.c_str());
    return [NSString stringWithCString:httpflv.c_str() encoding:[NSString defaultCStringEncoding]];
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
