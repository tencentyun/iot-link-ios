//
//  WCTextVC.m
//  TenextCloud
//
//  Created by Wp on 2019/11/12.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCTextVC.h"
#import <WebKit/WKWebView.h>

@interface WCTextVC ()

@end

@implementation WCTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"帮助";
    self.view.backgroundColor = kBgColor;
    
    if ([self.content isEqualToString:@"web"]) {
        WKWebView *web = [[WKWebView alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"wifi_type" ofType:@"html"];
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
        [self.view addSubview:web];
        [web mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    else
    {
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.text = self.content;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.trailing.mas_equalTo(-16);
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
            } else {
                make.top.mas_equalTo([WCUIProxy shareUIProxy].navigationBarHeight).offset(20);
            }
        }];
    }
}



@end
