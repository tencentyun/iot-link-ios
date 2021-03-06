//
//  TIoTCustomTimeSlider.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTimeSetmentModel : NSObject
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@end

@interface TIoTCustomTimeSlider : UIView
@property (nonatomic, assign) CGFloat currentValue; //当前值
@property (nonatomic, strong) NSArray <TIoTTimeSetmentModel *>* timeSegmentArray;
@end

NS_ASSUME_NONNULL_END
