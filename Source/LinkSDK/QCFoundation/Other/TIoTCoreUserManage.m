//
//  WCUserManage.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "QCUserManage.h"
#import "NSString+Extension.h"

@implementation QCUserManage
@synthesize accessToken = _accessToken;
@synthesize expireAt = _expireAt;
@synthesize userId = _userId;
@synthesize avatar = _avatar;
@synthesize nickName = _nickName;
@synthesize phoneNumber = _phoneNumber;

+(instancetype)shared{
    static QCUserManage *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

#pragma mark - getter & setter

- (BOOL)isValidToken
{
    if (self.accessToken && self.expireAt) {
        if (self.accessToken.length > 0 && [self.expireAt integerValue] > [[NSString getNowTimeString] integerValue]) {
            return  YES;
        }
    }
    
    return NO;
}

- (NSString *)accessToken
{
    if (!_accessToken) {
        _accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"acsToken"];
    }
    return _accessToken;
}

- (void)setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    if (accessToken == nil || [accessToken isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"acsToken"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:@"acsToken"];
    }
    
}

- (NSString *)expireAt
{
    if (!_expireAt) {
        _expireAt = [[NSUserDefaults standardUserDefaults] valueForKey:@"expire_At"];
    }
    return _expireAt;
}

- (void)setExpireAt:(NSString *)expireAt
{
    _expireAt = expireAt;
    [[NSUserDefaults standardUserDefaults] setValue:expireAt forKey:@"expire_At"];
}

- (NSString *)userId
{
    if (!_userId) {
        _userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"u_id"];
    }
    return _userId;
}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:@"u_id"];
}

- (NSString *)avatar
{
    if (!_avatar) {
        _avatar = [[NSUserDefaults standardUserDefaults] valueForKey:@"ava_tar"];
    }
    return _avatar;
}

- (void)setAvatar:(NSString *)avatar
{
    _avatar = avatar;
    [[NSUserDefaults standardUserDefaults] setValue:avatar forKey:@"ava_tar"];
}

- (NSString *)nickName
{
    if (!_nickName) {
        _nickName = [[NSUserDefaults standardUserDefaults] valueForKey:@"nick_name"];
    }
    return _nickName;
}

- (void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
    [[NSUserDefaults standardUserDefaults] setValue:nickName forKey:@"nick_name"];
}

- (NSString *)phoneNumber
{
    if (!_phoneNumber) {
        _phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"phone_number"];
    }
    return _phoneNumber;
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    _phoneNumber = phoneNumber;
    [[NSUserDefaults standardUserDefaults] setValue:phoneNumber forKey:@"phone_number"];
}



//保存accessToken
- (void)saveAccessToken:(NSString *)accessToken expireAt:(NSString *)expireAt{
    self.accessToken = [NSString stringWithFormat:@"%@",accessToken];
    self.expireAt = [NSString stringWithFormat:@"%@",expireAt];
}

//保存用户信息
- (void)saveUserInfo:(NSDictionary *)userInfo{
    
    if (userInfo[@"UserID"]) {
        self.userId = userInfo[@"UserID"];
    }
    if (userInfo[@"Avatar"]) {
        self.avatar = userInfo[@"Avatar"];
    }
    if (userInfo[@"NickName"]) {
        self.nickName = userInfo[@"NickName"];
    }
    if (userInfo[@"PhoneNumber"]) {
        self.phoneNumber = userInfo[@"PhoneNumber"];
    }
}


- (void)clear{
    self.accessToken = @"";
    self.userId = @"";
    self.nickName = @"";
    self.avatar = @"";
    self.phoneNumber = @"";
    self.expireAt = @"";
}

@end
