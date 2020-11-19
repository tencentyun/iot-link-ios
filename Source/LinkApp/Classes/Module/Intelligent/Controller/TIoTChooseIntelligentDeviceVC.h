//
//  TIoTChooseIntelligentDeviceVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTAutoIntelligentModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DeviceChoiceEnterType) {
    DeviceChoiceEnterTypeManual,
    DeviceChoiceEnterTypeAuto,
};
/**
 设备控制 选择设备后设置物模型，添加task，完成场景
 */
@interface TIoTChooseIntelligentDeviceVC : UIViewController

@property (nonatomic, strong) NSString *roomId;

@property (nonatomic, strong) NSMutableArray *actionOriginArray;
@property (nonatomic, strong) NSMutableArray *valueOriginArray;
@property (nonatomic, assign) DeviceChoiceEnterType enterType;
@property (nonatomic, assign) BOOL deviceAutoChoiceEnterActionType;//自动智能中的任务(action)为YES,条件(condition)为NO;
@end

NS_ASSUME_NONNULL_END
