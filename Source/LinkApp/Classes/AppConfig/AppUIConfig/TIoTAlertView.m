//
//  WCAlertView.m
//  TenextCloud
//
//

#import "TIoTAlertView.h"


@interface TIoTAlertView()<UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic) WCAlertViewStyle style;

@property (nonatomic,strong) UILabel *nameL;
@property (nonatomic,strong) UILabel *messageL;
@property (nonatomic,strong) UITextField *messageT;
@property (nonatomic,strong) UIButton *cancleBtn;
@property (nonatomic,strong) UIButton *doneBtn;
@property (nonatomic, strong) UIImage *successTopImage;

@property (nonatomic) CGRect oriFrame;
@property (nonatomic,strong) UIView *lineBtn;   //取消和确定两个按钮之间分割线
@property (nonatomic, strong) NSMutableAttributedString *conentTextProtolString;
@property (nonatomic, strong) UITextView *procolTV;
@property (nonatomic, strong)UIButton *procolBtn;
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

- (instancetype)initWithPricy:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.successTopImage = nil;
        [self setUpPricyViews];
    }
    return self;

}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message cancleTitlt:(NSString *)cancleTitlt doneTitle:(NSString *)doneTitle
{
    self.nameL.text = title;
    self.nameL.numberOfLines = 0;
    self.messageL.text = message;
    self.messageL.textAlignment = NSTextAlignmentCenter;
    self.messageT.placeholder = message;
    [self.cancleBtn setTitle:cancleTitlt forState:UIControlStateNormal];
    [self.doneBtn setTitle:doneTitle forState:UIControlStateNormal];
    if ([NSString isNullOrNilWithObject:doneTitle]) {
        self.doneBtn.hidden = YES;
        [self.cancleBtn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    }
}

- (void)setDefaultText:(NSString *)defaultText
{
    _defaultText = defaultText;
    self.messageT.text = defaultText;
}

- (void)setAlertViewContentAlignment:(TextAlignmentStyle)TextAlignmentStyle {
    switch (TextAlignmentStyle) {
        case TextAlignmentStyleCenter: {
            self.messageL.textAlignment = NSTextAlignmentCenter;
            break;
        }
        case TextAlignmentStyleLeft: {
            self.messageL.textAlignment = NSTextAlignmentLeft;
            break;
        }
        case TextAlignmentStyleRight: {
            self.messageL.textAlignment = NSTextAlignmentRight;
            break;
        }
        default:
            break;
    }
    
}

- (void)setConfirmButtonColor:(NSString *)hexString {
    [self.doneBtn setTitleColor:[UIColor colorWithHexString:hexString?:kIntelligentMainHexColor] forState:UIControlStateNormal];
}

- (void)setUpPricyViews {
    
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
//    name.font = [UIFont wcPfRegularFontOfSize:16];
    name.font = [UIFont boldSystemFontOfSize:16];
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
    
    self.procolTV = [[UITextView alloc] init];
    self.procolTV.attributedText = [self conentTextProtolString];;
    self.procolTV.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:kIntelligentMainHexColor]}; //
    self.procolTV.textColor = [UIColor colorWithHexString:@"#888888"];
    self.procolTV.delegate = self;
    self.procolTV.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
    self.procolTV.scrollEnabled = YES;
    [bgView addSubview:self.procolTV];
    [self.procolTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.equalTo(self.nameL.mas_bottom).offset(20);
        make.height.mas_equalTo(300);
    }];
    
    
    /*UITextView *procolTV1 = [[UITextView alloc] init];
    procolTV1.attributedText = [self protolStr];;
    procolTV1.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:kIntelligentMainHexColor]}; //
    procolTV1.textColor = [UIColor colorWithHexString:kRegionHexColor];
    procolTV1.delegate = self;
    procolTV1.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
    procolTV1.scrollEnabled = NO;
    procolTV1.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:procolTV1];
    [procolTV1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.procolTV.mas_bottom).offset(20);
//        make.centerX.equalTo(self.view).offset(15);
        make.left.equalTo(self.procolTV.mas_left).offset(27);
        make.right.equalTo(self.procolTV.mas_right);
    }];
    
    self.procolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.procolBtn addTarget:self action:@selector(procolClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.procolBtn setImage:[UIImage imageNamed:@"procolDefault"] forState:UIControlStateNormal];
    [self.procolBtn setImage:[UIImage imageNamed:@"agree_selected"] forState:UIControlStateSelected];
    [bgView addSubview:self.procolBtn];
    [self.procolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(procolTV1.mas_top).offset(4);
        make.width.height.mas_equalTo(30);
        make.right.equalTo(procolTV1.mas_left);
    }];*/
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = kLineColor;
    [bgView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(bgView);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.procolTV.mas_bottom).offset(20 *kScreenAllHeightScale);
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
    [btn setTitle:NSLocalizedString(@"register_privacy_policy_btn1", @"取消") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#6C7078"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 10;
    [stack addArrangedSubview:btn];
    self.cancleBtn = btn;
    
    self.lineBtn = [[UIView alloc]init];
    self.lineBtn.backgroundColor = kLineColor;
    [bgView addSubview:self.lineBtn];
    [self.lineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(btn);
        make.leading.equalTo(btn.mas_trailing);
        make.width.mas_equalTo(1);
    }];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:NSLocalizedString(@"register_privacy_policy_btn2", @"确定") forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor whiteColor]];
    btn2.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [btn2 addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    btn2.layer.cornerRadius = 10;
    [stack addArrangedSubview:btn2];
    self.doneBtn = btn2;
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
//    name.font = [UIFont wcPfRegularFontOfSize:16];
    name.font = [UIFont boldSystemFontOfSize:16];
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
    [btn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#6C7078"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 10;
    [stack addArrangedSubview:btn];
    self.cancleBtn = btn;
    
    self.lineBtn = [[UIView alloc]init];
    self.lineBtn.backgroundColor = kLineColor;
    [bgView addSubview:self.lineBtn];
    [self.lineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(btn);
        make.leading.equalTo(btn.mas_trailing);
        make.width.mas_equalTo(1);
    }];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:NSLocalizedString(@"confirm", @"确定") forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
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
    name.text = NSLocalizedString(@"room_name_tip", @"房间名称");
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
    [btn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
    [btn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:kRGBColor(230, 230, 230)];
    [btn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4;
    [stack addArrangedSubview:btn];
    self.cancleBtn = btn;
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:NSLocalizedString(@"confirm", @"确定") forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn2 setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
    [btn2 addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    btn2.layer.cornerRadius = 4;
    [stack addArrangedSubview:btn2];
    self.doneBtn = btn2;
    
}

- (void)showInView:(UIView *)superView
{
    [superView addSubview:self];
}

- (NSMutableAttributedString *)protolStr {
    NSString *str1 = NSLocalizedString(@"register_agree_1", @"同意并遵守腾讯云");
    NSString *str2 = NSLocalizedString(@"register_agree_2", @"用户协议");
    NSString *str3 = NSLocalizedString(@"register_agree_3", @"及");
    NSString *str4= NSLocalizedString(@"register_agree_4", @"隐私政策");
    NSString *showStr = [NSString stringWithFormat:@"%@%@%@%@",str1,str2,str3,str4];
    
    NSRange range1 = [showStr rangeOfString:str2];
    NSRange range2 = [showStr rangeOfString:str4];
    NSMutableParagraphStyle *pstype = [[NSMutableParagraphStyle alloc] init];
    [pstype setAlignment:NSTextAlignmentCenter];
    NSMutableAttributedString *mastring = [[NSMutableAttributedString alloc] initWithString:showStr attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:pstype}];
    
    NSString *valueString1 = [[NSString stringWithFormat:@"Privacy2://%@",str2] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *valueString2 = [[NSString stringWithFormat:@"Privacy4://%@",str4] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    [mastring addAttributes:@{NSLinkAttributeName:valueString1,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],} range:range1];
    [mastring addAttributes:@{NSLinkAttributeName:valueString2,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],} range:range2];
    return mastring;
}

- (NSMutableAttributedString *)conentTextProtolString {
    if (!_conentTextProtolString) {
        
        NSString *str1 = NSLocalizedString(@"register_privacy_policy_conte1", nil);
        NSString *str2 = NSLocalizedString(@"register_privacy_policy_conte2", @"用户协议");
        NSString *str3 = NSLocalizedString(@"register_privacy_policy_conte3", @"及");
        NSString *str4 = NSLocalizedString(@"register_privacy_policy_conte4", @"隐私政策");
        NSString *str5 = NSLocalizedString(@"register_privacy_policy_conte5", nil);
        NSString *str6 = NSLocalizedString(@"register_privacy_policy_conte6", @"腾讯连连App收集个人信息明示清单");
        NSString *str7 = NSLocalizedString(@"register_privacy_policy_conte7", nil);
        NSString *str8 = NSLocalizedString(@"register_privacy_policy_conte8", @"第三方sdk");
        NSString *str9 = NSLocalizedString(@"register_privacy_policy_conte9", nil);
        NSString *showStr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",str1,str2,str3,str4,str5,str6,str7,str8,str9];
        
        NSMutableParagraphStyle *pstype = [[NSMutableParagraphStyle alloc] init];
        [pstype setAlignment:NSTextAlignmentLeft];
        [pstype setParagraphSpacing:10];
        
        NSMutableAttributedString *mastring = [[NSMutableAttributedString alloc] initWithString:showStr attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:[UIColor orangeColor],NSParagraphStyleAttributeName:pstype}];
        
        NSString *valueString2 = [[NSString stringWithFormat:@"Privacy2://%@",str2] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSRange range2 = [showStr rangeOfString:str2];
        [mastring addAttributes:@{NSLinkAttributeName:valueString2,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],} range:range2];
        
        NSString *valueString4 = [[NSString stringWithFormat:@"Privacy4://%@",str4] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSRange range4 = [showStr rangeOfString:str4];
        [mastring addAttributes:@{NSLinkAttributeName:valueString4,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],} range:range4];
        
        NSString *valueString6 = [[NSString stringWithFormat:@"Privacy6://%@",str6] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSRange range6 = [showStr rangeOfString:str6];
        [mastring addAttributes:@{NSLinkAttributeName:valueString6,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],} range:range6];
        
        NSString *valueString8 = [[NSString stringWithFormat:@"Privacy8://%@",str8] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSRange range8 = [showStr rangeOfString:str8];
        [mastring addAttributes:@{NSLinkAttributeName:valueString8,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],} range:range8];
        
        _conentTextProtolString = mastring;
    }
    return _conentTextProtolString;
}

- (void)procolClick:(UIButton *)btn{
    btn.selected = !btn.selected;
}

#pragma mark uitextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    if ([[URL scheme] isEqualToString:@"Privacy2"]) {
        DDLogDebug(@"设备分享隐私");
        [self removeView];
        if (self.doneAction) {
            self.doneAction([URL scheme]);
        }
        return NO;
    }else if ([[URL scheme] isEqualToString:@"Privacy4"] || [[URL scheme] isEqualToString:@"Privacy6"] || [[URL scheme] isEqualToString:@"Privacy8"]) {
        [self removeView];
        if (self.doneAction) {
            self.doneAction([URL scheme]);
        }
        return NO;
    }
    return YES;
}

#pragma mark - event

- (void)cancle
{
    [self removeView];
    if (self.cancelAction) {
        self.cancelAction();
    }
}

- (void)done
{
//    if (self.procolBtn.selected) {
        
        [self removeView];
        if (self.doneAction) {
            self.doneAction(self.messageT.text);
        }
//    }else {
//        [MBProgressHUD showError:@"请点击同意按钮"];
//    }
}

- (void)removeView {
    [self.messageT resignFirstResponder];
    [self removeFromSuperview];
}

- (void)showSingleConfrimButton {
    self.cancleBtn.hidden = YES;
    self.lineBtn.hidden = YES;
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
