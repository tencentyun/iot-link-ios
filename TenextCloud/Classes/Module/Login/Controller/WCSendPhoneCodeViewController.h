//
//  WCSendPhoneCodeViewController.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBingPasswordViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WCSendPhoneCodeViewController : UIViewController

@property (nonatomic, assign) RegisterType registerType;
@property (nonatomic, copy) NSDictionary *sendCodeDic;

@end

NS_ASSUME_NONNULL_END
