//
//  WCTipView.m
//  TenextCloud
//
//  Created by Wp on 2020/3/25.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCTipView.h"

@implementation WCTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = kRGBAColor(0, 0, 0, 0.7);
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 10;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(kScreenWidth - 60);
    }];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    [close addTarget:self action:@selector(shutDown) forControlEvents:UIControlEventTouchUpInside];
    [close setImage:[UIImage imageNamed:@"closeWindow"] forState:UIControlStateNormal];
    [bgView addSubview:close];
    [close mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.width.height.mas_equalTo(40);
    }];
    
    
    UILabel *name = [[UILabel alloc] init];
    name.text = @"设备已离线";
    name.textColor = kFontColor;
    name.textAlignment = NSTextAlignmentCenter;
    name.font = [UIFont boldSystemFontOfSize:20];
    [bgView addSubview:name];
    [name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.mas_equalTo(30);
        make.trailing.mas_equalTo(-20);
    }];
    
    
    UILabel *content = [[UILabel alloc] init];
    content.text = @"请检查：\n1.设备是否有电；\n\n2.设备连接的路由器是否正常工作,网络通畅；\n\n3.是否修改了路由器的名称或密码，可以尝试重新连接；\n\n4.设备是否与路由器距离过远、隔墙或有其他遮挡物。";
    content.numberOfLines = 0;
    content.textColor = kFontColor;
    content.font = [UIFont systemFontOfSize:16];
    [bgView addSubview:content];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.equalTo(name.mas_bottom).offset(20);
        make.trailing.mas_equalTo(-20);
    }];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"问题反馈" forState:UIControlStateNormal];
    [btn setTitleColor:kMainColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn addTarget:self action:@selector(toFeedback) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4;
    [bgView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.equalTo(content.mas_bottom).offset(30);
        make.trailing.mas_equalTo(-20);
        make.height.mas_equalTo(44);
    }];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"返回首页" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn2 setBackgroundColor:kMainColor];
    [btn2 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    btn2.layer.cornerRadius = 4;
    [bgView addSubview:btn2];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.equalTo(btn.mas_bottom).offset(20);
        make.trailing.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
        make.height.mas_equalTo(44);
    }];
    
}

- (void)showInView:(UIView *)superView
{
    self.frame = superView.frame;
    [superView addSubview:self];
}

- (void)toFeedback
{
    if (self.feedback) {
        self.feedback();
    }
}

- (void)goBack
{
    if (self.navback) {
        self.navback();
    }
}

- (void)shutDown
{
    [self removeFromSuperview];
}

@end
