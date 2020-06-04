//
//  WCWebVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/19.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCWebVC.h"
#import <WebKit/WebKit.h>
#import <QuickLook/QLPreviewController.h>


@interface WCWebVC ()

@end

@implementation WCWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url;
    if (self.filePath) {
        url = [NSURL fileURLWithPath:self.filePath];
    }
    else
    {
        url = [NSURL URLWithString:self.urlPath];
    }
    
    WKWebView *web = [[WKWebView alloc] init];
    [web loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:web];
    [web mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo([WCUIProxy shareUIProxy].navigationBarHeight);
        make.bottom.mas_equalTo(0);
    }];
    
}



@end
