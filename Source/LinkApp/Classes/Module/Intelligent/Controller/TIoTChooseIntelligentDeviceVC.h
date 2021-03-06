//
//  TIoTChooseIntelligentDeviceVC.h
//  LinkApp
//
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
@property (nonatomic, assign) BOOL deviceAutoChoiceEnterActionType;//自动智能中的任务(action)为YES,条件(condition)为NO; 手动也设置为yes
@property (nonatomic, assign) NSInteger actionCount; //action现有数组个数
@property (nonatomic, assign) NSInteger conditionCount; //condition现有数组个数
@end

NS_ASSUME_NONNULL_END
