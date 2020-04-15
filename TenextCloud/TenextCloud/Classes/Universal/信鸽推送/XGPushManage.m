//
//  XGPushManage.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/26.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "XGPushManage.h"
#import <UserNotifications/UserNotifications.h>
#import "XGPush.h"

@interface XGPushManage ()<XGPushDelegate,UNUserNotificationCenterDelegate>

@property (nonatomic, copy) NSString *deviceToken;

@end

@implementation XGPushManage

static uint32_t const kXGAccessID = 1600003264;

static NSString *const kXGAccessKey = @"IN51HLDWINA3";

+ (id)sharedXGPushManage{
    static XGPushManage *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (void)startPushService{
    
#ifdef DEBUG
    [XGPush.defaultManager setEnableDebug:YES];
#endif
    [XGPush.defaultManager startXGWithAppID:kXGAccessID appKey:kXGAccessKey delegate:self];
    
    if (XGPush.defaultManager.xgApplicationBadgeNumber > 0) {
        [XGPush.defaultManager setXgApplicationBadgeNumber:0];
    }
    
    [XGPush.defaultManager reportXGNotificationInfo:self.launchOptions];
}

- (void)stopPushService{
    [XGPush.defaultManager stopXGNotification];
    
    [[WCRequestObject shared] post:@"AppUnBindXgToken" Param:@{@"Token":self.deviceToken?:@"",@"Platform":@"ios"} success:^(id responseObject) {
        
    } failure:^(NSString *reason, NSError *error) {
        
    }];
}

- (void)reportXGNotificationInfo:(nonnull NSDictionary *)info{
    [XGPush.defaultManager reportXGNotificationInfo:info];
}

- (void)bindPushToken
{
    if (self.deviceToken) {
        
        [[WCRequestObject shared] post:@"AppBindXgToken" Param:@{@"Token":self.deviceToken,@"Platform":@"ios"} success:^(id responseObject) {
            
        } failure:^(NSString *reason, NSError *error) {
            
        }];
    }
}

#pragma mark - XGPushDelegate

- (void)xgPushDidFinishStart:(BOOL)isSuccess error:(nullable NSError *)error{
    if (error) {
        WCLog(@"信鸽推送启动失败：%@",error);
    }
}

- (void)xgPushDidRegisteredDeviceToken:(nullable NSString *)deviceToken error:(nullable NSError *)error{
    //绑定信鸽
    self.deviceToken = deviceToken;
    WCLog(@"信鸽推送：%@",deviceToken);
}

// iOS 10 新增 API 无论APP当前在前台还是后台点击通知都会走该 API
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    
    [[XGPush defaultManager] reportXGNotificationResponse:response];
    completionHandler();
}

// App 在前台弹通知需要调用这个接口
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    [XGPush.defaultManager reportXGNotificationInfo:notification.request.content.userInfo];
    
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

 /// 统一收到通知消息的回调
//- (void)xgPushDidReceiveRemoteNotification:(id)notification withCompletionHandler:(void (^)(NSUInteger))completionHandler {
//
//    if (@available(iOS 10.0, *)) {
//        if ([notification isKindOfClass:[UNNotification class]]) {
//            [[XGPush defaultManager] reportXGNotificationInfo:((UNNotification *)notification).request.content.userInfo];
//            completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
//        }
//    } else {
//        [[XGPush defaultManager] reportXGNotificationInfo:(NSDictionary *)notification];
//        completionHandler(UIBackgroundFetchResultNewData);
//    }
//}


@end
