//
//  WCBingPasswordViewController.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RegisterType) {
    PhoneRegister,
    EmailRegister,
    PhoneResetPwd,
    EmailResetPwd,
    LoginedResetPwd
};

NS_ASSUME_NONNULL_BEGIN

@interface TIoTBingPasswordViewController : UIViewController

@property (nonatomic, assign) RegisterType registerType;
@property (nonatomic, copy) NSDictionary *sendDataDic;

@end

NS_ASSUME_NONNULL_END
