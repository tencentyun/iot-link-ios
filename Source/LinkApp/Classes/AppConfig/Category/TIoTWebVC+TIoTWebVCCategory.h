//
//  TIoTWebVC+TIoTWebVCCategory.h
//  LinkApp
//
//

#import "TIoTWebVC.h"


NS_ASSUME_NONNULL_BEGIN

/**
 原生与H5交互
 */
@interface TIoTWebVC (TIoTWebVCCategory)

- (void)webViewInvokeJavaScript:(NSDictionary *)responseDic port:(NSString *)portString;

@end

NS_ASSUME_NONNULL_END
