//
//  WCWebVC.h
//  TenextCloud
//
//  Created by Wp on 2019/12/19.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TIoTWebVC;
typedef void(^requestTicketRefreshURL)(TIoTWebVC *webController);

@interface TIoTWebVC : UIViewController

@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,copy) NSString *urlPath;
@property (nonatomic,assign) BOOL needJudgeJump;//需要判断跳转
@property (nonatomic,assign) BOOL needRefresh;//刷新当前页

- (void)loadUrl:(NSString *)urlString;
//定点刷新评测内容
- (void)refushEvaluationContent;
- (void)appEventWithH5Response:(NSString *)event;

@property (nonatomic, strong) NSDictionary *sharedMessageDic;
@property (nonatomic, strong) NSString *sharedURLString;
@property (nonatomic, strong) NSString *sharedPathString;
@property (nonatomic, copy) requestTicketRefreshURL requestTicketRefreshURLBlock;

@property (nonatomic, strong) NSMutableDictionary *deviceDic;//h5自定义面板
@property (nonatomic, strong,readonly) WKWebView *webView;

/**
 蓝牙部分
 */
/// 扫描蓝牙设备 自定义数据
@property (nonatomic, strong) NSMutableArray *peripheralInfoArray;


- (void)webViewInvokeJavaScript:(NSDictionary *)responseDic port:(NSString *)portString;
@end

NS_ASSUME_NONNULL_END
