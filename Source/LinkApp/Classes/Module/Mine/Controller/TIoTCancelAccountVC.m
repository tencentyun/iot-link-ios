//
//  TIoTCancelAccountVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/8/3.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTCancelAccountVC.h"
#import "TIoTWebVC.h"
#import "UIImage+Ex.h"
#import "TIoTAppEnvironment.h"
#import "TIoTNavigationController.h"
#import "TIoTMainVC.h"
@import TrueTime;
#import "TIoTAppDelegate.h"

@interface TIoTCancelAccountVC ()
@property (nonatomic, strong) UILabel   *cancelTitle;
@property (nonatomic, strong) UILabel   *clearContentPart;
@property (nonatomic, strong) UILabel   *cancelTimePart;
@property (nonatomic, strong) UILabel   *withdrawApplicationPart;
@property (nonatomic, strong) UILabel   *endContentPart;
@property (nonatomic, strong) UIView    *bottomView;
@property (nonatomic, strong) UIButton  *protocolButton;
@property (nonatomic, strong) UIButton  *cancelButton;
@property (nonatomic, strong) UIImage   *selectedBackImage;
@property (nonatomic, strong) UIImage   *unSelectedBackImage;
@end

@implementation TIoTCancelAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
    
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"注销账号";
    
    CGFloat kSpace = 20;
    CGFloat kPadding = 20;
    
    [self.view addSubview:self.cancelTitle];
    [self.cancelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(kPadding * kScreenAllHeightScale);
        make.trailing.equalTo(self.view.mas_trailing).offset(-kPadding * kScreenAllHeightScale);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kSpace * kScreenAllHeightScale);
        }else {
            make.top.equalTo(self.view).offset(64 * kScreenAllHeightScale + kSpace * kScreenAllHeightScale);
        }
    }];
    
    
    [self.view addSubview:self.clearContentPart];
    [self.clearContentPart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cancelTitle.mas_bottom).offset(kSpace);
        make.leading.trailing.equalTo(self.cancelTitle);
        
    }];
    
    [self.view addSubview:self.cancelTimePart];
    [self.cancelTimePart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clearContentPart.mas_bottom).offset(kSpace);
        make.leading.trailing.equalTo(self.cancelTitle);
    }];
    
    [self.view addSubview:self.withdrawApplicationPart];
    [self.withdrawApplicationPart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cancelTimePart.mas_bottom).offset(kSpace);
        make.leading.trailing.equalTo(self.cancelTitle);
    }];
    
    [self.view addSubview:self.endContentPart];
    [self.endContentPart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.withdrawApplicationPart.mas_bottom).offset(kSpace);
        make.leading.trailing.equalTo(self.cancelTitle);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            if ([TIoTUIProxy shareUIProxy].iPhoneX) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }else {
                make.bottom.equalTo(self.view.mas_bottom).offset(- 35 * kScreenAllHeightScale);
            }
        }else {
            make.bottom.equalTo(self.view.mas_bottom).offset(- 35 * kScreenAllHeightScale);
        }
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(100 * kScreenAllHeightScale);
    }];
    
    TIoTAppDelegate *appDelegate = (TIoTAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSDate *now = [[appDelegate.timeClient referenceTime] now];
    if (now == nil) {
        now = [NSDate date];
    }
    
    int days = 7;
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSDate *appointDate = [now initWithTimeIntervalSinceNow: oneDay * days];
    NSString *appointDataString = [NSString converDataToFormat:@"yyyy-MM-dd" withData:appointDate];
    NSArray *dateArray = [appointDataString componentsSeparatedByString:@"-"];
    NSString *tempString = [NSString stringWithFormat:@"%@年%@月%@日 00:00:00",dateArray[0],dateArray[1],dateArray[2]];
    [self setContentLabelFormatWithLabel:self.cancelTimePart contentString:[NSString stringWithFormat:@"如果您确定“注销账号”，账号将注销于\n%@",tempString] textColour:nil textFont:[UIFont wcPfSemiboldFontOfSize:14]];
    
}

- (UILabel *)cancelTitle {
    if (!_cancelTitle) {
        _cancelTitle = [[UILabel alloc]init];
        [self setContentLabelFormatWithLabel:_cancelTitle contentString:NSLocalizedString(@"logout_must_know", @"注销须知") textColour:nil textFont:[UIFont wcPfBoldFontOfSize:24]];
    }
    return _cancelTitle;
}

- (UILabel *)clearContentPart {
    if (!_clearContentPart) {
        _clearContentPart = [[UILabel alloc]init];
        _clearContentPart.numberOfLines = 0;
        [self setContentLabelFormatWithLabel:_clearContentPart contentString:NSLocalizedString(@"logout_text_for_attention1", @"请您确保账号处于安全状态下且是本人申请注销。注销账号是不可恢复的操作，账号被注销后，您账号下的所有信息、数据将被永久删除，无法找回。为避免您的损失，请谨慎进行账号注销操作。") textColour:nil textFont:[UIFont wcPfSemiboldFontOfSize:14]];
    }
    return _clearContentPart;
}

- (UILabel *)cancelTimePart {
    if (!_cancelTimePart) {
        _cancelTimePart = [[UILabel alloc]init];
        _cancelTimePart.numberOfLines = 0;
        [self setContentLabelFormatWithLabel:_cancelTimePart contentString:@"如果您确定“注销账号”，账号将注销于\n2020年8月3日 00:00:00" textColour:nil textFont:[UIFont wcPfSemiboldFontOfSize:14]];
    }
    return _cancelTimePart;
}

- (UILabel *)withdrawApplicationPart {
    if (!_withdrawApplicationPart) {
        _withdrawApplicationPart = [[UILabel alloc]init];
        _withdrawApplicationPart.numberOfLines = 0;
        [self setContentLabelFormatWithLabel:_withdrawApplicationPart contentString:@"若您在注销日期前登录腾讯连连，则自动撤销“注销账号”申请。" textColour:nil textFont:[UIFont wcPfSemiboldFontOfSize:14]];
    }
    return _withdrawApplicationPart;
}

- (UILabel *)endContentPart {
    if (!_endContentPart) {
        _endContentPart = [[UILabel alloc]init];
        _endContentPart.numberOfLines = 0;
        [self setContentLabelFormatWithLabel:_endContentPart contentString: NSLocalizedString(@"logout_text_for_attention3", @"注：如腾讯连连账号是通过第三方软件（微信） 进行登录的，您所注销的账号仅影响腾讯连连内的账号与数据，并不会影响您在微信的账号信息。")  textColour:nil textFont:nil];
    }
    return _endContentPart;
}

- (UILabel *)setContentLabelFormatWithLabel:(UILabel *)contentLabel contentString:(NSString *)contentString textColour:(UIColor *)textColor textFont:(UIFont *)font {
    
    contentLabel.text = contentString ? contentString : @"注销账号";
    contentLabel.textColor = textColor ? textColor :[UIColor colorWithHexString:@"#15161A"];
    contentLabel.font = font ? font : [UIFont wcPfRegularFontOfSize:14];
    return contentLabel;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        CGFloat kSpace = 15;
        CGFloat kPadding = 20;
        
        UIView *line = [[UIView alloc]init];
        [_bottomView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(_bottomView);
            make.top.equalTo(_bottomView.mas_top);
            make.height.mas_equalTo(0.5 * kScreenAllHeightScale);
        }];
        
        [_bottomView addSubview:self.protocolButton];
        [self.protocolButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line.mas_bottom).offset(kSpace * kScreenAllHeightScale);
            make.leading.equalTo(_bottomView.mas_leading).offset(kPadding * kScreenAllHeightScale);
        }];
        
        UILabel *cancelProtocolLabel = [[UILabel alloc]init];
        [self setContentLabelFormatWithLabel:cancelProtocolLabel contentString:NSLocalizedString(@"already_known", @"我已了解") textColour:nil textFont:nil];
        [_bottomView addSubview:cancelProtocolLabel];
        [cancelProtocolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.protocolButton.mas_centerY);
            make.leading.equalTo(self.protocolButton.mas_trailing).offset(kPadding/2 * kScreenAllWidthScale);
        }];
        
        UIButton *protocolDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [protocolDetailBtn setTitle:NSLocalizedString(@"tencentll_account_logout_agreement", @"《腾讯连连账号注销协议》") forState:UIControlStateNormal];
        [protocolDetailBtn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        [protocolDetailBtn addTarget:self action:@selector(cancelProtocolClick) forControlEvents:UIControlEventTouchUpInside];
        protocolDetailBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_bottomView addSubview:protocolDetailBtn];
        [protocolDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cancelProtocolLabel.mas_trailing);
            make.centerY.equalTo(self.protocolButton.mas_centerY);
        }];
        
        UIView *line2 = [[UIView alloc]init];
        [_bottomView addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(line);
            make.top.equalTo(self.protocolButton.mas_bottom).offset(12 * kScreenAllHeightScale);
            make.height.mas_equalTo(0.5 * kScreenAllHeightScale);
        }];
        
        [_bottomView addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_bottomView.mas_leading).offset(16 * kScreenAllWidthScale);
            make.trailing.equalTo(_bottomView.mas_trailing).offset(-16 * kScreenAllWidthScale);
            make.top.equalTo(line2.mas_bottom).offset(12 * kScreenAllHeightScale);
            make.height.mas_equalTo(40 * kScreenAllHeightScale);
        }];
        
        
    }
    return _bottomView;
}

- (UIButton *)protocolButton {
    if (!_protocolButton) {
        _protocolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_protocolButton setImage:[UIImage imageNamed:@"procolDefault"] forState:UIControlStateNormal];
        [_protocolButton setImage:[UIImage imageNamed:@"procolSelect"] forState:UIControlStateSelected];
        [_protocolButton addTarget:self action:@selector(procolClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _protocolButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.selectedBackImage = [UIImage makeRoundCornersWithRadius:20 withImage:[self gradientImageWithColors:@[[UIColor colorWithHexString:@"#FD8989"],[UIColor colorWithHexString:@"#FA5151"]] rect:CGRectMake(0, 0, (kScreenWidth - 32), 40 * kScreenAllHeightScale)]];
        self.unSelectedBackImage = [UIImage makeRoundCornersWithRadius:20 withImage:[self gradientImageWithColors:@[[UIColor colorWithHexString:kNoSelectedHexColor],[UIColor colorWithHexString:kNoSelectedHexColor]] rect:CGRectMake(0, 0, (kScreenWidth - 32), 40 * kScreenAllHeightScale)]];
        [_cancelButton setBackgroundImage:self.unSelectedBackImage forState:UIControlStateNormal];
        _cancelButton.enabled = NO;
        [_cancelButton setTitle:NSLocalizedString(@"logout_text", @"注销")  forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        _cancelButton.layer.cornerRadius = 20;
        _clearContentPart.layer.masksToBounds = YES;
        [_cancelButton addTarget:self action:@selector(cancelAccountClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cancelButton;
}


#pragma mark - event
- (void)procolClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self checkCanceled];
}

- (void)checkCanceled {
    if (self.protocolButton.selected) {
        self.cancelButton.enabled = YES;
        [_cancelButton setBackgroundImage:self.selectedBackImage forState:UIControlStateNormal];
    }else {

        self.cancelButton.enabled = NO;
        [_cancelButton setBackgroundImage:self.unSelectedBackImage forState:UIControlStateNormal];
    }

}

- (void)cancelProtocolClick {
    TIoTWebVC *vc = [TIoTWebVC new];
    vc.title = @"腾讯连连账号注销协议";
    vc.urlPath = CancelAccountURL;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancelAccountClick {
    
    TIoTAlertView *modifyAlertView = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
    [modifyAlertView alertWithTitle:NSLocalizedString(@"confirm_to_cancel_account_title", @"确定注销账号吗") message:NSLocalizedString(@"confirm_to_cancel_account_content", @"注销后，此账户下的所有用户数据也将被永久删除")  cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"verify", @"确认")];
    modifyAlertView.doneAction = ^(NSString * _Nonnull text) {
        
        [self cacelAccountPostMehtod];
    };
    [modifyAlertView showInView:[[UIApplication sharedApplication] delegate].window];

}


- (void)cacelAccountPostMehtod {
    [[TIoTRequestObject shared] post:AppUserCancelAccount Param:@{} success:^(id responseObject) {
        
         TIoTAlertView *modifyAlertView = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:[UIImage imageNamed:@"success_icon"]];
        [modifyAlertView alertWithTitle:NSLocalizedString(@"cancel_account_request_success_title", @"账号已申请注销")  message:NSLocalizedString(@"cancel_account_request_success_content", @"如需撤销，请在7日内登录腾讯连连")  cancleTitlt:@"" doneTitle:NSLocalizedString(@"verify", @"确认")];
        [modifyAlertView showSingleConfrimButton];
        modifyAlertView.doneAction = ^(NSString * _Nonnull text) {
            
            [[TIoTAppEnvironment shareEnvironment] loginOut];
            TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTMainVC alloc] init]];
            self.view.window.rootViewController = nav;
        };
        [modifyAlertView showInView:[[UIApplication sharedApplication] delegate].window];
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

#pragma mark - private method
- (CAGradientLayer *)setGradientLayer:(UIColor*)startColor endColor:(UIColor*)endColor targetView:(UIView *)targetView alpha:(CGFloat)alpha{
    //初始化CAGradientlayer对象，使它的大小为UIView的大小
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = targetView.bounds;
    gradientLayer.cornerRadius = 20;
    gradientLayer.masksToBounds = YES;
    
    //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
//    [targetView.layer addSublayer:gradientLayer];
    
    //设置渐变区域的起始和终止位置（范围为0-1）
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    
    //设置颜色数组
    //    gradientLayer.colors = @[(__bridge id)[UIColor blueColor].CGColor,
    //                                  (__bridge id)[UIColor redColor].CGColor];
    gradientLayer.colors = @[(__bridge id)[startColor colorWithAlphaComponent:alpha].CGColor,
                             (__bridge id)[endColor colorWithAlphaComponent:alpha].CGColor];
    
    //设置颜色分割点（范围：0-1）
    gradientLayer.locations = @[@(0.5f), @(1.0f)];
    
    return gradientLayer;
}

- (UIImage *)gradientImageWithColors:(NSArray *)colors rect:(CGRect)rect
{
    if (!colors.count || CGRectEqualToRect(rect, CGRectZero)) {
        return nil;
    }

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];

    gradientLayer.frame = rect;
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(0.5, 1);
    NSMutableArray *mutColors = [NSMutableArray arrayWithCapacity:colors.count];
    for (UIColor *color in colors) {
        [mutColors addObject:(__bridge id)color.CGColor];
    }
    gradientLayer.colors = [NSArray arrayWithArray:mutColors];

    UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, gradientLayer.opaque, 0);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
