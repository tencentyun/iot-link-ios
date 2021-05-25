//
//  TIoTDemoCustomSheetView.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/26.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TIoTDemoCustomSheetView;

typedef void(^ChooseSecondFunctionBlock)(void);
typedef void(^ChooseFirstFunctionBlock)(void);
typedef void(^ChooseFunctionBlock)(TIoTDemoCustomSheetView *view);

@interface TIoTDemoCustomSheetView : UIView
@property (nonatomic, copy) ChooseFirstFunctionBlock chooseFirstBlock;
@property (nonatomic, copy) ChooseSecondFunctionBlock chooseSecondBlock;
- (void)sheetViewTopTitleFirstTitle:(NSString *)firstString secondTitle:(NSString *)secondString;
- (void)sheetViewTopTitleArray:(NSArray <NSString*>*)titleArray withMatchBlocks:(NSArray<ChooseFunctionBlock>*)blockArray;
@end

NS_ASSUME_NONNULL_END
