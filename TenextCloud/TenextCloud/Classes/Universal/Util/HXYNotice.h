//
//  HXYNotice.h
//  zhipuzi
//
//  Created by 侯兴宇 on 2017/11/8.
//  Copyright © 2017年 迅享科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXYNotice : NSObject

+ (void)removeListener:(id)listener;

//添加动作完成之后通知
+ (void)addActionDownListener:(id)listener reaction:(SEL)selector;
+ (void)addActionDownPost;

//注册设备监听
+ (void)addActivePushListener:(id)listener reaction:(SEL)selector;
+ (void)addActivePushPost:(NSArray *)deviceIds;

//登录通知
+ (void)addLoginInListener:(id)listener reaction:(SEL)selector;
+ (void)addLoginInPost;


//登出通知
+ (void)addLoginOutListener:(id)listener reaction:(SEL)selector;
+ (void)addLoginOutPost;


//修改用户信息
+ (void)addModifyUserInfoListener:(id)listener reaction:(SEL)selector;
+ (void)addModifyUserInfoPost;


//websocket连接成功
+ (void)addSocketConnectSucessListener:(id)listener reaction:(SEL)selector;
+ (void)addSocketConnectSucessPost;

//开启心跳通知
+ (void)addHeartBeatListener:(id)listener reaction:(SEL)selector;
+ (void)postHeartBeat:(NSArray *)deviceIds;


//更新首页设备列表
+ (void)addUpdateDeviceListListener:(id)listener reaction:(SEL)selector;
+ (void)addUpdateDeviceListPost;


//设备上报通知
+ (void)addReportDeviceListener:(id)listener reaction:(SEL)selector;
+ (void)addReportDevicePost:(NSDictionary *)dic;



//家庭列表更新
+ (void)addUpdateFamilyListListener:(id)listener reaction:(SEL)selector;
+ (void)addUpdateFamilyListPost;


//房间列表更新
+ (void)addUpdateRoomListListener:(id)listener reaction:(SEL)selector;
+ (void)addUpdateRoomListPost;


//定时列表更新
+ (void)addUpdateTimerListListener:(id)listener reaction:(SEL)selector;
+ (void)addUpdateTimerListPost;

//成员更新
+ (void)addUpdateMemberListListener:(id)listener reaction:(SEL)selector;
+ (void)postUpdateMemberList;
@end
