//
//  TIoTDeviceSettingVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTIntelligentProductConfigModel.h"
#import "TIoTAutoIntelligentModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, IntelligentEnterType) {
    IntelligentEnterTypeManual,
    IntelligentEnterTypeAuto,
};

/**
 设备设置页面
 */
@interface TIoTDeviceSettingVC : UIViewController
@property (nonatomic, strong) TIoTDataTemplateModel *templateModel;
@property (nonatomic, strong) TIoTIntelligentProductConfigModel *productModel;  //创建的时候传
//@property (nonatomic, strong) NSMutableArray <TIoTIntelligentProductConfigModel*>*productModelArray; //保存的时候传递
@property (nonatomic, assign) BOOL isEdited;
@property (nonatomic, strong) TIoTPropertiesModel *editedModel;
@property (nonatomic, copy) NSString *valueString;
@property (nonatomic, assign) NSInteger editActionIndex;
@property (nonatomic, strong) NSMutableArray *actionOriginArray;
@property (nonatomic, strong) NSMutableArray *valueOriginArray;

@property (nonatomic, assign) IntelligentEnterType enterType; //
@property (nonatomic, assign) BOOL isAutoActionType;    //自动智能任务入口 (包含在自动智能enterType里 yes 任务入口，no 条件入口）

@end

NS_ASSUME_NONNULL_END
