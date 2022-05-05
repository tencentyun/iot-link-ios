//
//  TIoTResolutionRatioChoiceVC.h
//  LinkApp
//

/**
 选择分辨率
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIoTResolutionBlock)(NSInteger selectResolutionValue);
@interface TIoTResolutionRatioChoiceVC : UIViewController
@property (nonatomic, assign) NSInteger selectedResolutionHeight;
@property (nonatomic, copy) TIoTResolutionBlock resolutionBlock;
@end

NS_ASSUME_NONNULL_END
