//
//  WCAlertView.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TextAlignmentStyle) {
    TextAlignmentStyleCenter,
    TextAlignmentStyleLeft,
    TextAlignmentStyleRight,
};

typedef NS_ENUM(NSInteger,WCAlertViewStyle) {
    WCAlertViewStyleText = 0,
    WCAlertViewStyleTextField = 1
};


@interface TIoTAlertView : UIView

- (instancetype)initWithFrame:(CGRect)frame andStyle:(WCAlertViewStyle)style;

- (instancetype)initWithFrame:(CGRect)frame withTopImage:(UIImage *)topImage;
- (instancetype)initWithPricy:(CGRect)frame ;

@property (nonatomic, strong) void (^doneAction)(NSString *text);
@property (nonatomic, strong) void (^cancelAction)(void);
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, copy) NSString *defaultText;//输入框默认文本

- (void)alertWithTitle:(NSString *)title message:(NSString *)message cancleTitlt:(NSString *)cancleTitlt doneTitle:(NSString *)doneTitle;
- (void)setConfirmButtonColor:(NSString *)hexString;
- (void)showInView:(UIView *)superView;
- (void)setAlertViewContentAlignment:(TextAlignmentStyle)TextAlignmentStyle;
- (void)showSingleConfrimButton;
- (void)setBackGroundAlphaValue:(CGFloat)value;
@end
