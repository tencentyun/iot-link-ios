//
//  TIoTOpensourceLicenseViewController.m
//  LinkApp
//
//  Created by Sun on 2021/1/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTOpensourceLicenseViewController.h"
#import "TIoTOpensourceContentModel.h"

@interface TIoTOpensourceLicenseViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation TIoTOpensourceLicenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    //拉去静态配置文件（开源软件信息 或其他）
    [[TIoTRequestObject shared] get:self.urlPath success:^(id responseObject) {

        NSDictionary *opensourceDic = (NSDictionary *)responseObject;
        
        NSString *htmlContent = [opensourceDic objectForKey:@"filecontent"];
        [self.webView loadHTMLString:htmlContent baseURL:nil];
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {

    }];
}

@end
