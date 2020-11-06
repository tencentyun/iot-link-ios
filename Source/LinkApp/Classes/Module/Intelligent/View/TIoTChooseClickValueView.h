//
//  TIoTChooseClickValueView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ChooseTaskValueBlock)(NSString *valueString,TIoTPropertiesModel *model);
/**
物模型 enum 和 bool 是 tableview 选择样式 高度 48+188=236
 */
@interface TIoTChooseClickValueView : UIView
@property (nonatomic, strong) TIoTPropertiesModel *model;
@property (nonatomic, copy) ChooseTaskValueBlock chooseTaskValueBlock;
@end

NS_ASSUME_NONNULL_END
