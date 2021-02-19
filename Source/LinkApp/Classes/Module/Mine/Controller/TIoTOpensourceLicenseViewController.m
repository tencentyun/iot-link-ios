//
//  TIoTOpensourceLicenseViewController.m
//  LinkApp
//
//  Created by Sun on 2021/1/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTOpensourceLicenseViewController.h"
#import "TIoTOpensourceContentModel.h"

@interface TIoTOpensourceLicenseViewController () <WKNavigationDelegate>

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
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    //拉去静态配置文件（开源软件信息 或其他）
    [self loadUrl:self.urlPath];
}

- (void)loadUrl:(NSString *)urlString {
    [[TIoTRequestObject shared] get:urlString success:^(id responseObject) {

        NSDictionary *opensourceDic = (NSDictionary *)responseObject;
        
        NSString *htmlContent = [opensourceDic objectForKey:@"filecontent"];
        [self.webView loadHTMLString:htmlContent baseURL:nil];
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {

    }];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // 获取完整url并进行UTF-8转码
        NSString *strRequest = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];
        if ([strRequest hasPrefix:@"https://imgcache.qq.com/qzone/qzactStatics/qcloud/data"]) {
            // 拦截点击链接
            if ([self needHandleURL:strRequest]) {
                [self loadUrl:strRequest];
                // 不允许跳转
                decisionHandler(WKNavigationActionPolicyCancel);
            } else {
                // 允许跳转
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        }else {
            // 允许跳转
            decisionHandler(WKNavigationActionPolicyAllow);
            
        }
}

- (BOOL)needHandleURL:(NSString *)URL
{
    if ([URL hasPrefix:TIoTAPPConfig.opensourceLicenseString]) {
        // 开源协议信息(英文)
        return YES;
    }else if ([URL hasPrefix:TIoTAPPConfig.privacyPolicyEnglishString]) {
        // 隐私政策(英文)
        return YES;
    }else if ([URL hasPrefix:TIoTAPPConfig.serviceAgreementEnglishString]) {
        // 服务协议(英文)
        return YES;
    }
    return NO;
}

@end
