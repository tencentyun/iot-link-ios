//
//  WCUserManage.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTCoreUserManage.h"
#import "NSString+Extension.h"

@implementation TIoTCoreUserManage
@synthesize accessToken = _accessToken;
@synthesize expireAt = _expireAt;
@synthesize userId = _userId;
@synthesize avatar = _avatar;
@synthesize nickName = _nickName;
@synthesize phoneNumber = _phoneNumber;

@synthesize countryCode = _countryCode;
@synthesize email = _email;
@synthesize hasPassword = _hasPassword;
@synthesize WxOpenID = _WxOpenID;
@synthesize requestID = _requestID;

+(instancetype)shared{
    static TIoTCoreUserManage *_instance = nil;
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
    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (NSString *)countryCode {
    if (!_countryCode) {
        _countryCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"country_Code"];
    }
    return _countryCode;
}

- (void)setCountryCode:(NSString *)countryCode {
    _countryCode = countryCode;
    [[NSUserDefaults standardUserDefaults] setValue:countryCode forKey:@"country_Code"];
}

- (NSString *)email {
    if (!_email) {
        _email = [[NSUserDefaults standardUserDefaults] valueForKey:@"email_"];
    }
    return _email;
}

- (void)setEmail:(NSString *)email {
    _email = email;
    [[NSUserDefaults standardUserDefaults] setValue:email forKey:@"email_"];
}

- (NSString *)WxOpenID {
    if (!_WxOpenID) {
        _WxOpenID = [[NSUserDefaults standardUserDefaults] valueForKey:@"WxOpen_ID"];
    }
    return _WxOpenID;
}

- (void)setWxOpenID:(NSString *)WxOpenID {
    _WxOpenID = WxOpenID;
    [[NSUserDefaults standardUserDefaults] setValue:WxOpenID forKey:@"WxOpen_ID"];
}

- (NSString *)hasPassword {
    if (!_hasPassword) {
        _hasPassword = [[NSUserDefaults standardUserDefaults] valueForKey:@"has_Password"];
    }
    return _hasPassword;
}

- (void)setHasPassword:(NSString *)hasPassword {
    _hasPassword = hasPassword;
    [[NSUserDefaults standardUserDefaults] setValue:hasPassword forKey:@"has_Password"];
}

- (NSString *)requestID {
    if (!_requestID) {
        _requestID = [[NSUserDefaults standardUserDefaults] valueForKey:@"request_ID"];
    }
    return _requestID;
}

- (void)setRequestID:(NSString *)requestID {
    _requestID = requestID;
    [[NSUserDefaults standardUserDefaults] setValue:requestID forKey:@"request_ID"];
}

//保存accessToken
- (void)saveAccessToken:(NSString *)accessToken expireAt:(NSString *)expireAt{
    self.accessToken = [NSString stringWithFormat:@"%@",accessToken];
    self.expireAt = [NSString stringWithFormat:@"%@",expireAt];
}

-(NSString *)hasBindWxOpenID {
    if (!_hasBindWxOpenID) {
        _hasBindWxOpenID = [[NSUserDefaults standardUserDefaults] valueForKey:@"Has_WxOpenID"];
    }
    return _hasBindWxOpenID;
}

- (void)setHasWxOpenID:(NSString *)hasBindWxOpenID {
    _hasBindWxOpenID = hasBindWxOpenID;
    [[NSUserDefaults standardUserDefaults] setValue:hasBindWxOpenID forKey:@"Has_WxOpenID"];
}

//@property (nonatomic, copy, nullable) NSString *RegionId;           // 22 美东  1 国内
//@property (nonatomic, copy, nullable) NSString *region;             // 美东 na-ashburn 国内 ap-guangzhou

- (NSString *)userRegionId {
    if (!_userRegionId) {
        _userRegionId = [[NSUserDefaults standardUserDefaults] valueForKey:@"Region_Id"];
    }
    return _userRegionId;
}

- (void)setRegionId:(NSString *)RegionId {
    _userRegionId = RegionId;
    [[NSUserDefaults standardUserDefaults] setValue:RegionId forKey:@"Region_Id"];
}

- (NSString *)userRegion {
    if (!_userRegion) {
        _userRegion = [[NSUserDefaults standardUserDefaults] valueForKey:@"region"];
    }
    return _userRegion;
}

- (void)setRegion:(NSString *)region {
    _userRegion = region;
    [[NSUserDefaults standardUserDefaults] setValue:region forKey:@"region"];
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
    if (userInfo[@"Email"]) {
        self.email = userInfo[@"Email"];
    }
    if (userInfo[@"HasPassword"]) {
        self.hasPassword = [NSString stringWithFormat:@"%@",userInfo[@"HasPassword"]];
    }
    if (userInfo[@"CountryCode"]) {
        self.countryCode = userInfo[@"CountryCode"];
    }
    if (userInfo[@"WxOpenID"]) {
        self.WxOpenID = userInfo[@"WxOpenID"];
    }
    if (userInfo[@"RequestId"]) {
        self.requestID = userInfo[@"RequestId"];
    }
    if (userInfo[@"Openid"]) {
        self.WxOpenID = userInfo[@"Openid"];
    }
    if (userInfo[@"HasWxOpenID"]) {
        self.hasWxOpenID = [NSString stringWithFormat:@"%@",userInfo[@"HasWxOpenID"]];
    }
    if (userInfo[@"RegionID"]) {
        self.userRegionId = [NSString stringWithFormat:@"%@",userInfo[@"RegionID"]];
    }
    if (userInfo[@"Region"]) {
        self.userRegion = userInfo[@"Region"];
    }
}


- (void)clear{
    self.accessToken = @"";
    self.userId = @"";
    self.nickName = @"";
    self.avatar = @"";
    self.phoneNumber = @"";
    self.expireAt = @"";
    self.countryCode = @"";
    self.email = @"";
    self.hasPassword = @"";
    self.WxOpenID = @"";
    self.requestID = @"";
    self.hasBindWxOpenID = @"";
    self.userRegionId = @"";
    self.userRegion = @"";
}


//@synthesize countryCode = _countryCode;
//@synthesize email = _email;
//@synthesize hasPassword = _hasPassword;
//@synthesize WxOpenID = _WxOpenID;
@end
