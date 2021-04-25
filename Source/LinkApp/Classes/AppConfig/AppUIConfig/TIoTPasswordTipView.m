//
//  TIoTPasswordTipView.m
//  LinkApp
//
//  Created by ccharlesren on 2021/4/25.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTPasswordTipView.h"
#import "UIImage+Ex.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTPasswordTipView ()
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImageView *tipImage;
@property (nonatomic, strong) UILabel   *tipLabel;
@end

@implementation TIoTPasswordTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUIViews];
    }
    return self;
}

- (void)setUIViews {
    
    CGFloat kTipImageWidthOrHeight = 20;
    CGFloat kLeftPadding = 16;
    CGFloat kHeight = 40;
    
//    UIImage *backgroundImage = [UIImage getGradientImageWithColors:@[[UIColor colorWithHexString:@"#FD8989"],[UIColor colorWithHexString:kSignoutHexColor]] imgSize:CGSizeMake(kScreenWidth, kHeight)];
    
    UIImage *backgroundImage = [self gradientImageWithColors:@[[UIColor colorWithHexString:@"#FD8989"],[UIColor colorWithHexString:kSignoutHexColor]] rect:CGRectMake(0, 0, kScreenWidth, kHeight)];
    
    self.backgroundImage = [[UIImageView alloc]init];
    self.backgroundImage.image = backgroundImage;
    [self addSubview:self.backgroundImage];
    [self.backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self);
    }];
    
    self.tipImage = [[UIImageView alloc]init];
    self.tipImage.image = [UIImage imageNamed:@"log_success"];
    [self addSubview:self.tipImage];
    [self.tipImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kTipImageWidthOrHeight);
        make.left.equalTo(self.mas_left).offset(kLeftPadding);
        make.centerY.equalTo(self);
    }];
    
    self.tipLabel = [[UILabel alloc]init];
    [self.tipLabel setLabelFormateTitle:NSLocalizedString(@"password_style", @"密码支持8-16位，必须包含字母和数字") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
    [self addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipImage.mas_right).offset(8);
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-kLeftPadding);
    }];
}

- (UIImage *)gradientImageWithColors:(NSArray *)colors rect:(CGRect)rect
{
    if (!colors.count || CGRectEqualToRect(rect, CGRectZero)) {
        return nil;
    }

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];

    gradientLayer.frame = rect;
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 1);
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
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
