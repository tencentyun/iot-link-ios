//
//  TIoTSamplingReteChoiceVC.h
//  LinkApp
//

/**
 选择采样率
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIoTSamplingBlock)(NSInteger samlpingRateValue);
@interface TIoTSamplingReteChoiceVC : UIViewController
@property (nonatomic, assign) NSInteger samplingValue;
@property (nonatomic, copy) TIoTSamplingBlock samplingBlock;
@end

NS_ASSUME_NONNULL_END
