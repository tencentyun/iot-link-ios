//
//  TIoTCustomTimeSlider.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/12.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTimeModel : NSObject
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@end

@interface TIoTCustomTimeSlider : UIView
@property (nonatomic, assign) CGFloat currentValue; //当前值
@property (nonatomic, strong) NSArray <TIoTTimeModel *>* timeSegmentArray;
@end

NS_ASSUME_NONNULL_END
