//
//  TIoTCustomSheetView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ChooseSecondFunctionBlock)(void);
typedef void(^ChooseFirstFunctionBlock)(void);

@interface TIoTCustomSheetView : UIView
@property (nonatomic, copy) ChooseFirstFunctionBlock chooseIntelligentFirstBlock;
@property (nonatomic, copy) ChooseSecondFunctionBlock chooseIntelligentSecondBlock;
- (void)sheetViewTopTitleFirstTitle:(NSString *)firstString secondTitle:(NSString *)secondString;
@end

NS_ASSUME_NONNULL_END
