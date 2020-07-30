//
//  TIoTModifyView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/7/31.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ModifyAccountType) {
    ModifyAccountPhoneType,
    ModifyAccountEmailType
};

NS_ASSUME_NONNULL_BEGIN

@protocol TIoTModifyAccountViewDelegate <NSObject>

- (void)modifyAccountSendCodeWithAccountType:(ModifyAccountType)accountType;

- (void)modifyAccountChangedTextFieldWithAccountType:(ModifyAccountType)accountType;

- (void)modifyAccountConfirmClickButtonWithAccountType:(ModifyAccountType)accountType;

@end

@interface TIoTModifyView : UIView
@property (nonatomic, strong) UITextField   *phoneOrEmailTF;
@property (nonatomic, strong) UIButton      *verificationButton;
@property (nonatomic, strong) UITextField   *verificationCodeTF;
@property (nonatomic, strong) UIButton      *confirmButton;

/**
  初始化对象时候，枚举必须要赋值
 */
@property (nonatomic, assign) ModifyAccountType modifyAccoutType;

@property (nonatomic, weak) id<TIoTModifyAccountViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
