//
//  TIoTChooseDelayTimeVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ChangeDelayTimeBlcok)(NSString *timeString);

@protocol TIoTChooseDelayTimeVCDelegate <NSObject>

- (void)changeDelayTimeString:(NSString *)timeString;

@end
/**
 延迟 添加时间后再添加设备控制，设置物模型，添加task，完成场景
 */
@interface TIoTChooseDelayTimeVC : UIViewController
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, copy) ChangeDelayTimeBlcok changeDelayTimeBlcok;
@property (nonatomic, weak)id<TIoTChooseDelayTimeVCDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
