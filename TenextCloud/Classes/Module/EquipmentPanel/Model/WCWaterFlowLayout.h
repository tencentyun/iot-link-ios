//
//  WCWaterFlowLayout.h
//  TenextCloud
//
//  Created by Wp on 2020/1/2.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WCWaterFlowLayout;

@protocol WCWaterFlowLayoutDelegate <NSObject>

- (CGSize)waterFlowLayout:(WCWaterFlowLayout *)waterFlowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/** 头视图Size */
-(CGSize )waterFlowLayout:(WCWaterFlowLayout *)waterFlowLayout sizeForHeaderViewInSection:(NSInteger)section;
/** 脚视图Size */
-(CGSize )waterFlowLayout:(WCWaterFlowLayout *)waterFlowLayout sizeForFooterViewInSection:(NSInteger)section;

/** 列间距*/
-(CGFloat)minSpaceForLines:(WCWaterFlowLayout *)waterFlowLayout;
/** 行间距*/
-(CGFloat)minSpaceForCells:(WCWaterFlowLayout *)waterFlowLayout;
/** 边缘之间的间距*/
-(UIEdgeInsets)edgeInsetInWaterFlowLayout:(WCWaterFlowLayout *)waterFlowLayout;

@end

@interface WCWaterFlowLayout : UICollectionViewLayout

@property (nonatomic, weak) id<WCWaterFlowLayoutDelegate> delegate;

@end
