//
//  HXYNotice.m
//  zhipuzi
//
//  Created by 侯兴宇 on 2017/11/8.
//  Copyright © 2017年 迅享科技. All rights reserved.
//

#import "HXYNotice.h"

static NSString * const addActionDown        = @"addActionDown";
static NSString * const addLoginIn           = @"addLoginIn";
static NSString * const addLoginOut          = @"addLoginOut";
static NSString * const modifyUserInfo       = @"modifyUserInfo";
static NSString * const socektConnectSucess  = @"socektConnectSucess";
static NSString * const updateDeviceList     = @"updateDeviceList";
static NSString * const reportDevice         = @"reportDevice";
static NSString * const addActivePush        = @"ActivePush";
static NSString * const HeartBeatNoti        = @"HeartBeatNoti";
static NSString * const updateFamilyList     = @"updateFamilyList";
static NSString * const updateRoomList       = @"updateRoomList";
static NSString * const updateTimerList      = @"updateTimerList";
static NSString * const updateMemberList     = @"updateMemberList";
static NSString * const changeAddDeviceType  = @"changeAddDeviceType";
static NSString * const loginInTicketToken   = @"loginInTicketToken";
static NSString * const appEnterBackground   = @"appEnterBackground";
static NSString * const appEnterForeground   = @"appEnterForeground";

@implementation HXYNotice

+ (void)removeListener:(id)listener
{
    [[NSNotificationCenter defaultCenter] removeObserver:listener];
}

+ (void)addActionDownListener:(id)listener reaction:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:addActionDown object:nil];
}

+ (void)addActionDownPost
{
    [[NSNotificationCenter defaultCenter] postNotificationName:addActionDown object:nil];
}

//注册设备监听
+ (void)addActivePushListener:(id)listener reaction:(SEL)selector{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:addActivePush object:nil];

}

+ (void)addActivePushPost:(NSArray *)deviceIds {
    [[NSNotificationCenter defaultCenter] postNotificationName:addActivePush object:deviceIds];
}

//注册设备监听
+ (void)addHeartBeatListener:(id)listener reaction:(SEL)selector{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:HeartBeatNoti object:nil];

}

+ (void)postHeartBeat:(NSArray *)deviceIds {
    [[NSNotificationCenter defaultCenter] postNotificationName:HeartBeatNoti object:deviceIds];
}


//登录通知
+ (void)addLoginInListener:(id)listener reaction:(SEL)selector{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:addLoginIn object:nil];
}

+ (void)addLoginInPost{
    [[NSNotificationCenter defaultCenter] postNotificationName:addLoginIn object:nil];
}


//登出通知
+ (void)addLoginOutListener:(id)listener reaction:(SEL)selector{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:addLoginOut object:nil];
}

+ (void)addLoginOutPost{
    [[NSNotificationCenter defaultCenter] postNotificationName:addLoginOut object:nil];
}

//修改用户信息
+ (void)addModifyUserInfoListener:(id)listener reaction:(SEL)selector{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:modifyUserInfo object:nil];
}

+ (void)addModifyUserInfoPost{
    [[NSNotificationCenter defaultCenter] postNotificationName:modifyUserInfo object:nil];
}


//websocket连接成功
+ (void)addSocketConnectSucessListener:(id)listener reaction:(SEL)selector{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:socektConnectSucess object:nil];
}

+ (void)addSocketConnectSucessPost{
    [[NSNotificationCenter defaultCenter] postNotificationName:socektConnectSucess object:nil];
}

//更新首页设备列表
+ (void)addUpdateDeviceListListener:(id)listener reaction:(SEL)selector{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:updateDeviceList object:nil];
}

+ (void)addUpdateDeviceListPost{
    [[NSNotificationCenter defaultCenter] postNotificationName:updateDeviceList object:nil];
}


//设备上报通知
+ (void)addReportDeviceListener:(id)listener reaction:(SEL)selector{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:reportDevice object:nil];
}

+ (void)addReportDevicePost:(NSDictionary *)dic{
    [[NSNotificationCenter defaultCenter] postNotificationName:reportDevice object:nil userInfo:dic];
}


//家庭列表更新
+ (void)addUpdateFamilyListListener:(id)listener reaction:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:updateFamilyList object:nil];
}

+ (void)addUpdateFamilyListPost
{
    [[NSNotificationCenter defaultCenter] postNotificationName:updateFamilyList object:nil];
}


//房间列表更新
+ (void)addUpdateRoomListListener:(id)listener reaction:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:updateRoomList object:nil];
}
+ (void)addUpdateRoomListPost
{
    [[NSNotificationCenter defaultCenter] postNotificationName:updateRoomList object:nil];
}


//定时列表更新
+ (void)addUpdateTimerListListener:(id)listener reaction:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:updateTimerList object:nil];
}

+ (void)addUpdateTimerListPost
{
    [[NSNotificationCenter defaultCenter] postNotificationName:updateTimerList object:nil];
}


//成员更新
+ (void)addUpdateMemberListListener:(id)listener reaction:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:updateMemberList object:nil];
}

+ (void)postUpdateMemberList
{
    [[NSNotificationCenter defaultCenter] postNotificationName:updateMemberList object:nil];
}


//切换配网方式
+ (void)changeAddDeviceTypeListener:(id)listener reaction:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:changeAddDeviceType object:nil];
}

+ (void)postChangeAddDeviceType:(NSInteger)deviceType
{
    [[NSNotificationCenter defaultCenter] postNotificationName:changeAddDeviceType object:@(deviceType)];
}

//重新登录获取ticketToken
+ (void)addLoginInTicketTokenListener:(id)listener reaction:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:loginInTicketToken object:nil];
}

+ (void)postLoginInTicketToken:(NSString *)ticketToken
{
    [[NSNotificationCenter defaultCenter] postNotificationName:loginInTicketToken object:ticketToken];
}

//APP进入后台
+ (void)addAPPEnterBackgroundLister:(id)listener reaction:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:appEnterBackground object:nil];
}

+ (void)postAPPEnterBackground {
    [[NSNotificationCenter defaultCenter] postNotificationName:appEnterBackground object:nil];
}

//APP进入前台
+ (void)addAPPEnterForegroundLister:(id)listener reaction:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:selector name:appEnterForeground object:nil];
}

+ (void)postAPPEnterForeground {
    [[NSNotificationCenter defaultCenter] postNotificationName:appEnterForeground object:nil];
}

@end
