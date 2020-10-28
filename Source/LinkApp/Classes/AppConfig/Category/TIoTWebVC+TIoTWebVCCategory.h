//
//  TIoTWebVC+TIoTWebVCCategory.h
//  LinkApp
//
//  Created by ccharlesren on 2020/10/28.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTWebVC.h"


NS_ASSUME_NONNULL_BEGIN

/**
 原生与H5交互
 */
@interface TIoTWebVC (TIoTWebVCCategory)

- (void)webViewInvokeJavaScript:(NSDictionary *)responseDic port:(NSString *)portString withWeb:(WKWebView *)webView;

@end

NS_ASSUME_NONNULL_END
