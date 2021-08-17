//
//  TIoTWebVC+TIoTWebVCCategory.m
//  LinkApp
//
//

#import "TIoTWebVC+TIoTWebVCCategory.h"

@implementation TIoTWebVC (TIoTWebVCCategory)

- (void)webViewInvokeJavaScript:(NSDictionary *)responseDic port:(NSString *)portString {
    if (![NSObject isNullOrNilWithObject:responseDic] && ![NSString isNullOrNilWithObject:portString]) {
        NSString *jsJsonString = [NSString objectToJson:responseDic];
        NSString *jsStr = [NSString stringWithFormat:@"JSBridge.callH5('%@','%@')",portString,jsJsonString];
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            DDLogVerbose(@"%@----%@",result, error);
        }];
    }
}

@end
