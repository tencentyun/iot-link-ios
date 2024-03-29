//
//  QCAccountManager.m
//  QCAccount
//
//

#import "TIoTCoreAccountSet.h"
#import "TIoTCoreRequestAction.h"
#import "TIoTCoreFoundation.h"
//#import <QCFoundation/TIoTCoreFoundation.h>



@interface TIoTCoreAccountSet()

@end

@implementation TIoTCoreAccountSet

+ (instancetype)shared
{
    static TIoTCoreAccountSet *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


#pragma mark - 注册

- (void)sendVerificationCodeWithEmail:(NSString *)email success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil,@{});
        return;
    }
    NSDictionary *tmpDic = @{@"Type":@"register",@"Email":email};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppSendEmailVerificationCode params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)checkVerificationCodeWithEmail:(NSString *)email code:(NSString *)code success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil,@{});
        return;
    }
    
    if (code == nil) {
        failure(@"code参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"register",@"Email":email,@"VerificationCode":code};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppCheckEmailVerificationCode params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)createEmailUserWithEmail:(NSString *)email verificationCode:(NSString *)code password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil,@{});
        return;
    }
    
    if (code == nil) {
        failure(@"code参数为空",nil,@{});
        return;
    }
    
    if (code == nil) {
        failure(@"password参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"Email":email,@"VerificationCode":code,@"Password":password};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppCreateEmailUser params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}


- (void)sendVerificationCodeWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil,@{});
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil,@{});
        return;
    }
    
    
    NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber};
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppSendVerificationCode params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}
- (void)checkVerificationCodeWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil,@{});
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil,@{});
        return;
    }
    
    if (verificationCode == nil) {
        failure(@"verificationCode参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber,@"VerificationCode":verificationCode};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppCheckVerificationCode params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}
- (void)createPhoneUserWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil,@{});
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil,@{});
        return;
    }
    
    if (verificationCode == nil) {
        failure(@"verificationCode参数为空",nil,@{});
        return;
    }
    
    if (password == nil) {
        failure(@"password参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"CountryCode":countryCode,@"PhoneNumber":phoneNumber,@"VerificationCode":verificationCode,@"Password":password};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppCreateCellphoneUser params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}

#pragma mark - 登录

- (void)signInWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil,@{});
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil,@{});
        return;
    }
    
    if (password == nil) {
        failure(@"password参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{
                             @"Type":@"phone",
                             @"CountryCode":countryCode,
                             @"PhoneNumber":phoneNumber,
                             @"Password":password
                             };
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppGetToken params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        [[TIoTCoreUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}
- (void)signInWithEmail:(NSString *)email password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    NSDictionary *tmpDic = @{
                                     @"Type":@"email",
                                     @"Password":password,
                                     @"Email":email,
                                     };
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppGetToken params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        [[TIoTCoreUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];

}
- (void)signInByWechatWithCode:(NSString *)code Success:(SRHandler)success failure:(FRHandler)failure
{
    if (code == nil) {
        failure(@"code参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"WxOpenID":[NSString stringWithFormat:@"%@",code],@"busi":@"studio"};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppGetTokenByWeiXin params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        [[TIoTCoreUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}

- (void)signOutOnSuccess:(SRHandler)success failure:(FRHandler)failure
{
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppLogoutUser params:@{} useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        [[TIoTCoreUserManage shared] clear];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}


#pragma mark - 邮箱重置密码

/// 发送用于重置的验证码到邮箱
- (void)sendCodeForResetWithEmail:(NSString *)email success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil,@{});
        return;
    }
    NSDictionary *tmpDic = @{@"Type":@"resetpass",@"Email":email};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppSendEmailVerificationCode params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

/// 检验验证码
- (void)checkCodeForResetWithEmail:(NSString *)email code:(NSString *)code success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil,@{});
        return;
    }
    if (code == nil) {
        failure(@"code参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"resetpass",@"Email":email,@"VerificationCode":code};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppCheckEmailVerificationCode params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

/// 重置密码（邮箱方式）
- (void)resetPasswordByEmail:(NSString *)email verificationCode:(NSString *)code password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    NSDictionary *tmpDic = @{@"Email":email,@"VerificationCode":code,@"Password":password};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppResetPasswordByEmail params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}


#pragma mark - 手机号重置密码

/// 发送用于重置的短信验证码
- (void)sendCodeForResetWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil,@{});
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"resetpass",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppSendVerificationCode params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}

/// 检验验证码
- (void)checkCodeForResetWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil,@{});
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil,@{});
        return;
    }
    
    if (verificationCode == nil) {
        failure(@"verificationCode参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"resetpass",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber,@"VerificationCode":verificationCode};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppCheckVerificationCode params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}

/// 重置密码（手机号方式）
- (void)ResetPasswordWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil,@{});
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil,@{});
        return;
    }
    
    if (verificationCode == nil) {
        failure(@"verificationCode参数为空",nil,@{});
        return;
    }
    
    if (password == nil) {
        failure(@"password参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"CountryCode":countryCode,@"PhoneNumber":phoneNumber,@"VerificationCode":verificationCode,@"Password":password};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppResetPasswordByCellphone params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}


#pragma mark - 修改密码

/// 修改密码
/// @param currentPassword 目前的密码
/// @param newPassword 新密码
- (void)modifyPasswordWithCurrentPassword:(NSString *)currentPassword newPassword:(NSString *)newPassword success:(SRHandler)success failure:(FRHandler)failure
{
    
    BOOL isPass = [NSString judgePassWordLegal:newPassword];
    if (!isPass) {
        failure(@"新密码不合规",nil,@{});
        return;
    }
    
    if ([currentPassword isEqualToString:newPassword]) {
        failure(NSLocalizedString(@"new_password_equals_old", @"新密码不能与旧密码相同"),nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"Password":currentPassword,@"NewPassword":newPassword};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppUserResetPassword params:tmpDic useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}


#pragma mark - 绑定手机号

/// 发送验证码（绑定手机号）
/// @param countryCode 国际区号，如中国大陆区号为86
- (void)sendCodeForBindWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil,@{});
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppSendVerificationCode params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

/// 绑定手机号
- (void)bindPhoneNumberWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode success:(SRHandler)success failure:(FRHandler)failure;
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil,@{});
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil,@{});
        return;
    }
    
    if (verificationCode == nil) {
        failure(@"verificationCode参数为空",nil,@{});
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber,@"VerificationCode":verificationCode};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppCheckVerificationCode params:tmpDic useToken:NO];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        
        TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppUpdateUser params:@{@"phoneNumber":phoneNumber,@"VerificationCode":verificationCode,@"CountryCode":countryCode} useToken:YES];
        [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
            [TIoTCoreUserManage shared].phoneNumber = phoneNumber;
            success(responseObject);
        } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
            failure(reason,error,dic);
        }];
        
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}


#pragma mark - 修改用户信息

- (void)getUserInfoOnSuccess:(SRHandler)success failure:(FRHandler)failure
{
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppGetUser params:@{} useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        NSDictionary *data = responseObject[@"Data"];
        [[TIoTCoreUserManage shared] saveUserInfo:data];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)getUploadInfoOnSuccess:(SRHandler)success failure:(FRHandler)failure
{
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppCosAuth params:@{@"path":@"iotexplorer-app-logs/user_{uin}/"} useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)updateUserWithNickName:(NSString *)nickName avatar:(NSString *)avatar success:(SRHandler)success failure:(FRHandler)failure
{
    NSString *name = nickName;
    NSString *pt = avatar;
    if (nickName == nil || [nickName isEqualToString:@""]) {
        name = [TIoTCoreUserManage shared].nickName;
    }
    if (avatar == nil || [avatar isEqualToString:@""]) {
        pt = [TIoTCoreUserManage shared].avatar;
    }
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppUpdateUser params:@{@"NickName":name,@"Avatar":pt} useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        [[TIoTCoreUserManage shared] saveUserInfo:@{@"UserID":[TIoTCoreUserManage shared].userId,@"Avatar":avatar,@"NickName":nickName,@"PhoneNumber":[TIoTCoreUserManage shared].phoneNumber}];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}


- (void)setFeedbackWithText:(NSString *)text contact:(NSString *)contact imageURLs:(NSArray<NSString *> *)urls success:(SRHandler)success failure:(FRHandler)failure
{
    if (text == nil) {
        failure(@"text参数为空",nil,@{});
        return;
    }
    
    if (contact == nil) {
        failure(@"contact参数为空",nil,@{});
        return;
    }
    
    if (urls == nil) {
        failure(@"urls参数为空",nil,@{});
        return;
    }
    
    
    NSDictionary *tmpDic = @{@"Type":@"advise",@"Desc":text,@"Contact":contact,@"LogUrl":[urls componentsJoinedByString:@","]};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppUserFeedBack params:tmpDic useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}
@end
