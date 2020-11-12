//
//  TIoTAutoCustomTimingView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 自动智能-自定义时间（周一至周天）view
 */
NS_ASSUME_NONNULL_BEGIN

typedef void(^AutoSaveCustomTimerBlock)(NSArray *dateArray,NSArray *originWeekArray);

typedef NS_ENUM(NSInteger, AutoInteSelectedRepeatType) {
    AutoInteSelectedRepeatTypeOnce,
    AutoInteSelectedRepeatTypeEveryday,
    AutoInteSelectedRepeatTypeWorkday,
    AutoInteSelectedRepeatTypeWeekend,
    AutoInteSelectedRepeatTypeCustom
}; 

@interface TIoTAutoCustomTimingView : UIView
@property (nonatomic, assign) NSInteger selectedRepeatIndexNumber;
@property (nonatomic, copy) AutoSaveCustomTimerBlock saveCustomTimerBlock;
@property (nonatomic, strong) NSArray *dateIDArray;
@end

NS_ASSUME_NONNULL_END
