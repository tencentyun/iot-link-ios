//
//  UIImageView+TIoTDemoWebImage.h
//  LinkSDKDemo
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (TIoTDemoWebImage)
- (void)setImageWithURLStr:(NSString *_Nullable)str placeHolder:(NSString *_Nullable)placeHolder;
@end

NS_ASSUME_NONNULL_END
