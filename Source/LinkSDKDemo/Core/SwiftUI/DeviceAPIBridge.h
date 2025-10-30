//
//  DeviceAPIBridge.h
//  LinkSDKDemo
//
//  设备API桥接类 - 用于 Swift 调用 OC 的设备相关逻辑
//  包含：设备绑定、设备列表获取等功能
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 设备绑定完成回调
typedef void(^DeviceBindingCompletion)(BOOL success, NSString * _Nullable message);

/// 设备列表获取完成回调
/// @param success 是否成功
/// @param deviceList 设备列表数组，每个元素是包含设备信息的字典
/// @param errorMessage 错误信息（失败时）
typedef void (^DeviceListCompletion)(BOOL success, NSArray<NSDictionary *> * _Nullable deviceList, NSString * _Nullable errorMessage);

/// 解绑设备完成回调
/// @param success 是否成功
/// @param errorMessage 错误信息（失败时）
typedef void (^UnbindDeviceCompletion)(BOOL success, NSString * _Nullable errorMessage);

/// 家庭列表获取完成回调
/// @param success 是否成功
/// @param familyList 家庭列表数组
/// @param errorMessage 错误信息（失败时）
typedef void (^FamilyListCompletion)(BOOL success, NSArray<NSDictionary *> * _Nullable familyList, NSString * _Nullable errorMessage);

/// 创建家庭完成回调
typedef void (^CreateFamilyCompletion)(BOOL success, NSString * _Nullable familyId, NSString * _Nullable errorMessage);

/// 房间列表获取完成回调
typedef void (^RoomListCompletion)(BOOL success, NSArray<NSDictionary *> * _Nullable roomList, NSString * _Nullable errorMessage);

@interface DeviceAPIBridge : NSObject

#pragma mark - 家庭管理

/// 获取家庭列表
/// @param completion 完成回调
+ (void)getFamilyListWithCompletion:(FamilyListCompletion)completion;

/// 创建家庭
/// @param familyName 家庭名称
/// @param address 家庭地址
/// @param completion 完成回调
+ (void)createFamilyWithName:(NSString *)familyName
                     address:(NSString *)address
                  completion:(CreateFamilyCompletion)completion;

#pragma mark - 房间管理

/// 获取房间列表
/// @param familyId 家庭ID
/// @param completion 完成回调
+ (void)getRoomListWithFamilyId:(NSString *)familyId
                     completion:(RoomListCompletion)completion;

#pragma mark - 设备绑定

/// 绑定设备（使用设备签名）
/// @param signature 设备签名
/// @param completion 完成回调
+ (void)bindDeviceWithSignature:(NSString *)signature completion:(DeviceBindingCompletion)completion;

#pragma mark - 设备列表

/// 获取设备列表
/// @param familyId 家庭ID
/// @param roomId 房间ID（可选，传 @"" 或 nil 表示获取所有房间的设备）
/// @param completion 完成回调
+ (void)getDeviceListWithFamilyId:(NSString *)familyId
                           roomId:(NSString * _Nullable)roomId
                       completion:(DeviceListCompletion)completion;

#pragma mark - 设备解绑

/// 解绑设备
/// @param familyId 家庭ID
/// @param productId 产品ID
/// @param deviceName 设备名称
/// @param completion 完成回调
+ (void)unbindDeviceWithFamilyId:(NSString *)familyId
                       productId:(NSString *)productId
                      deviceName:(NSString *)deviceName
                      completion:(UnbindDeviceCompletion)completion;

@end

NS_ASSUME_NONNULL_END
