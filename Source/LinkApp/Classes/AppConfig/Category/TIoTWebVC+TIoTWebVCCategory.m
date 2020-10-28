//
//  TIoTWebVC+TIoTWebVCCategory.m
//  LinkApp
//
//  Created by ccharlesren on 2020/10/28.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTWebVC+TIoTWebVCCategory.h"

@implementation TIoTWebVC (TIoTWebVCCategory)
- (void)webViewInvokeJavaScript:(TIoTResponseJSModel *)responseModel withWeb:(WKWebView *)webView {
    if (![NSString isNullOrNilWithObject:responseModel.callbackId]) {
        NSDictionary *paramDic = @{@"result":@(YES),@"callbackId":responseModel.callbackId};
        NSString *jsJsonString = [NSString objectToJson:paramDic];
        NSString *jsStr = [NSString stringWithFormat:@"JSBridge.callH5('callResult', '%@')",jsJsonString];
        [webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            WCLog(@"%@----%@",result, error);
        }];
    }
}

- (void)webViewInvokeJavaScriptEvent:(NSString *)eventString withWeb:(WKWebView * _Nonnull)webView {
    if (![NSString isNullOrNilWithObject:eventString]) {
        NSDictionary *paramDic = @{@"name":eventString};
        NSString *jsJsonString = [NSString objectToJson:paramDic];
        NSString *jsStr = [NSString stringWithFormat:@"JSBridge.callH5('emitEvent', '%@')",jsJsonString];
        [webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            WCLog(@"%@----%@",result, error);
        }];
    }
}

@end
