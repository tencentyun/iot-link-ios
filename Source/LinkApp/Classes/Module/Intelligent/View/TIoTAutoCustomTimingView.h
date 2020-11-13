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

typedef NS_ENUM(NSInteger,AutoRepeatType) {
    AutoRepeatTypeTimer,
    AutoRepeatTypeEffectTimePeriod,
    
};

typedef void(^AutoSaveCustomTimerBlock)(NSArray *dateArray,NSArray *originWeekArray);

typedef void(^AutoKeepRecordSelectedBefore)(NSInteger defaultTimeNum);

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
@property (nonatomic, assign) AutoRepeatType autoRepeatType;  //判断是定时进入，还是生效时段进入
@property (nonatomic, assign) NSInteger defaultTimeNum;  //从控制器传入的，上一次选择的重复类型Index
@property (nonatomic, copy) AutoKeepRecordSelectedBefore autoKeepRecordSelectedBefore; //不保存返回，显示默认重复类型选项（控制器对应选项）
@end

NS_ASSUME_NONNULL_END
