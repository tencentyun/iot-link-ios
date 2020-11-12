//
//  TIoTAutoSettingRepeatTimingView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 自动智能-定时页面选择重复设置view
 */

typedef NS_ENUM(NSInteger,AutoIntelligentRepeatType) {
    AutoIntelligentRepeatTypeOnce,
    AutoIntelligentRepeatTypeEveryday,
    AutoIntelligentRepeatTypeWorkday,
    AutoIntelligentRepeatTypeWeekend,
    AutoIntelligentRepeatTypeCustom,
};

typedef void(^AutoIntelligentSettingRepeatBlcok)(NSString * _Nullable repeatingString,NSInteger selectedNumber,NSString * _Nullable dateIDString);

NS_ASSUME_NONNULL_BEGIN

@interface TIoTAutoSettingRepeatTimingView : UIView
@property (nonatomic, copy)AutoIntelligentSettingRepeatBlcok settingRepeatTimingBlcok;
@property (nonatomic, assign) NSInteger defaultRepeatTimeNum;
@property (nonatomic, copy) NSString *dateContentString; //用户选择星期的标识字符串 (回调给控制器，然后再传入，因为取消后，view释放，没法保存)
@end

NS_ASSUME_NONNULL_END
