//
//  WCAlertView.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTAlertView.h"


@interface TIoTAlertView()<UITextFieldDelegate>

@property (nonatomic) WCAlertViewStyle style;

@property (nonatomic,strong) UILabel *nameL;
@property (nonatomic,strong) UILabel *messageL;
@property (nonatomic,strong) UITextField *messageT;
@property (nonatomic,strong) UIButton *cancleBtn;
@property (nonatomic,strong) UIButton *doneBtn;
@property (nonatomic, strong) UIImage *successTopImage;

@property (nonatomic) CGRect oriFrame;

@end
@implementation TIoTAlertView

- (instancetype)initWithFrame:(CGRect)frame andStyle:(WCAlertViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style;
        [self setupUI];
        [self addKeyboardNote];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withTopImage:(UIImage *)topImage {
    self = [super initWithFrame:frame];
    if (self) {
        self.successTopImage = topImage;
        [self setUpViews];
    }
    return self;
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message cancleTitlt:(NSString *)cancleTitlt doneTitle:(NSString *)doneTitle
{
    self.nameL.text = title;
    self.messageL.text = message;
    self.messageL.textAlignment = NSTextAlignmentCenter;
    self.messageT.placeholder = message;
    [self.cancleBtn setTitle:cancleTitlt forState:UIControlStateNormal];
    [self.doneBtn setTitle:doneTitle forState:UIControlStateNormal];
}

- (void)setDefaultText:(NSString *)defaultText
{
    _defaultText = defaultText;
    self.messageT.text = defaultText;
}

- (void)setUpViews {
    
    self.backgroundColor = kRGBAColor(0, 0, 0, 0.7);
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 10;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(kScreenWidth - 60);
    }];
    
    UIImageView *topImage = nil;
    if (self.successTopImage) {
        topImage = [[UIImageView alloc]initWithImage:self.successTopImage];
        [bgView addSubview:topImage];
        [topImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_top).offset(25 * kScreenAllHeightScale);
            make.centerX.equalTo(bgView.mas_centerX);
            make.width.height.mas_equalTo(40 * kScreenAllHeightScale);
        }];
    }
    
    UILabel *name = [[UILabel alloc] init];
    name.text = @"";
    name.textAlignment = NSTextAlignmentCenter;
    name.textColor = [UIColor colorWithHexString:@"#15161A"];
    name.font = [UIFont wcPfRegularFontOfSize:16];
    [bgView addSubview:name];
    self.nameL = name;
    [name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        if (topImage != nil) {
            make.top.equalTo(topImage.mas_bottom).offset(22 *kScreenAllHeightScale);
        }else {
            make.top.mas_equalTo(30);
        }
        
        make.trailing.mas_equalTo(-20);
    }];
    
    UILabel *content = [[UILabel alloc] init];
    content.text = @"";
    content.numberOfLines = 0;
    content.textColor = [UIColor colorWithHexString:@"#6C7078"];
    content.font = [UIFont wcPfRegularFontOfSize:14];
    [bgView addSubview:content];
    self.messageL = content;
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.equalTo(name.mas_bottom).offset(20);
        make.trailing.mas_equalTo(-20);
    }];
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = kLineColor;
    [bgView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(bgView);
        make.height.mas_equalTo(1);
        make.top.equalTo(content.mas_bottom).offset(20 *kScreenAllHeightScale);
    }];
    
    UIStackView *stack = [[UIStackView alloc] init];
    stack.distribution = UIStackViewDistributionFillEqually;
    stack.alignment = UIStackViewAlignmentFill;
    [bgView addSubview:stack];
    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(bgView);
        make.top.equalTo(line.mas_bottom);
        make.bottom.equalTo(bgView.mas_bottom);
        make.height.mas_equalTo(50 * kScreenAllHeightScale);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#6C7078"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 10;
    [stack addArrangedSubview:btn];
    self.cancleBtn = btn;
    
    UIView *lineBtn = [[UIView alloc]init];
    lineBtn.backgroundColor = kLineColor;
    [bgView addSubview:lineBtn];
    [lineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(btn);
        make.leading.equalTo(btn.mas_trailing);
        make.width.mas_equalTo(1);
    }];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"确定" forState:UIControlStateNormal];
    [btn2 setTitleColor:kMainColor forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor whiteColor]];
    btn2.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [btn2 addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    btn2.layer.cornerRadius = 10;
    [stack addArrangedSubview:btn2];
    self.doneBtn = btn2;
}

- (void)setupUI
{
    self.backgroundColor = kRGBAColor(0, 0, 0, 0.7);
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancle)];
//    [self addGestureRecognizer:tap];
    
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 10;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(kScreenWidth - 60);
    }];
    
    UILabel *name = [[UILabel alloc] init];
    name.text = @"房间名称";
    name.textAlignment = NSTextAlignmentCenter;
    name.textColor = kFontColor;
    name.font = [UIFont boldSystemFontOfSize:20];
    [bgView addSubview:name];
    self.nameL = name;
    [name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.mas_equalTo(30);
        make.trailing.mas_equalTo(-20);
    }];
    
    
    UIView *messageView;
    if (self.style ==WCAlertViewStyleText) {
        UILabel *content = [[UILabel alloc] init];
        content.text = @"详细是否水电费水电费水电费第三方第三方所发生的丰富的非";
        content.numberOfLines = 0;
        content.textColor = kFontColor;
        content.font = [UIFont systemFontOfSize:16];
        [bgView addSubview:content];
        messageView = content;
        self.messageL = content;
        [content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(20);
            make.top.equalTo(name.mas_bottom).offset(20);
            make.trailing.mas_equalTo(-20);
        }];
        
    }
    else if (self.style ==WCAlertViewStyleTextField)
    {
        
        UITextField *textf = [[UITextField alloc] init];
        textf.textColor = kFontColor;
        textf.borderStyle = UITextBorderStyleNone;
        textf.layer.borderColor = kRGBColor(230, 230, 230).CGColor;
        textf.layer.borderWidth = 1;
        textf.leftViewMode = UITextFieldViewModeAlways;
        textf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];;
        textf.returnKeyType = UIReturnKeyDone;
        [textf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [bgView addSubview:textf];
        messageView = textf;
        self.messageT = textf;
        [textf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(20);
            make.top.equalTo(name.mas_bottom).offset(20);
            make.trailing.mas_equalTo(-20);
            make.height.mas_equalTo(48);
        }];
    }
    
    
    
    UIStackView *stack = [[UIStackView alloc] init];
    stack.distribution = UIStackViewDistributionFillEqually;
    stack.alignment = UIStackViewAlignmentFill;
    stack.spacing = 20;
    [bgView addSubview:stack];
    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.equalTo(messageView.mas_bottom).offset(30);
        make.bottom.mas_equalTo(-30);
        make.height.mas_equalTo(48);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:kRGBColor(230, 230, 230)];
    [btn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4;
    [stack addArrangedSubview:btn];
    self.cancleBtn = btn;
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"确定" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn2 setBackgroundColor:kMainColor];
    [btn2 addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    btn2.layer.cornerRadius = 4;
    [stack addArrangedSubview:btn2];
    self.doneBtn = btn2;
    
}

- (void)showInView:(UIView *)superView
{
    [superView addSubview:self];
}


#pragma mark - event

- (void)cancle
{
    [self.messageT resignFirstResponder];
    [self removeFromSuperview];
}

- (void)done
{
    [self cancle];
    if (self.doneAction) {
        self.doneAction(self.messageT.text);
    }
}

- (void)showSingleConfrimButton {
    self.cancleBtn.hidden = YES;
    
    [self done];
}

#pragma mark - textf
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    NSInteger count = 0;
//    if ([string isEqualToString:@""]) {
//        if (range.length > 0) {
//            count = range.location;
//        }
//    }
//    else if ([string isEqualToString:@"\n"])
//    {
//        count = textField.text.length;
//    }
//    else
//    {
//        count = [NSString stringWithFormat:@"%@%@",textField.text,string].length;
//    }
//
//    if (self.maxLength > 0 && count > self.maxLength) {
//        return NO;
//    }
//    return YES;
//}

- (void)textFieldDidChange:(UITextField *)textField

{
    NSInteger kMaxLength = self.maxLength;
    NSString *toBeString = textField.text;
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
                
            }
            
        }
        else{//有高亮选择的字符串，则暂不对文字进行统计和限制
            
        }
        
    }else{//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
            
        }
        
    }

}

#pragma mark - keyboard

- (void)addKeyboardNote {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    // 1.显示键盘
    [center addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    
    // 2.隐藏键盘
    [center addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark 键盘通知执行
- (void)keyboardChange:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    
    if ([notification.name isEqualToString:@"UIKeyboardWillShowNotification"]) {
        self.oriFrame = self.frame;
        
        CGRect newFrame = self.frame;
        if (self.subviews.firstObject) {
            CGRect bgframe = self.subviews.firstObject.frame;
            CGFloat distance = keyboardEndFrame.origin.y - CGRectGetMaxY(bgframe);
            if (distance < 20) {
                newFrame.origin.y -= (20 - distance);
            }
        }
        self.frame = newFrame;
    }
    else if ([notification.name isEqualToString:@"UIKeyboardWillHideNotification"]) {
        
        self.frame = self.oriFrame;
    }
    
    [UIView commitAnimations];
}

@end
