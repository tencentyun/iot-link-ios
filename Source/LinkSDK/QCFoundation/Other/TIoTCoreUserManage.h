//
//  WCUserManage.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreUserManage : NSObject

+(instancetype)shared;

@property (nonatomic) BOOL isValidToken;

@property (nonatomic, copy, nullable) NSString *accessToken;
@property (nonatomic, copy, nullable) NSString *expireAt;

@property (nonatomic, copy, nullable) NSString *userId;
@property (nonatomic, copy, nullable) NSString *avatar;
@property (nonatomic, copy, nullable) NSString *nickName;
@property (nonatomic, copy, nullable) NSString *phoneNumber;
@property (nonatomic, copy, nullable) NSString *countryCode;
@property (nonatomic, copy, nullable) NSString *email;
@property (nonatomic, copy, nullable) NSString *hasPassword;    //0 用户没有设置密码  1 用户已经设置密码
@property (nonatomic, copy, nullable) NSString *WxOpenID;
@property (nonatomic, copy, nullable) NSString *requestID;

@property (nonatomic,copy) NSString *familyId;//
@property (nonatomic,copy) NSString *currentRoomId;

//保存accessToken 和 有效期
- (void)saveAccessToken:(NSString *)accessToken expireAt:(NSString *)expireAt;

//保存用户信息
- (void)saveUserInfo:(NSDictionary *)userInfo;


- (void)clear;

@end

NS_ASSUME_NONNULL_END
