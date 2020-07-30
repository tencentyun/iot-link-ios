//
//  TIoTBindAccountVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/7/30.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AccountType) {
    AccountType_Phone,
    AccountType_Email
};

NS_ASSUME_NONNULL_BEGIN

@interface TIoTBindAccountVC : UIViewController

/**
 初始化对象时候必须赋值
 */
@property (nonatomic, assign) AccountType accountType;

@end

NS_ASSUME_NONNULL_END
