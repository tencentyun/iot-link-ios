//
//  WCUserManage.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTCoreUserManage.h"
#import "NSString+Extension.h"
#import "NSObject+additions.h"

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
@synthesize hasBindWxOpenID = _hasBindWxOpenID;
@synthesize userRegionId = _userRegionId;
@synthesize userRegion = _userRegion;
@synthesize countryTitle = _countryTitle;
@synthesize countryTitleEN = _countryTitleEN;

@synthesize signIn_countryCode = _signIn_countryCode;
@synthesize signIn_Title = _signIn_Title;
@synthesize signIn_Phone_Numner = _signIn_Phone_Numner;
//@synthesize signIn_Email_countryCode = _signIn_Email_countryCode;
//@synthesize signIn_Email_Title = _signIn_Email_Title;
@synthesize signIn_Email_Address = _signIn_Email_Address;

@synthesize login_CountryCode = _login_CountryCode;
@synthesize login_Title = _login_Title;
@synthesize login_Code_Text = _login_Code_Text;
//@synthesize login_PhoneEmail_CountryCode = _login_PhoneEmail_CountryCode;
//@synthesize login_PhoneEmail_Title = _login_PhoneEmail_Title;
//@synthesize login_PhoneEmail_Text = _login_PhoneEmail_Text;

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
    
    if ([NSString isNullOrNilWithObject:_userRegionId]) {
        _userRegionId = @"1";
    }
    return _userRegionId;
}

- (void)setUserRegionId:(NSString *)userRegionId {
    _userRegionId = userRegionId;
    [[NSUserDefaults standardUserDefaults] setValue:userRegionId forKey:@"Region_Id"];
}

- (NSString *)userRegion {
    if (!_userRegion) {
        _userRegion = [[NSUserDefaults standardUserDefaults] valueForKey:@"region"];
    }
    if ([NSString isNullOrNilWithObject:_userRegion]) {
        _userRegion = @"ap-guangzhou";
    }
    return _userRegion;
}

- (void)setUserRegion:(NSString *)userRegion {
    _userRegion = userRegion;
    [[NSUserDefaults standardUserDefaults] setValue:userRegion forKey:@"region"];
}

- (NSString *)countryTitle {
    if (!_countryTitle) {
        _countryTitle = [[NSUserDefaults standardUserDefaults] valueForKey:@"country_Title"];
    }
    if ([NSString isNullOrNilWithObject:_countryTitle]) {
        _countryTitle = NSLocalizedString(@"china_main_land", @"中国大陆");
    }
    return _countryTitle;
}

- (void)setCountryTitle:(NSString *)countryTitle {
    _countryTitle = countryTitle;
    [[NSUserDefaults standardUserDefaults] setValue:countryTitle forKey:@"country_Title"];
}

- (NSString *)countryTitleEN {
    if (!_countryTitleEN) {
        _countryTitleEN = [[NSUserDefaults standardUserDefaults] valueForKey:@"country_TitleEN"];
    }
    if ([NSString isNullOrNilWithObject:_countryTitleEN]) {
        _countryTitleEN = @"Chinese Mainland";
    }
    return _countryTitleEN;
}

- (void)setCountryTitleEN:(NSString *)countryTitleEN {
    _countryTitleEN = countryTitleEN;
    [[NSUserDefaults standardUserDefaults] setValue:countryTitleEN forKey:@"country_TitleEN"];
}

#pragma mark - 注册页面用户操作保存项
- (NSString *)signIn_countryCode {
    if (!_signIn_countryCode) {
        _signIn_countryCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"signIn_countryCode"];
    }
    return _signIn_countryCode;
}

- (void)setsignIn_countryCode:(NSString *)signIn_countryCode {
    _signIn_countryCode = signIn_countryCode;
    [[NSUserDefaults standardUserDefaults] setValue:signIn_countryCode forKey:@"signIn_countryCode"];
}

- (NSString *)signIn_Title {
    if (!_signIn_Title) {
        _signIn_Title = [[NSUserDefaults standardUserDefaults] valueForKey:@"signIn_Title"];
    }
    return _signIn_Title;
}

- (void)setsignIn_Title:(NSString *)signIn_Title {
    _signIn_Title = signIn_Title;
    [[NSUserDefaults standardUserDefaults] setValue:signIn_Title forKey:@"signIn_Title"];
}

- (NSString *)signIn_Phone_Numner {
    if (!_signIn_Phone_Numner) {
        _signIn_Phone_Numner = [[NSUserDefaults standardUserDefaults] valueForKey:@"signIn_Phone_Numner"];
    }
    return _signIn_Phone_Numner;
}

- (void)setSignIn_Phone_Numner:(NSString *)signIn_Phone_Numner {
    _signIn_Phone_Numner = signIn_Phone_Numner;
    [[NSUserDefaults standardUserDefaults] setValue:signIn_Phone_Numner forKey:@"signIn_Phone_Numner"];
}

//- (NSString *)signIn_Email_countryCode {
//    if (!_signIn_Email_countryCode) {
//        _signIn_Email_countryCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"signIn_Email_countryCode"];
//    }
//    return _signIn_Email_countryCode;
//}
//
//- (void)setsignIn_Email_countryCode:(NSString *)signIn_Email_countryCode {
//    _signIn_Email_countryCode = signIn_Email_countryCode;
//    [[NSUserDefaults standardUserDefaults] setValue:signIn_Email_countryCode forKey:@"signIn_Email_countryCode"];
//}
//
//- (NSString *)signIn_Email_Title {
//    if (!_signIn_Email_Title) {
//        _signIn_Email_Title = [[NSUserDefaults standardUserDefaults] valueForKey:@"signIn_Email_Title"];
//    }
//    return _signIn_Email_Title;
//}
//
//- (void)setSignIn_Email_Title:(NSString *)signIn_Email_Title {
//    _signIn_Email_Title = signIn_Email_Title;
//    [[NSUserDefaults standardUserDefaults] setValue:signIn_Email_Title forKey:@"signIn_Email_Title"];
//}

- (NSString *)signIn_Email_Address {
    if (!_signIn_Email_Address) {
        _signIn_Email_Address = [[NSUserDefaults standardUserDefaults] valueForKey:@"signIn_Email_Address"];
    }
    return _signIn_Email_Address;
}

- (void)setSignIn_Email_Address:(NSString *)signIn_Email_Address {
    _signIn_Email_Address = signIn_Email_Address;
    [[NSUserDefaults standardUserDefaults] setValue:signIn_Email_Address forKey:@"signIn_Email_Address"];
}

#pragma mark - 登录页 用户操作保存项
- (NSString *)login_CountryCode {
    if (!_login_CountryCode) {
        _login_CountryCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"login_CountryCode"];
    }
    return _login_CountryCode;
}

- (void)setlogin_CountryCode:(NSString *)login_CountryCode {
    _login_CountryCode = login_CountryCode;
    [[NSUserDefaults standardUserDefaults] setValue:login_CountryCode forKey:@"login_CountryCode"];
}

- (NSString *)login_Title {
    if (!_login_Title) {
        _login_Title = [[NSUserDefaults standardUserDefaults] valueForKey:@"login_Title"];
    }
    return _login_Title;
}

- (void)setlogin_Title:(NSString *)login_Title {
    _login_Title = login_Title;
    [[NSUserDefaults standardUserDefaults] setValue:login_Title forKey:@"login_Title"];
}

- (NSString *)login_Code_Text {
    if (!_login_Code_Text) {
        _login_Code_Text = [[NSUserDefaults standardUserDefaults] valueForKey:@"login_Code_Text"];
    }
    return _login_Code_Text;
}

- (void)setlogin_Code_Text:(NSString *)login_Code_Text {
    _login_Code_Text = login_Code_Text;
    [[NSUserDefaults standardUserDefaults] setValue:login_Code_Text forKey:@"login_Code_Text"];
}

//- (NSString *)login_PhoneEmail_CountryCode {
//    if (!_login_PhoneEmail_CountryCode) {
//        _login_PhoneEmail_CountryCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"login_PhoneEmail_CountryCode"];
//    }
//    return _login_PhoneEmail_CountryCode;
//}
//
//- (void)setlogin_PhoneEmail_CountryCode:(NSString *)login_PhoneEmail_CountryCode {
//    _login_PhoneEmail_CountryCode = login_PhoneEmail_CountryCode;
//    [[NSUserDefaults standardUserDefaults] setValue:login_PhoneEmail_CountryCode forKey:@"login_PhoneEmail_CountryCode"];
//}
//
//- (NSString *)login_PhoneEmail_Title {
//    if (!_login_PhoneEmail_Title) {
//        _login_PhoneEmail_Title = [[NSUserDefaults standardUserDefaults] valueForKey:@"login_PhoneEmail_Title"];
//    }
//    return _login_PhoneEmail_Title;
//}
//
//- (void)setlogin_PhoneEmail_Title:(NSString *)login_PhoneEmail_Title {
//    _login_PhoneEmail_Title = login_PhoneEmail_Title;
//    [[NSUserDefaults standardUserDefaults] setValue:login_PhoneEmail_Title forKey:@"login_PhoneEmail_Title"];
//}

//- (NSString *)login_PhoneEmail_Text {
//    if (!_login_PhoneEmail_Text) {
//        _login_PhoneEmail_Text = [[NSUserDefaults standardUserDefaults] valueForKey:@"login_PhoneEmail_Text"];
//    }
//    return _login_PhoneEmail_Text;
//}
//
//- (void)setlogin_PhoneEmail_Text:(NSString *)login_PhoneEmail_Text {
//    _login_PhoneEmail_Text = login_PhoneEmail_Text;
//    [[NSUserDefaults standardUserDefaults] setValue:login_PhoneEmail_Text forKey:@"login_PhoneEmail_Text"];
//}

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
    if (userInfo[@"Title"]) {
        self.countryTitle = userInfo[@"Title"];
    }
    if (userInfo[@"TitleEN"]) {
        self.countryTitleEN = userInfo[@"TitleEN"];
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
    self.countryTitle = @"";
    self.countryTitleEN = @"";
}

- (void)signInClear {
    self.signIn_countryCode = @"";
    self.signIn_Title = @"";
    self.signIn_Phone_Numner = @"";
//    self.signIn_Email_countryCode = @"";
    self.signIn_Email_Address = @"";
//    self.signIn_Email_Title = @"";
}

//@synthesize countryCode = _countryCode;
//@synthesize email = _email;
//@synthesize hasPassword = _hasPassword;
//@synthesize WxOpenID = _WxOpenID;
@end
