//
//  TIoTAlertCustomView.m
//  LinkApp
//
//  Created by ccharlesren on 2021/1/26.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTAlertCustomView.h"

@interface TIoTAlertCustomView ()<UITextViewDelegate>
@property (nonatomic, strong) UIView *blackMaskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextView *procolTV;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) NSString *messsageString;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, assign) TIoTAlertCustomViewContentType type;
@property (nonatomic, strong) NSMutableAttributedString *conentTextProtolString;

@end

@implementation TIoTAlertCustomView

- (instancetype)initWithFrame:(CGRect)frame withContentType:(TIoTAlertCustomViewContentType)contentType isAddHideGesture:(BOOL)hideTap{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializationData:contentType];
        [self setUPUIViewsWithHideMaskGesture:hideTap];
    }
    return self;
}

- (void)alertCustomViewTitleMessage:(NSString *)titleString cancelBtnTitle:(NSString *)cancelTitle confirmBtnTitle:(NSString *)confirmTitle {
    
    self.messageLabel.text = titleString?:@"";
    [self.cancelButton setTitle:cancelTitle?:@"" forState:UIControlStateNormal];
    [self.confirmButton setTitle:confirmTitle?:@"" forState:UIControlStateNormal];
}

- (void)setUPUIViewsWithHideMaskGesture:(BOOL)isHide {
    
    self.blackMaskView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.blackMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [[UIApplication sharedApplication].delegate.window addSubview:self.blackMaskView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAlertView)];
    if (isHide) [self.blackMaskView addGestureRecognizer:tap];
    
    
    
    CGFloat kIntervalPadding = 10;
    CGFloat kContentViewPadding = 30;
    CGFloat kTitleWidthPadding = 20;
    
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 10;
    [self.blackMaskView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.blackMaskView);
        make.width.mas_equalTo(kScreenWidth - kContentViewPadding*2);
    }];

    UILabel *messageLabel = [[UILabel alloc]init];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:messageLabel];
    self.messageLabel = messageLabel;
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(kTitleWidthPadding);
        make.top.equalTo(self.contentView.mas_top).offset(kIntervalPadding*2);
        make.trailing.mas_equalTo(-kTitleWidthPadding);
    }];

    UIView *middleView = [[UIView alloc]init];
    middleView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:middleView];
    [middleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.equalTo(self.contentView);
        make.top.equalTo(messageLabel.mas_bottom).offset(kIntervalPadding);
        make.height.mas_equalTo(200);
        make.trailing.mas_equalTo(-kTitleWidthPadding);
        make.leading.mas_equalTo(kTitleWidthPadding);
    }];
    
    
    if (self.type == TIoTAlertViewContentTypeDatePick) {
        [middleView addSubview:self.datePicker];
        [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(middleView);
        }];
    }else {
        
        middleView.hidden = YES;
        
        self.procolTV = [[UITextView alloc] init];
        self.procolTV.attributedText = [self conentTextProtolString];;
        self.procolTV.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:kIntelligentMainHexColor]}; //
        self.procolTV.textColor = [UIColor colorWithHexString:@"#6C7078"];
        self.procolTV.delegate = self;
        self.procolTV.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
        self.procolTV.scrollEnabled = NO;
        [self.contentView addSubview:self.procolTV];
        [self.procolTV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(middleView);
            make.top.equalTo(messageLabel.mas_bottom);
        }];
    }
    
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = kLineColor;
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(1);
        if (self.type == TIoTAlertViewContentTypeDatePick) {
            make.top.equalTo(middleView.mas_bottom).offset(kIntervalPadding);
        }else {
            make.top.equalTo(self.procolTV.mas_bottom).offset(kIntervalPadding);
        }
        
    }];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.distribution = UIStackViewDistributionFillEqually;
    stack.alignment = UIStackViewAlignmentFill;
    [self.contentView addSubview:stack];
    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.top.equalTo(line.mas_bottom);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(50);
    }];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitleColor:[UIColor colorWithHexString:@"#6C7078"] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [cancelButton setBackgroundColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.layer.cornerRadius = 10;
    [stack addArrangedSubview:cancelButton];
    self.cancelButton = cancelButton;

    UIView *lineBtn = [[UIView alloc]init];
    lineBtn.backgroundColor = kLineColor;
    [self.contentView addSubview:lineBtn];
    [lineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cancelButton);
        make.leading.equalTo(cancelButton.mas_trailing);
        make.width.mas_equalTo(1);
    }];

    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    [confirmButton setBackgroundColor:[UIColor whiteColor]];
    confirmButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [confirmButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.layer.cornerRadius = 10;
    [stack addArrangedSubview:confirmButton];
    self.confirmButton = confirmButton;
    
    
}

- (void)cancle {
    [self hideAlertView];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)done {
    [self hideAlertView];
    if (self.confirmBlock) {
        self.confirmBlock(self.dateString);
    }
}

- (void)hideAlertView {
    [self.blackMaskView removeFromSuperview];
}

- (void)initializationData:(TIoTAlertCustomViewContentType)contentType {
    self.messsageString = @"";
    self.dateString = @"";
    self.type = contentType;
}

- (void)dateChange:(UIDatePicker *)datePicker {
    
    self.dateString = [self getDateStringWithDate:datePicker.date];
}

- (NSString *)getDateStringWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //设置时间格式
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:date];
    return dateString?:@"";
}

#pragma mark uitextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    if ([[URL scheme] isEqualToString:@"Privacy2"]) {
        WCLog(@"设备分享隐私");
        
        [self hideAlertView];
        if (self.privatePolicyBlock) {
            self.privatePolicyBlock();
        }
        return NO;
    }
    return YES;
}

#pragma mark - lazy
- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc]init];
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.frame = CGRectMake(0, 14, kScreenWidth, 200);
        _datePicker.datePickerMode = UIDatePickerModeDate;
        // 设置当前显示时间
        [_datePicker setDate:[NSDate date] animated:YES];
        
        self.dateString = [self getDateStringWithDate:[NSDate date]];
        
        //监听DataPicker的滚动
        [_datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _datePicker;
}

- (NSMutableAttributedString *)conentTextProtolString {
    if (!_conentTextProtolString) {

        NSString *str1 = NSLocalizedString(@"device_shared_agree_1", @"通过将设备名称与腾讯连连连接，即表示您同意与设备名称共享有关您的设备和设备日志的信息，第三方可以根据其条款和政策使用该设备。\n有关更多信息，请阅读我们的");
        NSString *str2= NSLocalizedString(@"register_agree_4", @"隐私政策");
        NSString *showStr = [NSString stringWithFormat:@"%@%@",str1,str2];
        
        NSRange range2 = [showStr rangeOfString:str2];
        NSMutableParagraphStyle *pstype = [[NSMutableParagraphStyle alloc] init];
        [pstype setAlignment:NSTextAlignmentCenter];
        NSMutableAttributedString *mastring = [[NSMutableAttributedString alloc] initWithString:showStr attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:pstype}];
        
        NSString *valueString2 = [[NSString stringWithFormat:@"Privacy2://%@",str2] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

        [mastring addAttributes:@{NSLinkAttributeName:valueString2,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],} range:range2];
        _conentTextProtolString = mastring;
    }
    return _conentTextProtolString;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
