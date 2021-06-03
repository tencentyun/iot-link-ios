//
//  TIoTDemoCustomChoiceDateView.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/3.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTimeModel : NSObject
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@end

typedef void(^TIoTDemoChooseDateBlock)(UIButton *button);
typedef void(^TIoTDemoPreviousDateSegemtnBlock)(void);
typedef void(^TIoTDemoNextDateSegmentBlock)(void);
typedef void(^TIoTDemoSelectedTimeModelBlock)(TIoTTimeModel *selectedTimeModel, CGFloat startTimestamp);

@interface TIoTDemoCustomChoiceDateView : UIView
@property (nonatomic, strong) NSArray *videoTimeSegmentArray;
@property (nonatomic, copy) TIoTDemoChooseDateBlock chooseDateBlock; //日历选择日期
@property (nonatomic, copy) TIoTDemoPreviousDateSegemtnBlock previousDateBlcok; //前事件
@property (nonatomic, copy) TIoTDemoNextDateSegmentBlock nextDateBlcok; //后事件
@property (nonatomic, copy) TIoTDemoSelectedTimeModelBlock timeModelBlock;
@end

NS_ASSUME_NONNULL_END
