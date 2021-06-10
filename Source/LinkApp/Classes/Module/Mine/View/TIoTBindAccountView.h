//
//  TIoTBindAccountView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BindAccountType) {
    BindAccountPhoneType,
    BindAccountEmailType
};

@protocol TIoTBindAccountViewDelegate <NSObject>
@optional
- (void)bindAccountSendCodeWithAccountType:(BindAccountType)accountType;

- (void)bindAccountChangedTextFieldWithAccountType:(BindAccountType)accountType;

- (void)bindAccountConfirmClickButtonWithAccountType:(BindAccountType)accountType;

- (void)bindAccountConentIncreaseInterval:(CGFloat)interval accountType:(BindAccountType)accountType;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TIoTBindAccountView : UIView
@property (nonatomic, strong) UITextField   *phoneOrEmailTF;
@property (nonatomic, strong) UIButton      *verificationButton;
@property (nonatomic, strong) UITextField   *verificationCodeTF;
@property (nonatomic, strong) UITextField   *passwordTF;
@property (nonatomic, strong) UITextField   *passwordConfirmTF;
@property (nonatomic, strong) UIButton      *confirmButton;

/**
  初始化对象时候，枚举必须要赋值
 */
@property (nonatomic, assign) BindAccountType bindAccoutType;

@property (nonatomic, weak) id<TIoTBindAccountViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
