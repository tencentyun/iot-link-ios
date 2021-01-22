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

- (void)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name {

    //1.配置IOT_P2P SDK
    setQcloudApiCred([sec_id UTF8String], [sec_key UTF8String]);
    setDeviceInfo([pro_id UTF8String], [dev_name UTF8String]);
    setXp2pInfoAttributes("_sys_xp2p_info");
    startServiceWithXp2pInfo("_server_info");
    
    
    //2.模拟发送数据
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), 0.1 * NSEC_PER_SEC, 0);
//    dispatch_source_set_event_handler(timer, ^{
//
//        NSLog(@"----");
//        [self sendDataToServer:@""];
//    });
//    dispatch_resume(timer);
    
    
    std::string httpflv =  delegateHttpFlv();
    printf("---%s",httpflv.c_str());
}

- (NSString *)getUrlForHttpFlv {
    std::string httpflv =  delegateHttpFlv();
    NSLog(@"httpflv---%s",httpflv.c_str());
    return [NSString stringWithCString:httpflv.c_str() encoding:[NSString defaultCStringEncoding]];
}

- (void)sendVoiceToServer {
    
    _serverHandle = runSendService(); //发送数据前需要告知http proxy
    
    AWAudioConfig *config = [[AWAudioConfig alloc] init];
    systemAvCapture = [[AWSystemAVCapture alloc] initWithAudioConfig:config];
    systemAvCapture.delegate = self;
    systemAvCapture.audioEncoderType = AWAudioEncoderTypeHWAACLC;
    [systemAvCapture startCapture];
}

- (void)stopVoiceToServer {

    [systemAvCapture stopCapture];
    systemAvCapture.delegate = nil;
}

- (void)stopService {
    stopSendService(_serverHandle);
    stopService();
}

#pragma mark -AWAVCaptureDelegate
- (void)capture:(uint8_t *)data len:(size_t)size {
    dataSend(data, size);
}

@end
