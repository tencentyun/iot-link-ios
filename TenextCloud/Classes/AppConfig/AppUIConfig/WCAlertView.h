//
//  WCAlertView.h
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef NS_ENUM(NSInteger,WCAlertViewStyle) {
    WCAlertViewStyleText = 0,
    WCAlertViewStyleTextField = 1
};


@interface WCAlertView : UIView

- (instancetype)initWithFrame:(CGRect)frame andStyle:(WCAlertViewStyle)style;

@property (nonatomic, strong) void (^doneAction)(NSString *text);
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, copy) NSString *defaultText;//输入框默认文本

- (void)alertWithTitle:(NSString *)title message:(NSString *)message cancleTitlt:(NSString *)cancleTitlt doneTitle:(NSString *)doneTitle;

- (void)showInView:(UIView *)superView;

@end
