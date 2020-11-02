//
//  WCWebVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/19.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTWebVC.h"
#import <QuickLook/QLPreviewController.h>
#import "TIoTNavigationController.h"
#import "TIoTAppEnvironment.h"
#import "TIoTEvaluationSharedView.h"

#import "TIoTPanelMoreViewController.h"
#import "TIoTH5CallResultModel.h"
#import "YYModel.h"
#import "TIoTWebVC+TIoTWebVCCategory.h"

#import "TIoTDeviceDetailVC.h"
#import "TIoTDeviceShareVC.h"
#import "TIoTModifyRoomVC.h"

@interface TIoTWebVC () <WKUIDelegate, WKScriptMessageHandler>
@property (nonatomic, strong,readwrite) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSDictionary *bridgeMethodDic;
@end

@implementation TIoTWebVC

+(BOOL)accessInstanceVariablesDirectly {
    return NO;
}
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self == [super init]) {
        self.needJudgeJump = NO;
    }
    return self;
}

- (void)setUrlPath:(NSString *)urlPath {
    
    // Debug 就切到uin测试环境
//    if (TIoTAPPConfig.isDebug) {
        NSURLComponents *components = [NSURLComponents componentsWithString:urlPath];
        NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray arrayWithArray:components.queryItems];
        NSURLQueryItem *nameItem = [NSURLQueryItem queryItemWithName:@"uin" value:TIoTAPPConfig.GlobalDebugUin];
        [queryItems addObject:nameItem];
        components.queryItems = queryItems;
        
        _urlPath = components.URL.absoluteString;
//    }else {
//        //现网环境
//        _urlPath = urlPath;
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // addScriptMessageHandler 很容易导致循环引用
    // 控制器 强引用了WKWebView,WKWebView copy(强引用了）configuration， configuration copy （强引用了）userContentController
    // userContentController 强引用了 self （控制器）
    
    for (NSString *key in self.bridgeMethodDic.allKeys) {
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:key];
    }
    
    if (self.needRefresh) {
        [self refushEvaluationContent];
    }
    
    [self webViewInvokeJavaScript:@{@"name":@"pageShow"} port:@"emitEvent"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 因此这里要记得移除handlers
    
    [self webViewInvokeJavaScript:@{@"name":@"pageHide"} port:@"emitEvent"];
    
    for (NSString *key in self.bridgeMethodDic.allKeys) {
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:key];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //屏蔽左滑手势，面板中手势会有冲突
    self.fd_interactivePopDisabled = YES;
    
    if (self.requestTicketRefreshURLBlock) {
        self.requestTicketRefreshURLBlock(self);
    }
    
    NSURL *url;
    if (self.filePath) {
        url = [NSURL fileURLWithPath:self.filePath];
    }
    else
    {
        url = [NSURL URLWithString:self.urlPath];
    }
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    self.webView.UIDelegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        if (self.requestTicketRefreshURLBlock) {
            make.top.mas_equalTo(0);
        }else {
            make.top.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight);
        }
        make.bottom.mas_equalTo(0);
    }];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.tintColor = kMainColor;
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        if (self.requestTicketRefreshURLBlock) {
            make.top.mas_equalTo(0);
        }else {
            make.top.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight);
        }
        make.height.mas_equalTo(2);
    }];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [HXYNotice addLoginInTicketTokenListener:self reaction:@selector(LoginSuccessWithTicketToken:)];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    //APP 前后台切换，需要透传事件，在APPdelegate中添加了post通知
    [HXYNotice addAPPEnterForegroundLister:self reaction:@selector(appEnterForeground)];
    [HXYNotice addAPPEnterBackgroundLister:self reaction:@selector(appEnterBackground)];
    
}

- (void)nav_customBack {
    if ([self.webView canGoBack] && self.needJudgeJump) {
        [self.webView goBack];
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Public Methods
// 加载url
- (void)loadUrl:(NSString *)urlString {

    NSURL *url = [NSURL URLWithString:urlString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - KVO
// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            [self.progressView setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
            
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    } else if (object == self.webView && [keyPath isEqualToString:@"title"] && self.needJudgeJump) {
        NSLog(@"title change:%@", change);
        NSString *title = [change objectForKey:NSKeyValueChangeNewKey];
        if (!self.requestTicketRefreshURLBlock) {
            self.title = title;
        }
    }
}

- (void)LoginSuccessWithTicketToken:(NSNotification *)noti {
    NSString *ticket = noti.object;
    NSString *jsStr = [NSString stringWithFormat:@"LoginResult('%@')",ticket];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        WCLog(@"%@----%@",result, error);
    }];
}

#pragma mark - APP 切前后台透传事件
- (void)appEnterForeground {
    [self sendEventH5:@"appShow"];
    [self webViewInvokeJavaScript:@{@"name":@"pageShow"} port:@"emitEvent"];
}

- (void)appEnterBackground {
    [self webViewInvokeJavaScript:@{@"name":@"pageHide"} port:@"emitEvent"];
    [self sendEventH5:@"appHide"];
}

- (void)sendEventH5:(NSString *)eventString {
    NSString *event = eventString ? :@"";
    [self webViewInvokeJavaScript:@{@"name":event} port:@"emitEvent"];
}

//定点刷新评测内容
- (void)refushEvaluationContent {
    NSString *jsStr = [NSString stringWithFormat:@"pageShow('')"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        WCLog(@"%@----%@",result, error);
    }];
}

//新协议开发中
- (void)appEventWithH5Response:(NSString *)event {
    NSString *jsStr = [NSString stringWithFormat:@"%@('')",event];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        WCLog(@"%@----%@",result, error);
    }];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"have_known", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
//    message.body  --  Allowed types are NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull.
    NSLog(@"body:%@",message.body);
    
    NSString *responseMethodStirng = self.bridgeMethodDic[message.name];
    if (![NSString isNullOrNilWithObject:responseMethodStirng]) {
        if (!self) {
            return;
        }
        SEL methodSel = NSSelectorFromString(responseMethodStirng);
        IMP imp = [self methodForSelector:methodSel];
        void (*func)(id, SEL,id) = (void *)imp;
        func(self,methodSel,message);

    }
    
#warning 需要优化，这块的会调不能写这里。因为会调里面的会有其他参数，这里调过去后就js报错了，放在具体的bridge方法里做会调
//    if (![NSString isNullOrNilWithObject:message.body]) {
//        if (![NSString isNullOrNilWithObject:message.body[@"callbackId"]]) {
//            TIoTH5CallResultModel *model = [TIoTH5CallResultModel yy_modelWithJSON:message.body];
//            NSString *callbackIDString = model.callbackId ?:@"";
//            [self webViewInvokeJavaScript:@{@"result":@(YES),@"callbackId":callbackIDString} port:@"callResult"];
//        }
//    }
    
    
}

#pragma mark - 显示自定义分享view
- (void)showSharedViewWithMessage:(WKScriptMessage *)message {
    TIoTLog(@"弹框");
    TIoTEvaluationSharedView * shareView = [[TIoTEvaluationSharedView alloc]init];
    shareView.sharedFriendDic = self.sharedMessageDic;
    shareView.sharedPathString = self.sharedPathString;
    shareView.sharedURLString = self.sharedURLString;
    [self.view addSubview:shareView];
    [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale);
        }
        make.leading.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - 响应H5调用原生，JSBridge方法响应
- (void)loginWithMessage:(WKScriptMessage *)message {
    [[TIoTCoreUserManage shared] clear];
    UIViewController *loginVc = [NSClassFromString(@"TIoTVCLoginAccountVC") new];
    [loginVc setValue:@(YES) forKeyPath:@"isExpireAt"];
    TIoTNavigationController *vc = [[TIoTNavigationController alloc] initWithRootViewController:loginVc];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

//跳转详情页
- (void)displayEvaluationDetailWebViewWithURlMessage:(WKScriptMessage *)message {
    NSString *bodyUrlString = @"";
    if (![NSString isNullOrNilWithObject:message.body]) {
        bodyUrlString = message.body[@"url"] ? :@"";
    }
    
    NSArray *bodyUrlArray = [bodyUrlString componentsSeparatedByString:@"="];
    NSData *data = [bodyUrlArray.lastObject dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *bodyParamDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//    NSDictionary *itemParamDic =  @{@"articleId":bodyParamDic[@"ArticleId"],@"IsLike":bodyParamDic[@"IsLike"],@"LikeCount":bodyParamDic[@"LikeCount"],@"articleRoute":bodyParamDic[@"articleRoute"],@"articleTitle":bodyParamDic[@"articleTitle"]};
    NSString *itemParaString = [NSString objectToJson:bodyParamDic];
    NSString *itemJsonString = [NSString URLEncode:itemParaString];
    [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
    [[TIoTRequestObject shared] post:AppGetTokenTicket Param:@{} success:^(id responseObject) {
        
        WCLog(@"AppGetTokenTicket responseObject%@", responseObject);
        NSString *ticket = responseObject[@"TokenTicket"]?:@"";
        TIoTWebVC *vc = [TIoTWebVC new];
        NSString *url = nil;
        NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        url = [NSString stringWithFormat:@"%@/%@/#%@=%@&appID=%@&ticket=%@&uin=%@", [TIoTCoreAppEnvironment shareEnvironment].h5Url, H5Evaluation, bodyUrlArray.firstObject,itemJsonString,bundleId, ticket,TIoTAPPConfig.GlobalDebugUin];
        vc.sharedMessageDic = bodyParamDic;
        vc.sharedURLString = [NSString stringWithFormat:@"%@/%@/?uin=%@#%@=%@", [TIoTCoreAppEnvironment shareEnvironment].h5Url, H5Evaluation,TIoTAPPConfig.GlobalDebugUin,bodyUrlArray.firstObject,itemJsonString];
        vc.sharedPathString = [NSString stringWithFormat:@"pages/Index/TabPages/Evaluation/EvaluationDetail/EvaluationDetail?item=%@&ticket=%@&uin=%@",itemJsonString, ticket,TIoTAPPConfig.GlobalDebugUin];
        vc.urlPath = url;
        vc.needJudgeJump = YES;
        [self.navigationController pushViewController:vc animated:YES];
        [MBProgressHUD dismissInView:self.view];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD dismissInView:self.view];
    }];
}

- (void)goDeviceDetailWithMessage:(WKScriptMessage *)message {
    TIoTPanelMoreViewController *vc = [[TIoTPanelMoreViewController alloc] init];
    vc.title = @"设备详情";
    vc.deviceDic = self.deviceDic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goFeedBackWithMessage:(WKScriptMessage *)message {
    [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
    [[TIoTRequestObject shared] post:AppGetTokenTicket Param:@{} success:^(id responseObject) {

        WCLog(@"AppGetTokenTicket responseObject%@", responseObject);
        NSString *ticket = responseObject[@"TokenTicket"]?:@"";
        TIoTWebVC *vc = [TIoTWebVC new];
        NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        NSString *url = [NSString stringWithFormat:@"%@/%@/?appID=%@&ticket=%@#/pages/User/Feedback/Feedback", [TIoTCoreAppEnvironment shareEnvironment].h5Url, H5HelpCenter, bundleId, ticket];
        vc.urlPath = url;
        vc.needJudgeJump = YES;
        vc.needRefresh = YES;
        [self.navigationController pushViewController:vc animated:YES];
        [MBProgressHUD dismissInView:self.view];

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD dismissInView:self.view];
    }];
}

- (void)goDeviceInfoWithMessage:(WKScriptMessage *)message  {

    TIoTDeviceDetailVC *deviceDatailVC = [[TIoTDeviceDetailVC alloc]init];
    [self.navigationController pushViewController:deviceDatailVC animated:YES];
}

- (void)goEditDeviceNameWithMessage:(WKScriptMessage *)message {
    TIoTPanelMoreViewController *vc = [[TIoTPanelMoreViewController alloc] init];
    vc.title = @"设备详情";
    vc.deviceDic = self.deviceDic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goRoomSettingWithMessage:(WKScriptMessage *)message {
    TIoTModifyRoomVC *vc = [[TIoTModifyRoomVC alloc] init];
    vc.deviceInfo = self.deviceDic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goShareDeviceWithMessage:(WKScriptMessage *)message {
    TIoTDeviceShareVC *vc = [[TIoTDeviceShareVC alloc] init];
    vc.deviceDic = self.deviceDic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goNavBackWithMessage:(WKScriptMessage *)message {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadUnmountDeviceWithMessage:(WKScriptMessage *)message {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareConfigWithMessage:(WKScriptMessage *)message {
    
}

- (void)goFirmwareUpgradeWithMessage:(WKScriptMessage *)message {
    
}

#pragma mark - lazy loading

- (NSDictionary *)bridgeMethodDic {
    if (!_bridgeMethodDic) {
        
        _bridgeMethodDic = @{@"LoginApp":NSStringFromSelector(@selector(loginWithMessage:)),
                             @"goDetail":NSStringFromSelector(@selector(displayEvaluationDetailWebViewWithURlMessage:)),
                             @"onArticleShare":NSStringFromSelector(@selector(showSharedViewWithMessage:)),
                             @"goDeviceDetailPage":NSStringFromSelector(@selector(goDeviceDetailWithMessage:)),
                             @"goFeedBackPage":NSStringFromSelector(@selector(goFeedBackWithMessage:)),
                             @"goDeviceInfoPage":NSStringFromSelector(@selector(goDeviceInfoWithMessage:)),
                             @"goEditDeviceNamePage":NSStringFromSelector(@selector(goEditDeviceNameWithMessage:)),
                             @"goRoomSettingPage":NSStringFromSelector(@selector(goRoomSettingWithMessage:)),
                             @"goShareDevicePage":NSStringFromSelector(@selector(goShareDeviceWithMessage:)),
                             @"navBack":NSStringFromSelector(@selector(goNavBackWithMessage:)),
                             @"reloadAfterUnmount":NSStringFromSelector(@selector(reloadUnmountDeviceWithMessage:)),
                             @"setShareConfig":NSStringFromSelector(@selector(shareConfigWithMessage:)),
                             @"goFirmwareUpgradePage":NSStringFromSelector(@selector(goFirmwareUpgradeWithMessage:)),
                             
                             //蓝牙部分
                             @"openBluetoothAdapter":NSStringFromSelector(@selector(openBluetoothWithMessageWithMessage:)),
                             @"getBluetoothAdapterState":NSStringFromSelector(@selector(getBluetoothAdapterStateWithMessage:)),
                             @"startBluetoothDevicesDiscovery":NSStringFromSelector(@selector(startBluetoothDevicesDiscoveryWithMessage:)),
                             @"stopBluetoothDevicesDiscovery":NSStringFromSelector(@selector(stopBluetoothDevicesDiscoveryWithMessage:)),
                             @"getBluetoothDevices":NSStringFromSelector(@selector(getBluetoothDevicesWithMessage:)),
                             @"getConnectedBluetoothDevices":NSStringFromSelector(@selector(getConnectedBluetoothDevicesWithMessage:)),
                             @"getBLEDeviceRSSI":NSStringFromSelector(@selector(getBLEDeviceRSSIWithMessage:)),
                             @"createBLEConnection":NSStringFromSelector(@selector(createBLEConnectionWithMessage:)),
                             @"closeBLEConnection":NSStringFromSelector(@selector(closeBLEConnectionWithMessage:)),
                             @"getBLEDeviceServices":NSStringFromSelector(@selector(getBLEDeviceServicesWithMessage:)),
                             @"getBLEDeviceCharacteristics":NSStringFromSelector(@selector(getBLEDeviceCharacteristicsWithMessage:)),
                             @"readBLECharacteristicValue":NSStringFromSelector(@selector(readBLECharacteristicValueWithMessage:)),
                             @"writeBLECharacteristicValue":NSStringFromSelector(@selector(writeBLECharacteristicValueWithMessage:)),
                             @"notifyBLECharacteristicValueChange":NSStringFromSelector(@selector(notifyBLECharacteristicValueChangeWithMessage:)),
                             @"registerBluetoothDevice":NSStringFromSelector(@selector(registerBluetoothDeviceWithMessage:)),
                             @"bindBluetoothDevice":NSStringFromSelector(@selector(bindBluetoothDeviceWithMessage:))
                             
        };
    }
    return _bridgeMethodDic;
}
@end
