//
//  TIoTChooseSliderValueView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTAutoIntelligentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCustomSlider : UISlider

@end

typedef void(^SliderTaskValueBlock)(NSString *valueString,TIoTPropertiesModel *model,NSString *numberStr,NSString *compareValue);

/**
 物模型 int 和 float 是slider滑动选择样式
 */
@interface TIoTChooseSliderValueView : UIView
@property (nonatomic, strong) TIoTPropertiesModel *model;
@property (nonatomic, copy) SliderTaskValueBlock sliderTaskValueBlock;

@property (nonatomic, assign) NSInteger isAutoIntellignet;; //自动智能 0 手动 1自动
@property (nonatomic, assign) BOOL isActionType; // no condition yes action
@property (nonatomic, strong) TIoTAutoIntelligentModel *conditionModel; //编辑传入的model
@end

NS_ASSUME_NONNULL_END
