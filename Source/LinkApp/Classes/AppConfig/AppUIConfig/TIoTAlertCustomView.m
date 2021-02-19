//
//  TIoTAlertCustomView.m
//  LinkApp
//
//  Created by ccharlesren on 2021/1/26.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTAlertCustomView.h"
#import "TIoTIntelligentBottomActionView.h"
#import "UIView+XDPExtension.h"

@interface TIoTAlertCustomView ()<UITextViewDelegate>
@property (nonatomic, strong) UIView *blackMaskView;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextView *procolTV;
@property (nonatomic, strong) NSString *cancelBtnTitle;
@property (nonatomic, strong) NSString *confirmBtnTitle;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSString *messsageString;
@property (nonatomic, strong) UIView *procolHoldView;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, assign) TIoTAlertCustomViewContentType type;
@property (nonatomic, strong) NSMutableAttributedString *conentTextProtolString;

@end

@implementation TIoTAlertCustomView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.cancelBtnTitle = NSLocalizedString(@"cancel", @"取消");
        self.confirmBtnTitle = NSLocalizedString(@"confirm", @"确定");
    }
    return self;
}

- (void)alertContentType:(TIoTAlertCustomViewContentType)contentType isAddHideGesture:(BOOL)hideTap {
    [self initializationData:contentType];
    [self setUPUIViewsWithHideMaskGesture:hideTap];
}

- (void)alertCustomViewTitleMessage:(NSString *)titleString cancelBtnTitle:(NSString *)cancelTitle confirmBtnTitle:(NSString *)confirmTitle {
    
    self.messageLabel.text = titleString?:@"";
    self.cancelBtnTitle = cancelTitle?:self.cancelBtnTitle;
    self.confirmBtnTitle = confirmTitle?:self.confirmBtnTitle;
    
    [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[self.cancelBtnTitle,self.confirmBtnTitle]];
    
    self.titleLabel.text = titleString?:@"";
    
}

- (void)setUPUIViewsWithHideMaskGesture:(BOOL)isHide {
    
    self.blackMaskView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.blackMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [[UIApplication sharedApplication].delegate.window addSubview:self.blackMaskView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAlertView)];
    if (isHide) [self.blackMaskView addGestureRecognizer:tap];
    
    CGFloat kIntervalPadding = 12;
    CGFloat kContentViewPadding = 20;
    CGFloat kTitleWidthPadding = 20;
    
    
    CGFloat kBottomViewHeight = 56;
    CGFloat kSafeAreaInsetBottom = 34;
    
    if (@available (iOS 11.0, *)) {
        if ([UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom) {
            kBottomViewHeight = kBottomViewHeight +[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        }else {
            kBottomViewHeight = kBottomViewHeight + kSafeAreaInsetBottom;
        }
    }else {
        kBottomViewHeight = kBottomViewHeight + kSafeAreaInsetBottom;
    }
    
    [self.blackMaskView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.blackMaskView);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.blackMaskView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.blackMaskView.mas_width);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];

    UILabel *messageLabel = [[UILabel alloc]init];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:messageLabel];
    self.messageLabel = messageLabel;
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(kTitleWidthPadding);
        make.top.equalTo(self.contentView.mas_top).offset(kIntervalPadding);
        make.trailing.mas_equalTo(-kTitleWidthPadding);
    }];

    UIView *lineTop = [[UIView alloc]init];
    lineTop.backgroundColor = kLineColor;
    [self.contentView addSubview:lineTop];
    [lineTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(1);
        make.top.equalTo(messageLabel.mas_bottom).offset(kIntervalPadding);
    }];
    
    UIView *middleView = [[UIView alloc]init];
    middleView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:middleView];
    [middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineTop.mas_bottom).offset(0);
        make.height.mas_equalTo(272);
        make.trailing.mas_equalTo(0);
        make.leading.mas_equalTo(0);
    }];
    
    
    if (self.type == TIoTAlertViewContentTypeDatePick) {
        
        [middleView addSubview:self.datePicker];
        [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(middleView);
        }];
    }else {
        
        messageLabel.hidden = YES;
        lineTop.hidden = YES;
        middleView.hidden = YES;
        
        CGFloat kTopPadding = 24;
        CGFloat kTopViewHeight = 72;
        
        UIView *topView = [[UIView alloc]init];
        [self.contentView addSubview:topView];
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(kTopPadding);
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(kTopViewHeight);
        }];
        
        UIImageView *logoImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"AppIcon"]];
        [topView addSubview:logoImage];
        [logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(kTitleWidthPadding);
            make.top.equalTo(self.contentView.mas_top).offset(kTopPadding);
            make.width.height.mas_equalTo(24);
        }];
        
        UILabel *logoLabel = [[UILabel alloc]init];
        logoLabel.text = NSLocalizedString(@"lialian_name", @"腾讯连连");
        logoLabel.font = [UIFont wcPfRegularFontOfSize:16];
        logoLabel.textColor = [UIColor blackColor];
        logoLabel.textAlignment = NSTextAlignmentLeft;
        [topView addSubview:logoLabel];
        [logoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(logoImage.mas_right).offset(8);
            make.centerY.equalTo(logoImage);
        }];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.font = [UIFont wcPfMediumFontOfSize:22];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [topView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(logoImage.mas_bottom).offset(15);
            make.left.equalTo(logoImage.mas_left);
        }];
        
        self.procolTV = [[UITextView alloc] init];
        self.procolTV.attributedText = [self conentTextProtolString];;
        self.procolTV.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:kIntelligentMainHexColor]}; //
        self.procolTV.textColor = [UIColor colorWithHexString:@"#888888"];
        self.procolTV.delegate = self;
        self.procolTV.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
        self.procolTV.scrollEnabled = NO;
        [self.contentView addSubview:self.procolTV];
        [self.procolTV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(middleView.mas_left).offset(kTitleWidthPadding);
            make.right.equalTo(middleView.mas_right).offset(-kTitleWidthPadding);
            make.top.equalTo(topView.mas_bottom).offset(kContentViewPadding);
        }];
        
        self.procolHoldView = [[UIView alloc]init];
        [self.contentView addSubview:self.procolHoldView];
        [self.procolHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.procolTV.mas_bottom);
            make.height.mas_equalTo(60);
        }];
    }
    
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = kLineColor;
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(1);
        if (self.type == TIoTAlertViewContentTypeDatePick) {
            make.top.equalTo(middleView.mas_bottom).offset(0);
        }else {
            make.top.equalTo(self.procolHoldView.mas_bottom).offset(0);
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
        make.height.mas_equalTo(8);
    }];

    UIView *intervalView = [[UIView alloc]init];
    intervalView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [stack addArrangedSubview:intervalView];
    
}

- (void)hideAlertView {
    [self.blackMaskView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)initializationData:(TIoTAlertCustomViewContentType)contentType {
    self.messsageString = @"";
    self.dateString = @"";
    self.type = contentType;
}

- (void)drawRect:(CGRect)rect {
    [self changeViewRectConnerWithView:self.contentView withRect:CGRectMake(0, 0, kScreenWidth, CGRectGetHeight(self.contentView.frame)) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
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
//        _datePicker.frame = CGRectMake(0, 14, kScreenWidth, 272);
        _datePicker.datePickerMode = UIDatePickerModeDate;
        // 设置当前显示时间
        [_datePicker setDate:[NSDate date] animated:YES];
        
        self.dateString = [self getDateStringWithDate:[NSDate date]];
        
        //监听DataPicker的滚动
        [_datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _datePicker;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        __weak typeof(self)weakSelf = self;
        
        _bottomView.firstBlock = ^{
            [weakSelf hideAlertView];
            if (weakSelf.cancelBlock) {
                weakSelf.cancelBlock();
            }
        };
        
        _bottomView.secondBlock = ^{
            [weakSelf hideAlertView];
            if (weakSelf.confirmBlock) {
                weakSelf.confirmBlock(weakSelf.dateString);
            }
        };
        
    }
    return _bottomView;
}

- (NSMutableAttributedString *)conentTextProtolString {
    if (!_conentTextProtolString) {

        NSString *str1 = NSLocalizedString(@"device_shared_agree_1", @"通过将设备与腾讯连连连接，即表示您同意共享有关您设备和设备日志的信息，第三方可以根据其条款和政策使用该设备。\n有关更多信息，请阅读我们的");
        NSString *str2= NSLocalizedString(@"privacy_policy_lower_case", @"隐私政策");
        NSString *showStr = [NSString stringWithFormat:@"%@%@",str1,str2];
        
        NSRange range2 = [showStr rangeOfString:str2];
        NSMutableParagraphStyle *pstype = [[NSMutableParagraphStyle alloc] init];
        [pstype setAlignment:NSTextAlignmentLeft];
        [pstype setParagraphSpacing:10];
        NSMutableAttributedString *mastring = [[NSMutableAttributedString alloc] initWithString:showStr attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:[UIColor orangeColor],NSParagraphStyleAttributeName:pstype}];
        
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
