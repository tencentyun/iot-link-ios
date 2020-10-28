//
//  TIoTWebVC+TIoTWebVCCategory.h
//  LinkApp
//
//  Created by ccharlesren on 2020/10/28.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTWebVC.h"

#import "TIoTResponseJSModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 原生通过jsBridge调用js
 */
@interface TIoTWebVC (TIoTWebVCCategory)

/**
 web 调用 h5
 */
- (void)webViewInvokeJavaScript:(TIoTResponseJSModel *)scriptString withWeb:(WKWebView *)webView;

/**
 事件透传
 */
- (void)webViewInvokeJavaScriptEvent:(NSString *)eventString withWeb:(WKWebView * _Nonnull)webView;

@end

NS_ASSUME_NONNULL_END
