//
//  QCAccountManager.m
//  QCAccount
//
//  Created by Wp on 2019/12/4.
//  Copyright © 2019 Reo. All rights reserved.
//

#import "QCAccountSet.h"
#import "WCRequestAction.h"
#import <QCFoundation/QCFoundation.h>



@interface QCAccountSet()

@end

@implementation QCAccountSet

+ (instancetype)shared
{
    static QCAccountSet *_instance = nil;
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
        failure(@"email参数为空",nil);
        return;
    }
    NSDictionary *tmpDic = @{@"Type":@"register",@"Email":email};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppSendEmailVerificationCode params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)checkVerificationCodeWithEmail:(NSString *)email code:(NSString *)code success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil);
        return;
    }
    
    if (code == nil) {
        failure(@"code参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"register",@"Email":email,@"VerificationCode":code};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppCheckEmailVerificationCode params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)createEmailUserWithEmail:(NSString *)email verificationCode:(NSString *)code password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil);
        return;
    }
    
    if (code == nil) {
        failure(@"code参数为空",nil);
        return;
    }
    
    if (code == nil) {
        failure(@"password参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"Email":email,@"VerificationCode":code,@"Password":password};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppCreateEmailUser params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}


- (void)sendVerificationCodeWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil);
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil);
        return;
    }
    
    
    NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber};
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppSendVerificationCode params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}
- (void)checkVerificationCodeWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil);
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil);
        return;
    }
    
    if (verificationCode == nil) {
        failure(@"verificationCode参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber,@"VerificationCode":verificationCode};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppCheckVerificationCode params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}
- (void)createPhoneUserWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil);
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil);
        return;
    }
    
    if (verificationCode == nil) {
        failure(@"verificationCode参数为空",nil);
        return;
    }
    
    if (password == nil) {
        failure(@"password参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"CountryCode":countryCode,@"PhoneNumber":phoneNumber,@"VerificationCode":verificationCode,@"Password":password};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppCreateCellphoneUser params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}

#pragma mark - 登录

- (void)signInWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil);
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil);
        return;
    }
    
    if (password == nil) {
        failure(@"password参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{
                             @"Type":@"phone",
                             @"CountryCode":countryCode,
                             @"PhoneNumber":phoneNumber,
                             @"Password":password
                             };
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetToken params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        [[QCUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}
- (void)signInWithEmail:(NSString *)email password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    NSDictionary *tmpDic = @{
                                     @"Type":@"email",
                                     @"Password":password,
                                     @"Email":email,
                                     };
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetToken params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        [[QCUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];

}
- (void)signInByWechatWithCode:(NSString *)code Success:(SRHandler)success failure:(FRHandler)failure
{
    if (code == nil) {
        failure(@"code参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"code":[NSString stringWithFormat:@"%@",code],@"busi":@"studio"};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetTokenByWeiXin params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        [[QCUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}

- (void)signOutOnSuccess:(SRHandler)success failure:(FRHandler)failure
{
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppLogoutUser params:@{} useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        [[QCUserManage shared] clear];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}


#pragma mark - 邮箱重置密码

/// 发送用于重置的验证码到邮箱
- (void)sendCodeForResetWithEmail:(NSString *)email success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil);
        return;
    }
    NSDictionary *tmpDic = @{@"Type":@"resetpass",@"Email":email};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppSendEmailVerificationCode params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

/// 检验验证码
- (void)checkCodeForResetWithEmail:(NSString *)email code:(NSString *)code success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil);
        return;
    }
    if (code == nil) {
        failure(@"code参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"resetpass",@"Email":email,@"VerificationCode":code};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppCheckEmailVerificationCode params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

/// 重置密码（邮箱方式）
- (void)resetPasswordByEmail:(NSString *)email verificationCode:(NSString *)code password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    NSDictionary *tmpDic = @{@"Email":email,@"VerificationCode":code,@"Password":password};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppResetPasswordByEmail params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}


#pragma mark - 手机号重置密码

/// 发送用于重置的短信验证码
- (void)sendCodeForResetWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil);
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"resetpass",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppSendVerificationCode params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}

/// 检验验证码
- (void)checkCodeForResetWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil);
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil);
        return;
    }
    
    if (verificationCode == nil) {
        failure(@"verificationCode参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"resetpass",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber,@"VerificationCode":verificationCode};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppCheckVerificationCode params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}

/// 重置密码（手机号方式）
- (void)ResetPasswordWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil);
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil);
        return;
    }
    
    if (verificationCode == nil) {
        failure(@"verificationCode参数为空",nil);
        return;
    }
    
    if (password == nil) {
        failure(@"password参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"CountryCode":countryCode,@"PhoneNumber":phoneNumber,@"VerificationCode":verificationCode,@"Password":password};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppResetPasswordByCellphone params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
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
        failure(@"新密码不合规",nil);
        return;
    }
    
    if ([currentPassword isEqualToString:newPassword]) {
        failure(@"新密码不能与旧密码相同",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"Password":currentPassword,@"NewPassword":newPassword};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppUserResetPassword params:tmpDic useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}


#pragma mark - 绑定手机号

/// 发送验证码（绑定手机号）
/// @param countryCode 国际区号，如中国大陆区号为86
- (void)sendCodeForBindWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber success:(SRHandler)success failure:(FRHandler)failure
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil);
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppSendVerificationCode params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

/// 绑定手机号
- (void)bindPhoneNumberWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode success:(SRHandler)success failure:(FRHandler)failure;
{
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil);
        return;
    }
    
    if (phoneNumber == nil) {
        failure(@"phoneNumber参数为空",nil);
        return;
    }
    
    if (verificationCode == nil) {
        failure(@"verificationCode参数为空",nil);
        return;
    }
    
    NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":countryCode,@"PhoneNumber":phoneNumber,@"VerificationCode":verificationCode};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppCheckVerificationCode params:tmpDic useToken:NO];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        
        QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppUpdateUser params:@{@"phoneNumber":phoneNumber,@"VerificationCode":verificationCode,@"CountryCode":countryCode} useToken:YES];
        [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
            [QCUserManage shared].phoneNumber = phoneNumber;
            success(responseObject);
        } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
            failure(reason,error);
        }];
        
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}


#pragma mark - 修改用户信息

- (void)getUserInfoOnSuccess:(SRHandler)success failure:(FRHandler)failure
{
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetUser params:@{} useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        NSDictionary *data = responseObject[@"Data"];
        [[QCUserManage shared] saveUserInfo:data];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)getUploadInfoOnSuccess:(SRHandler)success failure:(FRHandler)failure
{
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppCosAuth params:@{@"path":@"iotexplorer-app-logs/user_{uin}/"} useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)updateUserWithNickName:(NSString *)nickName avatar:(NSString *)avatar success:(SRHandler)success failure:(FRHandler)failure
{
    NSString *name = nickName;
    NSString *pt = avatar;
    if (nickName == nil || [nickName isEqualToString:@""]) {
        name = [QCUserManage shared].nickName;
    }
    if (avatar == nil || [avatar isEqualToString:@""]) {
        pt = [QCUserManage shared].avatar;
    }
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppUpdateUser params:@{@"NickName":name,@"Avatar":pt} useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        [[QCUserManage shared] saveUserInfo:@{@"UserID":[QCUserManage shared].userId,@"Avatar":avatar,@"NickName":nickName,@"PhoneNumber":[QCUserManage shared].phoneNumber}];
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}


- (void)setFeedbackWithText:(NSString *)text contact:(NSString *)contact imageURLs:(NSArray<NSString *> *)urls success:(SRHandler)success failure:(FRHandler)failure
{
    if (text == nil) {
        failure(@"text参数为空",nil);
        return;
    }
    
    if (contact == nil) {
        failure(@"contact参数为空",nil);
        return;
    }
    
    if (urls == nil) {
        failure(@"urls参数为空",nil);
        return;
    }
    
    
    NSDictionary *tmpDic = @{@"Type":@"advise",@"Desc":text,@"Contact":contact,@"LogUrl":[urls componentsJoinedByString:@","]};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppUserFeedBack params:tmpDic useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}
@end
