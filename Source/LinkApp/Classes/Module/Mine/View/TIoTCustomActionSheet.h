//
//  TIoTCustomActionSheet.h
//  LinkApp
//
//  Created by ccharlesren on 2020/8/15.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CustomactionSheetBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCustomActionSheet : UIView

@property (nonatomic, copy) CustomactionSheetBlock choiceFahrenheitBlock;//转华氏温度
@property (nonatomic, copy) CustomactionSheetBlock choiceCelsiusBlock;//转摄氏温度

- (instancetype)initWithFrame:(CGRect)frame;

- (void)shwoActionSheetView;

@end

NS_ASSUME_NONNULL_END
