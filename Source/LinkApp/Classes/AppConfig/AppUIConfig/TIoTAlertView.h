//
//  WCAlertView.h
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
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

@property (nonatomic, strong) void (^doneAction)(NSString *text);
@property (nonatomic, strong) void (^cancelAction)(void);
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, copy) NSString *defaultText;//输入框默认文本

- (void)alertWithTitle:(NSString *)title message:(NSString *)message cancleTitlt:(NSString *)cancleTitlt doneTitle:(NSString *)doneTitle;

- (void)showInView:(UIView *)superView;
- (void)setAlertViewContentAlignment:(TextAlignmentStyle)TextAlignmentStyle;
- (void)showSingleConfrimButton;
@end
