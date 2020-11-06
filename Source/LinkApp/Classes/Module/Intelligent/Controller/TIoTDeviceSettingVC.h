//
//  TIoTDeviceSettingVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTIntelligentProductConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 设备设置页面
 */
@interface TIoTDeviceSettingVC : UIViewController
@property (nonatomic, strong) TIoTDataTemplateModel *templateModel;
@property (nonatomic, strong) TIoTIntelligentProductConfigModel *productModel;
@property (nonatomic, assign) BOOL isEdited;
@property (nonatomic, strong) TIoTPropertiesModel *editedModel;
@property (nonatomic, copy) NSString *valueString;
@end

NS_ASSUME_NONNULL_END
