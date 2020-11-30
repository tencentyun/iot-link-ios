//
//  TIoTAutoEffectTimePriodView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/13.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 生效时间段自定义view
 */
NS_ASSUME_NONNULL_BEGIN
typedef void(^AutoGenerateTimePeriodBlock)(NSMutableDictionary *timePeriodDic,NSString *dayIDString);

typedef NS_ENUM(NSInteger, AutoEffectPeriodRepetaType) {
//    AutoEffectPeriodRepetaTypeOnce,
    AutoEffectPeriodRepetaTypeEveryday,
    AutoEffectPeriodRepetaTypeWorkday,
    AutoEffectPeriodRepetaTypeWeekend,
    AutoEffectPeriodRepetaTypeCustom
};

@interface TIoTAutoEffectTimePriodView : UIView
@property (nonatomic, assign) NSInteger defaultRepeatTimeNum;
@property (nonatomic, strong) NSString *dayIDString; //用户保存生效时间段view回传给控制器的dayIDString,再进入时间段再传入
@property (nonatomic, strong) NSMutableDictionary *effectTimeDic; //生效时间，时间周期 @{@"customTime":@"",@"repeatType":@""}
@property (nonatomic, copy) AutoGenerateTimePeriodBlock generateTimePeriodBlock;
@end

NS_ASSUME_NONNULL_END
