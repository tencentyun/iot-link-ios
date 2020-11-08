//
//  TIoTChooseSliderValueView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCustomSlider : UISlider

@end

typedef void(^SliderTaskValueBlock)(NSString *valueString,TIoTPropertiesModel *model);

/**
 物模型 int 和 float 是slider滑动选择样式
 */
@interface TIoTChooseSliderValueView : UIView
@property (nonatomic, strong) TIoTPropertiesModel *model;
@property (nonatomic, copy) SliderTaskValueBlock sliderTaskValueBlock;
@end

NS_ASSUME_NONNULL_END
