//
//  WCRequestAction.h
//  TenextCloud
//
//  Created by Wp on 2019/12/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCRequestAction : NSObject


//MARK: 用户管理

FOUNDATION_EXPORT NSString *const AppFindUser;
FOUNDATION_EXPORT NSString *const AppSendVerificationCode;//短信验证码
FOUNDATION_EXPORT NSString *const AppCheckVerificationCode;//校验短信验证码
FOUNDATION_EXPORT NSString *const AppCreateCellphoneUser;//手机号注册
FOUNDATION_EXPORT NSString *const AppResetPasswordByCellphone;//手机号重置密码

FOUNDATION_EXPORT NSString *const AppSendEmailVerificationCode;//邮箱验证码
FOUNDATION_EXPORT NSString *const AppCheckEmailVerificationCode;//检验邮箱验证码
FOUNDATION_EXPORT NSString *const AppCreateEmailUser;//使用邮箱注册
FOUNDATION_EXPORT NSString *const AppResetPasswordByEmail;//邮箱重置密码

FOUNDATION_EXPORT NSString *const AppGetToken;//手机号邮箱登录
FOUNDATION_EXPORT NSString *const AppGetTokenByWeiXin;//微信登录

FOUNDATION_EXPORT NSString *const AppGetUser;//查询用户基本信息
FOUNDATION_EXPORT NSString *const AppUpdateUser;//修改用户基本信息
FOUNDATION_EXPORT NSString *const AppGetUserSetting;//查询用户设置信息
FOUNDATION_EXPORT NSString *const AppUpdateUserSetting;//修改用户设置信息
FOUNDATION_EXPORT NSString *const AppLogoutUser;//退出登录

FOUNDATION_EXPORT NSString *const AppUserResetPassword;//登录下修改密码

FOUNDATION_EXPORT NSString *const AppUserFeedBack;//用户意见反馈
FOUNDATION_EXPORT NSString *const AppCosAuth;//上传图片获取信息



//MARK: 消息

FOUNDATION_EXPORT NSString *const AppGetMessages;//查询消息列表
FOUNDATION_EXPORT NSString *const AppDeleteMessage;//用户删除消息
FOUNDATION_EXPORT NSString *const AppBindXgToken;//绑定推送token
FOUNDATION_EXPORT NSString *const AppUnBindXgToken;//解绑推送token


//MARK: 家庭管理

FOUNDATION_EXPORT NSString *const AppGetFamilyList;//家庭列表
FOUNDATION_EXPORT NSString *const AppCreateFamily;//新建家庭
FOUNDATION_EXPORT NSString *const AppDescribeFamily;//获取家庭详情
FOUNDATION_EXPORT NSString *const AppModifyFamily;//修改家庭
FOUNDATION_EXPORT NSString *const AppDeleteFamily;//删除家庭

FOUNDATION_EXPORT NSString *const AppCreateRoom;//新建房间
FOUNDATION_EXPORT NSString *const AppGetRoomList;//房间列表
FOUNDATION_EXPORT NSString *const AppModifyRoom;//修改房间
FOUNDATION_EXPORT NSString *const AppDeleteRoom;//删除房间

FOUNDATION_EXPORT NSString *const AppInviteMember;//邀请成员
FOUNDATION_EXPORT NSString *const AppDeleteFamilyMember;//管理员移除成员
FOUNDATION_EXPORT NSString *const AppJoinFamily;//成员申请加入
FOUNDATION_EXPORT NSString *const AppExitFamily;//成员主动退出
FOUNDATION_EXPORT NSString *const AppGetFamilyMemberList;//获取成员列表

FOUNDATION_EXPORT NSString *const AppSendShareFamilyInvite;//邀请家庭成员

//MARK: 设备管理

FOUNDATION_EXPORT NSString *const AppGetFamilyDeviceList;//获取设备列表
FOUNDATION_EXPORT NSString *const AppGetDeviceStatuses;//获取设备在线状态
FOUNDATION_EXPORT NSString *const AppSigBindDeviceInFamily;//wifi配网绑定设备
FOUNDATION_EXPORT NSString *const AppSecureAddDeviceInFamily;//扫码绑定设备
FOUNDATION_EXPORT NSString *const AppGetDeviceInFamily;//获取设备详情
FOUNDATION_EXPORT NSString *const AppGetDeviceData;//获取设备的模型数据
FOUNDATION_EXPORT NSString *const AppUpdateDeviceInFamily;//修改设备名称
FOUNDATION_EXPORT NSString *const AppControlDeviceData;//用户控制设备
FOUNDATION_EXPORT NSString *const AppDeleteDeviceInFamily;//用户移除设备

FOUNDATION_EXPORT NSString *const AppGetProductsConfig;//获取产品的界面配置
FOUNDATION_EXPORT NSString *const AppGetProducts;//获取产品属性
FOUNDATION_EXPORT NSString *const AppReportDeviceData;//虚拟设备上报

FOUNDATION_EXPORT NSString *const AppModifyFamilyDeviceRoom;//更换设备所属房间


//MARK: 设备定时

FOUNDATION_EXPORT NSString *const AppGetTimerList;//获取定时任务列表
FOUNDATION_EXPORT NSString *const AppCreateTimer;//新建定时任务
FOUNDATION_EXPORT NSString *const AppModifyTimerStatus;//修改定时器状态
FOUNDATION_EXPORT NSString *const AppModifyTimer;//修改定时器
FOUNDATION_EXPORT NSString *const AppDeleteTimer;//修改定时器

//MARK: 设备分享

FOUNDATION_EXPORT NSString *const AppSendShareDeviceInvite;//发送设备分享邀请
FOUNDATION_EXPORT NSString *const AppBindUserShareDevice;//绑定用户分享的设备
FOUNDATION_EXPORT NSString *const AppListUserShareDevices;//查询用户分享的设备列表
FOUNDATION_EXPORT NSString *const AppListShareDeviceUsers;//查询设备的用户列表
FOUNDATION_EXPORT NSString *const AppRemoveShareDeviceUser;//删除设备的用户
FOUNDATION_EXPORT NSString *const AppRemoveUserShareDevice;//删除用户的设备


@end

NS_ASSUME_NONNULL_END
