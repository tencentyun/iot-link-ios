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

@interface TIoTCancelAccountVC ()
@property (nonatomic, strong) UILabel   *cancelTitle;
@property (nonatomic, strong) UILabel   *contentPart1;
@property (nonatomic, strong) UILabel   *contentPart2;
@property (nonatomic, strong) UILabel   *contentPart3;
@property (nonatomic, strong) UILabel   *contentPart4;
@property (nonatomic, strong) UIView    *bottomView;
@property (nonatomic, strong) UIButton  *protocolButton;
@property (nonatomic, strong) UIButton  *cancelButton;
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
    CGFloat kPadding = 25;
    
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
    
    
    [self.view addSubview:self.contentPart1];
    [self.contentPart1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cancelTitle.mas_bottom).offset(kSpace);
        make.leading.trailing.equalTo(self.cancelTitle);
        
    }];
    
    [self.view addSubview:self.contentPart2];
    [self.contentPart2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentPart1.mas_bottom).offset(kSpace);
        make.leading.trailing.equalTo(self.cancelTitle);
    }];
    
    [self.view addSubview:self.contentPart3];
    [self.contentPart3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentPart2.mas_bottom).offset(kSpace);
        make.leading.trailing.equalTo(self.cancelTitle);
    }];
    
    [self.view addSubview:self.contentPart4];
    [self.contentPart4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentPart3.mas_bottom).offset(kSpace);
        make.leading.trailing.equalTo(self.cancelTitle);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        }else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(100 * kScreenAllHeightScale);
    }];
    
    
}

- (UILabel *)cancelTitle {
    if (!_cancelTitle) {
        _cancelTitle = [[UILabel alloc]init];
        [self setContentLabelFormatWithLabel:_cancelTitle contentString:@"注销当前账号" textColour:nil textFont:[UIFont wcPfBoldFontOfSize:24]];
    }
    return _cancelTitle;
}

- (UILabel *)contentPart1 {
    if (!_contentPart1) {
        _contentPart1 = [[UILabel alloc]init];
        [self setContentLabelFormatWithLabel:_contentPart1 contentString:@"注销账号后，您的账号下所有信息和数据将被清空。" textColour:nil textFont:nil];
    }
    return _contentPart1;;
}

- (UILabel *)contentPart2 {
    if (!_contentPart2) {
        _contentPart2 = [[UILabel alloc]init];
        _contentPart2.numberOfLines = 0;
        [self setContentLabelFormatWithLabel:_contentPart2 contentString:@"如果您确定“注销账号”，账号将注销于\n2020-XX-XX 00:00:00" textColour:nil textFont:nil];
    }
    return _contentPart2;
}

- (UILabel *)contentPart3 {
    if (!_contentPart3) {
        _contentPart3 = [[UILabel alloc]init];
        _contentPart3.numberOfLines = 0;
        [self setContentLabelFormatWithLabel:_contentPart3 contentString:@"若您在注销日期前登录腾讯连连，则自动撤销“注销账号”申请。" textColour:nil textFont:nil];
    }
    return _contentPart3;
}

- (UILabel *)contentPart4 {
    if (!_contentPart4) {
        _contentPart4 = [[UILabel alloc]init];
        [self setContentLabelFormatWithLabel:_contentPart4 contentString:@"感谢您的使用！" textColour:nil textFont:nil];
    }
    return _contentPart4;
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
        [self setContentLabelFormatWithLabel:cancelProtocolLabel contentString:@"我已了解" textColour:nil textFont:nil];
        [_bottomView addSubview:cancelProtocolLabel];
        [cancelProtocolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.protocolButton.mas_centerY);
            make.leading.equalTo(self.protocolButton.mas_trailing).offset(kPadding/2 * kScreenAllWidthScale);
        }];
        
        UIButton *protocolDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [protocolDetailBtn setTitle:@"《腾讯连连账号注销协议》" forState:UIControlStateNormal];
        [protocolDetailBtn setTitleColor:kMainColor forState:UIControlStateNormal];
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
        UIImage *backImage = [UIImage makeRoundCornersWithRadius:20 withImage:[self gradientImageWithColors:@[[UIColor colorWithHexString:@"#FD8989"],[UIColor colorWithHexString:@"#FA5151"]] rect:CGRectMake(0, 0, (kScreenWidth - 32), 40 * kScreenAllHeightScale)]];
        [_cancelButton setBackgroundImage:backImage forState:UIControlStateNormal];
        _cancelButton.enabled = NO;
        [_cancelButton setTitle:@"注销" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        _cancelButton.layer.cornerRadius = 20;
        _contentPart1.layer.masksToBounds = YES;
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
    }else {

        self.cancelButton.enabled = NO;
    }

}

- (void)cancelProtocolClick {
    TIoTWebVC *vc = [TIoTWebVC new];
    vc.title = @"腾讯连连账号注销协议";
    #ifdef DEBUG
        NSMutableString *tempMutStr = [[NSMutableString alloc] initWithString:CancelAccountURL];
        [tempMutStr insertString:@"?uin=testReleaseID" atIndex:55];
        vc.urlPath = tempMutStr;
    #else
        vc.urlPath = CancelAccountURL;
    #endif
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancelAccountClick {
    WCLog(@"cancel account ");
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
