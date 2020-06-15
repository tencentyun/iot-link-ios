//
//  QCDeviceManager.h
//  QCAccount
//
//  Created by Wp on 2019/12/6.
//  Copyright © 2019 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCParts.h"


@interface DeviceInfo : NSObject

@property (nonatomic,copy) NSString *theme;
@property (nonatomic,copy) NSDictionary *navBar;
@property (nonatomic,assign) BOOL timingProject;

@property (nonatomic,copy) NSMutableArray *zipData;

@end


@interface QCDeviceSet : NSObject


+ (instancetype)shared;


#pragma mark - 设备相关


/// 收到设备发生改变的数据
@property (nonatomic,strong) void (^deviceChange)(NSDictionary *changeInfo);

/// 注册设备监听（调用成功后才能收到deviceChange）
- (void)activePushWithDeviceIds:(NSArray *)deviceIds complete:(Result)result;

/// 获取设备列表
/// @param offset 非必传（忽略时传0），所需要查询的数据的偏移量
/// @param limit 非必传（忽略时传0），所需要查询的总限制量，最大返回 50 条
- (void)getDeviceListWithFamilyId:(NSString *)familyId roomId:(NSString *)roomId offset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure;

/// 获取产品配置
- (void)getProductsConfigWithProductIds:(NSArray *)productIds success:(SRHandler)success failure:(FRHandler)failure;

/// 获取产品信息
- (void)getProductsWithProductIds:(NSArray *)productIds success:(SRHandler)success failure:(FRHandler)failure;

/// 获取设备数据
- (void)getDeviceDataWithProductId:(NSString *)productId deviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure;

/// 获取产品配置+产品信息+设备数据（前面三个接口组合）
- (void)getDeviceDetailWithProductId:(NSString *)productId deviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure;


/// 下发控制数据
/// @param data 需要下发的数据
- (void)controlDeviceDataWithProductId:(NSString *)productId deviceName:(NSString *)deviceName data:(NSDictionary *)data success:(SRHandler)success failure:(FRHandler)failure;

/// 修改设备别名
/// @param aliasName 别名
- (void)modifyAliasName:(NSString *)aliasName ByProductId:(NSString *)productId andDeviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure;

/// 解绑设备
/// @param productId 产品id
/// @param deviceName 设备名
- (void)deleteDeviceWithFamilyId:(NSString *)familyId productId:(NSString *)productId andDeviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure;

/// 动态签名绑定设备
/// @param signatureInfo 配网成功产生的信息集合
/// @param familyId 家庭id
/// @param roomId 非必传（忽略时传@""）,房间id
- (void)bindDeviceWithSignatureInfo:(NSString *)signatureInfo inFamilyId:(NSString *)familyId roomId:(NSString *)roomId success:(SRHandler)success failure:(FRHandler)failure;

/// 设备签名绑定设备（一般用于扫描二维码绑定设备）
/// @param deviceSignature 设备签名
/// @param familyId 家庭id
/// @param roomId 非必传（忽略时传@""）,房间id
- (void)bindDeviceWithDeviceSignature:(NSString *)deviceSignature inFamilyId:(NSString *)familyId roomId:(NSString *)roomId success:(SRHandler)success failure:(FRHandler)failure;

/// 更换设备绑定的房间
- (void)modifyRoomOfDeviceWithProductId:(NSString *)productId deviceName:(NSString *)deviceName familyId:(NSString *)familyId roomId:(NSString *)roomId success:(SRHandler)success failure:(FRHandler)failure;


#pragma mark - 云端定时


/// 获取定时器列表
- (void)getTimerListWithProductId:(NSString *)productId deviceName:(NSString *)deviceName offset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure;

/// 创建定时器
/// @param productId 新建定时任务所属产品 Id
/// @param deviceName 新建定时任务控制的设备名称
/// @param timerName 定时器名
/// @param days 如"1000000", // 每一位 0:关闭,1:开启, 从左至右依次表示: 周日 周一 周二 周三 周四 周五 周六
/// @param timePoint 定时器开启时间点，如7：30
/// @param repeat 是否循环，0表示不需要，1表示需要
/// @param data 定时器启动时下发的数据
- (void)createTimerWithProductId:(NSString *)productId deviceName:(NSString *)deviceName timerName:(NSString *)timerName days:(NSString *)days timePoint:(NSDate *)timePoint repeat:(NSUInteger)repeat data:(NSDictionary *)data success:(SRHandler)success failure:(FRHandler)failure;

/// 修改定时器
/// @param timerId 需修改的定时器 Id
/// @param productId 定时任务所属产品 Id
/// @param deviceName 定时任务控制的设备名称
/// @param timerName 定时器名
/// @param days 如"1000000", // 每一位 0:关闭,1:开启, 从左至右依次表示: 周日 周一 周二 周三 周四 周五 周六
/// @param timePoint 定时器开启时间点，如7：30
/// @param repeat 是否循环，0表示不需要，1表示需要
/// @param data 定时器启动时下发的数据
- (void)modifyTimerWithTimerId:(NSString *)timerId productId:(NSString *)productId deviceName:(NSString *)deviceName timerName:(NSString *)timerName days:(NSString *)days timePoint:(NSDate *)timePoint repeat:(NSUInteger)repeat data:(NSDictionary *)data success:(SRHandler)success failure:(FRHandler)failure;

/// 修改定时器开关状态
/// @param timerId 需修改的定时器 Id
/// @param productId 定时任务所属产品 Id
/// @param deviceName 定时任务控制的设备名称
/// @param status 开关状态
- (void)modifyTimerStatusWithTimerId:(NSString *)timerId productId:(NSString *)productId deviceName:(NSString *)deviceName status:(BOOL)status success:(SRHandler)success failure:(FRHandler)failure;

/// 删除定时器
- (void)deleteTimerWithProductId:(NSString *)productId deviceName:(NSString *)deviceName timerId:(NSString *)timerId success:(SRHandler)success failure:(FRHandler)failure;


#pragma mark - 设备分享


/// 获取某分享设备的用户列表
- (void)getUserListForDeviceWithProductId:(NSString *)productId deviceName:(NSString *)deviceName offset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure;

/// 获取某用户的分享设备列表
- (void)getDeviceListForUserWithOffset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure;

/// 移除共享设备的用户
/// @param userID 需移除的用户id
- (void)removeShareDeviceUserWithProductId:(NSString *)productId deviceName:(NSString *)deviceName userID:(NSString *)userID success:(SRHandler)success failure:(FRHandler)failure;

/// 移除用户分享的设备
/// @param shareDeviceToken 设备分享token
- (void)removeUserShareDeviceWithProductId:(NSString *)productId deviceName:(NSString *)deviceName shareDeviceToken:(NSString *)shareDeviceToken success:(SRHandler)success failure:(FRHandler)failure;

/// 绑定用户分享的设备
- (void)bindUserShareDeviceWithProductId:(NSString *)productId deviceName:(NSString *)deviceName shareDeviceToken:(NSString *)shareDeviceToken success:(SRHandler)success failure:(FRHandler)failure;

/// 发送设备分享邀请（手机号账户）
- (void)sendInvitationToPhoneNum:(NSString *)phoneNum withCountryCode:(NSString *)countryCode familyId:(NSString *)familyId productId:(NSString *)productId deviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure;

/// 发送设备分享邀请（邮箱账户）
- (void)sendInvitationToEmail:(NSString *)email withFamilyId:(NSString *)familyId productId:(NSString *)productId deviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure;

@end
