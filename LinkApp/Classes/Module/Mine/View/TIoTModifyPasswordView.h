//
//  TIoTModifyPasswordView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/8/1.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TIoTModifyPasswordViewDelegate  <NSObject>
@optional
- (void)modifyPasswordSendCode;

- (void)modifyPasswordChangedTextField;

- (void)modifyPasswordConfirmClickButton;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TIoTModifyPasswordView : UIView

@property (nonatomic, strong) UITextField   *phoneOrEmailTF;
@property (nonatomic, strong) UIButton      *verificationButton;
@property (nonatomic, strong) UITextField   *verificationCodeTF;
@property (nonatomic, strong) UITextField   *passwordTF;
@property (nonatomic, strong) UITextField   *passwordConfirmTF;
@property (nonatomic, strong) UIButton      *confirmButton;

@property (nonatomic, weak) id<TIoTModifyPasswordViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
