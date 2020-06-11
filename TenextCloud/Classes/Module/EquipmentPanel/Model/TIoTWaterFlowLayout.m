//
//  WCWaterFlowLayout.m
//  TenextCloud
//
//  Created by Wp on 2020/1/2.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTWaterFlowLayout.h"

/** 每一列之间的间距*/
static const NSInteger WSLDefaultColumeMargin = 10;
/** 每一行之间的间距*/
static const CGFloat WSLDefaultRowMargin = 10;
/** 边缘之间的间距*/
static const UIEdgeInsets WSLDefaultEdgeInset = {10, 10, 10, 10};

///** 每一行之间的间距*/
//static const CGSize WSLDefaultHeaderSize = CGSizeMake(0, 66);
///** 每一行之间的间距*/
//static const CGSize WSLDefaultFooterSize = CGSizeMake(0, 66);


@interface TIoTWaterFlowLayout ()

/** 存放所有cell的布局属性*/
@property (strong, nonatomic) NSMutableArray *attrsArray;

/// 上一个块的frame
@property (nonatomic, assign) CGRect lastItemFrame;

///行间距
-(CGFloat)minSpaceForLines;
/// 块之间间距
-(CGFloat)minSpaceForCells;
/** 边缘之间的间距*/
-(UIEdgeInsets)edgeInsets;

@end

@implementation TIoTWaterFlowLayout

#pragma mark - 重写系统方法

/** 初始化 生成每个视图的布局信息*/
-(void)prepareLayout {
    
    [super prepareLayout];
    
    //清除之前数组
    [self.attrsArray removeAllObjects];
    
    //开始创建每一组cell的布局属性
    NSInteger sectionCount =  [self.collectionView numberOfSections];
    for(NSInteger section = 0; section < sectionCount; section++){
        
        //获取每一组头视图header的UICollectionViewLayoutAttributes
        if([self.delegate respondsToSelector:@selector(waterFlowLayout:sizeForHeaderViewInSection:)]){
            UICollectionViewLayoutAttributes *headerAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            
            if (headerAttrs.frame.size.height > 0) {
                [self.attrsArray addObject:headerAttrs];
            }
        }
        
        //开始创建组内的每一个cell的布局属性
        NSInteger rowCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger row = 0; row < rowCount; row++) {
            //创建位置
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:section];
            //获取indexPath位置cell对应的布局属性
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.attrsArray addObject:attrs];
        }
        
        //获取每一组脚视图footer的UICollectionViewLayoutAttributes
//        if([self.delegate respondsToSelector:@selector(waterFlowLayout:sizeForFooterViewInSection:)]){
//            UICollectionViewLayoutAttributes *footerAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
//            [self.attrsArray addObject:footerAttrs];
//        }
        
    }
}

/** 决定一段区域所有cell和头尾视图的布局属性*/
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

/** 返回indexPath位置cell对应的布局属性*/
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    //设置布局属性
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes  layoutAttributesForCellWithIndexPath:indexPath];
    
    attrs.frame = [self to_itemFrameOfHorizontalGridWaterFlow:indexPath];
    
    return attrs;
}

/** 返回indexPath位置头和脚视图对应的布局属性*/
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *attri;
    
    if ([UICollectionElementKindSectionHeader isEqualToString:elementKind]) {
        
        //头视图
        attri = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
        
        attri.frame = [self headerViewFrameOfVerticalWaterFlow:indexPath];
        
    }else {
        
        //脚视图
        attri = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:indexPath];
        
        attri.frame = [self footerViewFrameOfVerticalWaterFlow:indexPath];
        
    }
    
    return attri;
    
}

/** 返回值决定了collectionView停止滚动时的偏移量 手指松开后执行
 * proposedContentOffset：原本情况下，collectionView停止滚动时最终的偏移量
 * velocity 滚动速率，通过这个参数可以了解滚动的方向
 */
/*
 - (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
 {
 if (self.flowLayoutStyle == WSLLineWaterFlow) {
 // 拖动比较快 最终偏移量 不等于 手指离开时偏移量
 CGFloat collectionW = self.collectionView.frame.size.width;
 
 // 最终偏移量
 CGPoint targetP = [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
 
 // 0.获取最终显示的区域
 CGRect targetRect = CGRectMake(targetP.x, 0, collectionW, MAXFLOAT);
 
 // 1.获取最终显示的cell
 NSArray *attrs = [super layoutAttributesForElementsInRect:targetRect];
 
 // 获取最小间距
 CGFloat minDelta = MAXFLOAT;
 for (UICollectionViewLayoutAttributes *attr in attrs) {
 // 获取距离中心点距离:注意:应该用最终的x
 CGFloat delta = (attr.center.x - targetP.x) - self.collectionView.bounds.size.width * 0.5;
 
 if (fabs(delta) < fabs(minDelta)) {
 minDelta = delta;
 }
 }
 
 // 移动间距
 targetP.x += minDelta;
 
 if (targetP.x < 0) {
 targetP.x = 0;
 }
 
 return targetP;
 
 }
 return proposedContentOffset;
 
 }
 // Invalidate:刷新
 // 在滚动的时候是否允许刷新布局
 - (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
 
 if (self.flowLayoutStyle == WSLLineWaterFlow) {
 return YES;
 }
 
 return NO;
 }
 */
//返回内容高度
-(CGSize)collectionViewContentSize {
    
    return CGSizeMake(self.collectionView.frame.size.width,self.lastItemFrame.origin.y + self.lastItemFrame.size.height + self.edgeInsets.bottom);
}

#pragma mark - Help Methods


//垂直栅格布局
- (CGRect)to_itemFrameOfHorizontalGridWaterFlow:(NSIndexPath *)indexPath
{
    CGSize itemSize = [self.delegate waterFlowLayout:self sizeForItemAtIndexPath:indexPath];
    
    CGFloat x = 0;
    CGFloat y = 0;
    
    if (itemSize.width == self.lastItemFrame.size.width) {
        
        //换行
        if (roundf(self.lastItemFrame.origin.x + self.lastItemFrame.size.width + self.edgeInsets.right) >= [UIScreen mainScreen].bounds.size.width) {
            y = CGRectGetMaxY(self.lastItemFrame) + self.minSpaceForLines;
            x = self.edgeInsets.left;
        }
        else
        {
            y = self.lastItemFrame.origin.y;
            x = self.lastItemFrame.origin.x + self.lastItemFrame.size.width + self.minSpaceForCells;
        }
        
        
    }
    else //换行
    {
        y = indexPath.row == 0 ? self.edgeInsets.top + CGRectGetMaxY(self.lastItemFrame) : self.lastItemFrame.origin.y + self.lastItemFrame.size.height + self.minSpaceForLines;
        x = self.edgeInsets.left;
    }
    
    //记录最后一个块的frame
    self.lastItemFrame = CGRectMake(x, y, itemSize.width, itemSize.height);
    
    return self.lastItemFrame;
}


//返回头视图的布局frame
- (CGRect)headerViewFrameOfVerticalWaterFlow:(NSIndexPath *)indexPath{
    
    CGSize size = CGSizeZero;
    
    if([self.delegate respondsToSelector:@selector(waterFlowLayout:sizeForHeaderViewInSection:)]){
        size = [self.delegate waterFlowLayout:self sizeForHeaderViewInSection:indexPath.section];
    }
    
    self.lastItemFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, size.height);
    return self.lastItemFrame;
    
}
//返回脚视图的布局frame
- (CGRect)footerViewFrameOfVerticalWaterFlow:(NSIndexPath *)indexPath{
    
    CGSize size = CGSizeZero;
    
    if([self.delegate respondsToSelector:@selector(waterFlowLayout:sizeForFooterViewInSection:)]){
        size = [self.delegate waterFlowLayout:self sizeForFooterViewInSection:indexPath.section];
    }
    
    return CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, size.height);
    
}

#pragma mark - getter

-(NSMutableArray *)attrsArray {
    if (_attrsArray == nil) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

-(CGFloat)minSpaceForCells {
    if ([self.delegate respondsToSelector:@selector(minSpaceForCells:)]) {
        return [self.delegate minSpaceForCells:self];
    } else {
        return  WSLDefaultColumeMargin;
    }
}

-(CGFloat)minSpaceForLines {
    if ([self.delegate respondsToSelector:@selector(minSpaceForLines:)]) {
        return [self.delegate minSpaceForLines:self];
    } else {
        return WSLDefaultRowMargin;
    }
}

-(UIEdgeInsets)edgeInsets {
    if ([self.delegate respondsToSelector:@selector(edgeInsetInWaterFlowLayout:)]) {
        return [self.delegate edgeInsetInWaterFlowLayout:self];
    } else {
        return  WSLDefaultEdgeInset;
    }
}

@end
