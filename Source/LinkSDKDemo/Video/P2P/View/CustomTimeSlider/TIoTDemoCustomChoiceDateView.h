//
//  TIoTDemoCustomChoiceDateView.h
//  LinkSDKDemo
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTimeModel : NSObject
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@end

typedef void(^TIoTDemoChooseDateBlock)(UIButton *button);
typedef void(^TIoTDemoPreviousDateSegemtnBlock)(TIoTTimeModel *preTimeModel);
typedef void(^TIoTDemoNextDateSegmentBlock)(TIoTTimeModel *nextTimeModel);
typedef void(^TIoTDemoSelectedTimeModelBlock)(TIoTTimeModel *selectedTimeModel, CGFloat startTimestamp);

/**
 自定义滑动事件选择控件
 */

@interface TIoTDemoCustomChoiceDateView : UIView
@property (nonatomic, strong) NSArray *videoTimeSegmentArray;

/// 从日历中选日期
@property (nonatomic, copy) TIoTDemoChooseDateBlock chooseDateBlock; 

/// 选择前一个事件，获取开始/结束时间戳
@property (nonatomic, copy) TIoTDemoPreviousDateSegemtnBlock previousDateBlcok;

/// 选择后一个事件，获取开始/结束时间戳
@property (nonatomic, copy) TIoTDemoNextDateSegmentBlock nextDateBlcok;

/// 滑动停止后，获取当前值所在事件开始/结束时间戳
@property (nonatomic, copy) TIoTDemoSelectedTimeModelBlock timeModelBlock;

/// 设置日期
/// @param dayDateString 日期字符串:格式 "2020-1-1"
- (void)resetSelectedDate:(NSString *)dayDateString;

/// 设置滑动条滚动偏移量
/// @param offsetX 横向偏移坐标
- (void)setScrollViewContentOffsetX:(CGFloat)offsetX currtentSecond:(NSInteger)currentSecond;

@end

NS_ASSUME_NONNULL_END
