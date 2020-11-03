//
//  TIoTCustomSheetView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ChooseDelayTimerBlock)(void);
typedef void(^ChooseDeviceBlock)(void);

@interface TIoTCustomSheetView : UIView
@property (nonatomic, copy) ChooseDeviceBlock chooseIntelligentDeviceBlock;
@property (nonatomic, copy) ChooseDelayTimerBlock chooseDelayTimerBlock;
@end

NS_ASSUME_NONNULL_END
