//
//  WCWaterFlowLayout.h
//  TenextCloud
//
//  Created by Wp on 2020/1/2.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TIoTWaterFlowLayout;

@protocol WCWaterFlowLayoutDelegate <NSObject>

- (CGSize)waterFlowLayout:(TIoTWaterFlowLayout *)waterFlowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/** 头视图Size */
-(CGSize )waterFlowLayout:(TIoTWaterFlowLayout *)waterFlowLayout sizeForHeaderViewInSection:(NSInteger)section;
/** 脚视图Size */
-(CGSize )waterFlowLayout:(TIoTWaterFlowLayout *)waterFlowLayout sizeForFooterViewInSection:(NSInteger)section;

/** 列间距*/
-(CGFloat)minSpaceForLines:(TIoTWaterFlowLayout *)waterFlowLayout;
/** 行间距*/
-(CGFloat)minSpaceForCells:(TIoTWaterFlowLayout *)waterFlowLayout;
/** 边缘之间的间距*/
-(UIEdgeInsets)edgeInsetInWaterFlowLayout:(TIoTWaterFlowLayout *)waterFlowLayout;

@end

@interface TIoTWaterFlowLayout : UICollectionViewLayout

@property (nonatomic, weak) id<WCWaterFlowLayoutDelegate> delegate;

@end
