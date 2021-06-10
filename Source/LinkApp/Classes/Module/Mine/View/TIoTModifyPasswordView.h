//
//  TIoTModifyPasswordView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

@protocol TIoTModifyPasswordViewDelegate  <NSObject>
@optional
- (void)modifyPasswordSendCode;

- (void)modifyPasswordChangedTextField;

- (void)modifyPasswordConfirmClickButton;

- (void)modifyPasswordConentIncreaseInterval:(CGFloat)interval;
@end

NS_ASSUME_NONNULL_BEGIN

@interface TIoTModifyPasswordView : UIView

@property (nonatomic, strong) UITextField   *phoneOrEmailTF;
@property (nonatomic, strong) UIButton      *verificationButton;
@property (nonatomic, strong) UITextField   *verificationCodeTF;
@property (nonatomic, strong) UITextField   *passwordTF;
@property (nonatomic, strong) UITextField   *passwordConfirmTF;
@property (nonatomic, strong) UIButton      *confirmButton;
@property (nonatomic, strong) UILabel       *phoneOrEmailLabel;

@property (nonatomic, weak) id<TIoTModifyPasswordViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
