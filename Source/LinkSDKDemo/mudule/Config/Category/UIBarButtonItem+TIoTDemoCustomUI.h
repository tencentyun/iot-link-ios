//
//  UIBarButtonItem+TIoTDemoCustomUI.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (TIoTDemoCustomUI)
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image selectImage:(NSString *)selectImage;
@end

NS_ASSUME_NONNULL_END
