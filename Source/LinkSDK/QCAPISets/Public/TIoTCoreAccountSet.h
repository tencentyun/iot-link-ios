//
//  QCAccountManager.h
//  QCAccount
//
//  Created by Wp on 2019/12/4.
//  Copyright © 2019 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCParts.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCAccountSet : NSObject

+ (instancetype)shared;

#pragma mark - 邮箱注册

/// 发送验证码到邮箱（用于邮箱注册）
- (void)sendVerificationCodeWithEmail:(NSString *)email success:(SRHandler)success failure:(FRHandler)failure;

/// 校验验证码（用于邮箱注册）
/// @param code 验证码
- (void)checkVerificationCodeWithEmail:(NSString *)email code:(NSString *)code success:(SRHandler)success failure:(FRHandler)failure;

/// 邮箱注册
- (void)createEmailUserWithEmail:(NSString *)email verificationCode:(NSString *)code password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;


#pragma mark - 手机号注册

/// 发送验证码（用于手机号注册）
/// @param countryCode 国际区号，如中国大陆区号为86
- (void)sendVerificationCodeWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber success:(SRHandler)success failure:(FRHandler)failure;

/// 检验验证码（用于手机号注册）
- (void)checkVerificationCodeWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode success:(SRHandler)success failure:(FRHandler)failure;

/// 手机号注册
/// @param countryCode 国际区号，如中国大陆区号为86
- (void)createPhoneUserWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;


#pragma mark - 登录登出

/// 手机号登录
/// @param countryCode 国际区号，如中国大陆区号为86
- (void)signInWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;

/// 邮箱登录
- (void)signInWithEmail:(NSString *)email password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;

/// 微信登录
/// @param code 同意微信授权返回的code
- (void)signInByWechatWithCode:(NSString *)code Success:(SRHandler)success failure:(FRHandler)failure;

/// 登出
- (void)signOutOnSuccess:(SRHandler)success failure:(FRHandler)failure;

#pragma mark - 邮箱重置密码

/// 发送验证码（重置密码--邮箱方式）
- (void)sendCodeForResetWithEmail:(NSString *)email success:(SRHandler)success failure:(FRHandler)failure;

/// 检验验证码（重置密码--邮箱方式）
- (void)checkCodeForResetWithEmail:(NSString *)email code:(NSString *)code success:(SRHandler)success failure:(FRHandler)failure;

/// 重置密码（邮箱方式）
- (void)resetPasswordByEmail:(NSString *)email verificationCode:(NSString *)code password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;


#pragma mark - 手机号重置密码

/// 发送验证码（重置密码--手机号方式）
/// @param countryCode 国际区号，如中国大陆区号为86
- (void)sendCodeForResetWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber success:(SRHandler)success failure:(FRHandler)failure;

/// 检验验证码（重置密码--手机号方式）
- (void)checkCodeForResetWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode success:(SRHandler)success failure:(FRHandler)failure;

/// 重置密码（手机号方式）
/// @param countryCode 国际区号，如中国大陆区号为86
- (void)ResetPasswordWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;


#pragma mark - 修改密码

/// 修改密码
/// @param currentPassword 目前的密码
/// @param newPassword 新密码
- (void)modifyPasswordWithCurrentPassword:(NSString *)currentPassword newPassword:(NSString *)newPassword success:(SRHandler)success failure:(FRHandler)failure;


#pragma mark - 绑定手机号

/// 发送验证码（绑定手机号）
/// @param countryCode 国际区号，如中国大陆区号为86
- (void)sendCodeForBindWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber success:(SRHandler)success failure:(FRHandler)failure;

/// 绑定手机号
- (void)bindPhoneNumberWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode success:(SRHandler)success failure:(FRHandler)failure;


#pragma mark - 用户信息

/// 获取用户信息
- (void)getUserInfoOnSuccess:(SRHandler)success failure:(FRHandler)failure;

/// 获取上传cos的必要参数的必要参数
- (void)getUploadInfoOnSuccess:(SRHandler)success failure:(FRHandler)failure;

/// 修改用户信息
/// @param nickName 昵称(不修改时传@"")
/// @param avatar 头像(不修改时传@"")
- (void)updateUserWithNickName:(NSString *)nickName avatar:(NSString *)avatar success:(SRHandler)success failure:(FRHandler)failure;


#pragma mark - 意见反馈

/// 意见反馈
/// @param text 反馈文本内容
/// @param contact 联系方式（不填时传@""）
/// @param urls 图片地址
- (void)setFeedbackWithText:(NSString *)text contact:(NSString *)contact imageURLs:(NSArray<NSString *> *)urls success:(SRHandler)success failure:(FRHandler)failure;

@end

NS_ASSUME_NONNULL_END
