//
//  QCFamilyManager.h
//  QCAccount
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCParts.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCFamilySet : NSObject

+ (instancetype)shared;

/// 获取家庭列表
/// @param offset 非必传（忽略时传0），所需要查询的数据的偏移量
/// @param limit 非必传（忽略时传0），所需要查询的总限制量，最大返回 50 条
- (void)getFamilyListWithOffset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure;

/// 创建家庭
/// @param name 家庭名
/// @param address 家庭地址
- (void)createFamilyWithName:(NSString *)name address:(NSString *)address success:(SRHandler)success failure:(FRHandler)failure;

/// 获取家庭详情
- (void)getFamilyInfoWithFamilyId:(NSString *)familyId success:(SRHandler)success failure:(FRHandler)failure;

/// 修改家庭信息
/// @param name 家庭名
- (void)modifyFamilyWithFamilyId:(NSString *)familyId name:(NSString *)name success:(SRHandler)success failure:(FRHandler)failure;

/// 删除家庭
- (void)deleteFamilyWithFamilyId:(NSString *)familyId name:(NSString *)name success:(SRHandler)success failure:(FRHandler)failure;

/// 成员主动退出家庭
- (void)leaveFamilyWithFamilyId:(NSString *)familyId success:(SRHandler)success failure:(FRHandler)failure;

/// 家主删除家庭成员
- (void)deleteFamilyMemberWithFamilyId:(NSString *)familyId memberId:(NSString *)memberId success:(SRHandler)success failure:(FRHandler)failure;

/// 获取家庭成员列表
/// @param offset 非必传，所需要查询的数据的偏移量
/// @param limit 非必传，所需要查询的总限制量，最大返回 50 条
- (void)getMemberListWithFamilyId:(NSString *)familyId offset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure;

/// 获取房间列表
/// @param offset 非必传，所需要查询的数据的偏移量
/// @param limit 非必传，所需要查询的总限制量，最大返回 50 条
- (void)getRoomListWithFamilyId:(NSString *)familyId offset:(NSUInteger)offset limit:(NSUInteger)limit  success:(SRHandler)success failure:(FRHandler)failure;

/// 创建房间
/// @param name 房间名
- (void)createRoomWithFamilyId:(NSString *)familyId name:(NSString *)name success:(SRHandler)success failure:(FRHandler)failure;

/// 删除房间
- (void)deleteRoomWithFamilyId:(NSString *)familyId roomId:(NSString *)roomId success:(SRHandler)success failure:(FRHandler)failure;

/// 修改房间信息
/// @param name 房间名
- (void)modifyRoomWithFamilyId:(NSString *)familyId roomId:(NSString *)roomId name:(NSString *)name success:(SRHandler)success failure:(FRHandler)failure;

/// 邀请家庭成员（手机号账户）
- (void)sendInvitationToPhoneNum:(NSString *)phoneNum withCountryCode:(NSString *)countryCode familyId:(NSString *)familyId success:(SRHandler)success failure:(FRHandler)failure;

/// 邀请家庭成员（邮箱账户）
- (void)sendInvitationToEmail:(NSString *)email withFamilyId:(NSString *)familyId success:(SRHandler)success failure:(FRHandler)failure;

/// 加入家庭
- (void)joinFamilyWithShareToken:(NSString *)shareToken success:(SRHandler)success failure:(FRHandler)failure;

@end

NS_ASSUME_NONNULL_END
