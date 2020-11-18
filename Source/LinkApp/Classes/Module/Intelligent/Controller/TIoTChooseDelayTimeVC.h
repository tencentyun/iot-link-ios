//
//  TIoTChooseDelayTimeVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AddDelayTimeBlcok)(NSString *timeString,NSString *hourStr,NSString *minu);

/**
 进入编辑后需调用
 */
@protocol TIoTChooseDelayTimeVCDelegate <NSObject>

- (void)changeDelayTimeString:(NSString *)timeString hour:(NSString *)hourString minuteString:(NSString *)min withAutoDelayIndex:(NSInteger)autoDelayIndex;

@end
/**
 延迟 添加时间后再添加设备控制，设置物模型，添加task，完成场景
 */
@interface TIoTChooseDelayTimeVC : UIViewController
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, copy) AddDelayTimeBlcok addDelayTimeBlcok; //新增延时task的需要实现
@property (nonatomic, weak)id<TIoTChooseDelayTimeVCDelegate>delegate;
@property (nonatomic, copy) NSString *autoDelayDateString; //自动智能-编辑时候传入
@property (nonatomic, assign) NSInteger autoEditedDelayIndex; //在自动智能-定时action数据中index
@end

NS_ASSUME_NONNULL_END
