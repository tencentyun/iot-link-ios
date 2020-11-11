//
//  TIoTCustomSheetView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTCustomSheetView;

typedef void(^ChooseSecondFunctionBlock)(void);
typedef void(^ChooseFirstFunctionBlock)(void);
typedef void(^ChooseFunctionBlock)(TIoTCustomSheetView *view);

@interface TIoTCustomSheetView : UIView
@property (nonatomic, copy) ChooseFirstFunctionBlock chooseIntelligentFirstBlock;
@property (nonatomic, copy) ChooseSecondFunctionBlock chooseIntelligentSecondBlock;
- (void)sheetViewTopTitleFirstTitle:(NSString *)firstString secondTitle:(NSString *)secondString;
- (void)sheetViewTopTitleArray:(NSArray <NSString*>*)titleArray withMatchBlocks:(NSArray<ChooseFunctionBlock>*)blockArray;
@end

NS_ASSUME_NONNULL_END
