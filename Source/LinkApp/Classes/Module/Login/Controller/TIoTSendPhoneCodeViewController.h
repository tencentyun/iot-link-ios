//
//  WCSendPhoneCodeViewController.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTBingPasswordViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTSendPhoneCodeViewController : UIViewController

@property (nonatomic, assign) RegisterType registerType;
@property (nonatomic, copy) NSDictionary *sendCodeDic;

@end

NS_ASSUME_NONNULL_END
