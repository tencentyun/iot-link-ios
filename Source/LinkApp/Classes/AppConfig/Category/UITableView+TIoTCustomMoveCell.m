//
//  UITableView+TIoTCustomMoveCell.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "UITableView+TIoTCustomMoveCell.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, TIoTSnapshotEdge) {
    TIoTSnapshotEdgeTop = 1,
    TIoTSnapshotEdgeBottom = 2,
};

@interface UITableView (TIoTCustomMoveCell)
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIView *snapView;
@property (nonatomic, strong) UITableViewCell *customMoveCell;
@property (nonatomic, copy) TIoTMoveCustomCellBlock moveCellBlock;
@property (nonatomic, assign) TIoTSnapshotEdge scrollDirection; //滚动方向
@property (nonatomic, strong) CADisplayLink *scrollTimer;
@end

@implementation UITableView (TIoTCustomMoveCell)

///MARK:绑定数据源和添加手势
-(void)setupDataArray:(NSMutableArray *)dataSourceArray moveBlock:(TIoTMoveCustomCellBlock )moveBlock {
    self.dataSourceArray = [[NSMutableArray alloc] init];
    [self.dataSourceArray addObjectsFromArray:dataSourceArray];
    self.moveCellBlock = moveBlock;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)];
    [self addGestureRecognizer:longPressGesture];
}

-(void)longPressRecognizer:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
            
        case UIGestureRecognizerStateBegan:{
            [self reloadData];
            CGPoint point = [gesture locationOfTouch:0 inView:gesture.view];
            self.selectedIndexPath = [self indexPathForRowAtPoint:point];
            if (self.selectedIndexPath != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.customMoveCell = [self cellForRowAtIndexPath:self.selectedIndexPath];
                    self.snapView = [self.customMoveCell snapshotViewAfterScreenUpdates:NO];
                    self.snapView.frame = self.customMoveCell.frame;
                    [self addSubview:self.snapView];
                    self.customMoveCell.hidden = YES;
                    [UIView animateWithDuration:0.1 animations:^{
                        self.snapView.transform = CGAffineTransformScale(self.snapView.transform, 1.0, 1.0);
                        self.snapView.alpha = 0.7;
                    }];
                    
                });
                
            }
            
        }
            break;
            
        case UIGestureRecognizerStateChanged:{
            CGPoint point = [gesture locationOfTouch:0 inView:gesture.view];
            CGPoint center  = self.snapView.center;
            center.y = point.y;
            self.snapView.center = center;
            if ([self checkIfSnapshotMeetsEdge]) {
                [self startScrollTimer];
            }else{
                [self stopScrollTimer];
            }
            
            NSIndexPath *exchangeIndex = [self indexPathForRowAtPoint:point];
            //exchangeIndex可能为空
            if (exchangeIndex) {
                [self updateDataArrayWithIndex:exchangeIndex];
                [self moveRowAtIndexPath:self.selectedIndexPath toIndexPath:exchangeIndex];
                self.selectedIndexPath = exchangeIndex;
                
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.customMoveCell  = [self cellForRowAtIndexPath:self.selectedIndexPath];
                [UIView animateWithDuration:0.2 animations:^{
                    self.snapView.center = self.customMoveCell.center;
                    self.snapView.transform = CGAffineTransformIdentity;
                    self.snapView.alpha = 1.0;
                } completion:^(BOOL finished) {
                    self.customMoveCell.hidden = NO;
                    [self.snapView removeFromSuperview];
                    [self stopScrollTimer];
                }];
                
            });
        }
            break;
        default:
            break;
    }
}


///MARK:检查截图是否到边缘并作出响应
- (BOOL)checkIfSnapshotMeetsEdge {
    
    CGFloat minY = CGRectGetMinY(self.snapView.frame);
    CGFloat maxY = CGRectGetMaxY(self.snapView.frame);
    if (minY < self.contentOffset.y) {
        self.scrollDirection = TIoTSnapshotEdgeTop;
        return YES;
    }
    if (maxY > self.bounds.size.height + self.contentOffset.y) {
        self.scrollDirection = TIoTSnapshotEdgeBottom;
        return YES;
    }
    return NO;
}

# pragma mark - timer methods

///MARK: 创建启动定时器
- (void)startScrollTimer {
    if (self.scrollTimer == nil) {
        self.scrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(startAutoScroll)];
        [self.scrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

///MARK: 销毁定时器
- (void)stopScrollTimer {
    if (self.scrollTimer) {
        [self.scrollTimer invalidate];
    }
}

///MARK:开始自动滚动
- (void)startAutoScroll {
    CGFloat speedValue = 4;
    if (self.scrollDirection == TIoTSnapshotEdgeTop) {
        //向上滚动
        if (self.contentOffset.y > 0) {//向下滚动最大范围限制
            [self setContentOffset:CGPointMake(0, self.contentOffset.y - speedValue)];
            self.snapView.center = CGPointMake(self.snapView.center.x, self.snapView.center.y - speedValue);
        }
    }else{
        //向下滚动
        if (self.contentOffset.y + self.bounds.size.height < self.contentSize.height) {//向下滚动最大范围限制
            [self setContentOffset:CGPointMake(0, self.contentOffset.y + speedValue)];
            self.snapView.center = CGPointMake(self.snapView.center.x, self.snapView.center.y + speedValue);
        }
    }
    
    //交换cell
    NSIndexPath *exchangeIndex = [self indexPathForRowAtPoint:self.snapView.center];
    if (exchangeIndex) {
        [self updateDataArrayWithIndex:exchangeIndex];
        [self moveRowAtIndexPath:self.selectedIndexPath toIndexPath:exchangeIndex];
        self.selectedIndexPath = exchangeIndex;
    }
}

///MARK:更新数据源
-(void)updateDataArrayWithIndex:(NSIndexPath *)moveIndexPath {
    //判断是否是嵌套数组
    if ([self checkTargetArray:self.dataSourceArray]) {
        if (self.selectedIndexPath.section == moveIndexPath.section) {
            NSMutableArray *originalArr = self.dataSourceArray[self.selectedIndexPath.section];
            
            [originalArr exchangeObjectAtIndex:self.selectedIndexPath.row withObjectAtIndex:moveIndexPath.row];
            
        }else{
            
            NSMutableArray *originalArr = self.dataSourceArray[self.selectedIndexPath.section];
            NSMutableArray *removeTempArray = self.dataSourceArray[moveIndexPath.section];
            NSString * obj = [originalArr objectAtIndex:self.selectedIndexPath.row];
            [removeTempArray insertObject:obj atIndex:moveIndexPath.row];
            [originalArr removeObjectAtIndex:self.selectedIndexPath.row];
        }
        
    }else{
        [self.dataSourceArray exchangeObjectAtIndex:self.selectedIndexPath.row withObjectAtIndex:moveIndexPath.row];
    }
    
    self.moveCellBlock(self.dataSourceArray);
    
}

- (BOOL)checkTargetArray:(NSArray *)targetArray{
    
    for (id item in targetArray) {
        if ([item isKindOfClass:[NSArray class]]) {
            return YES;
        }
    }
    return NO;
}

-(NSMutableArray *)dataSourceArray {
    return objc_getAssociatedObject(self, "dataSourceArray");
}

- (void)setDataSourceArray:(NSMutableArray *)dataSourceArray {
    objc_setAssociatedObject(self, "dataSourceArray", dataSourceArray,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(TIoTMoveCustomCellBlock )moveCellBlock {
    return objc_getAssociatedObject(self, "moveCellBlock");
}

- (void)setMoveCellBlock:(TIoTMoveCustomCellBlock)moveCellBlock {
    objc_setAssociatedObject(self, "moveCellBlock", moveCellBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(UIView *)snapView {
    return objc_getAssociatedObject(self, "snapView");
}

-(void)setSnapView:(UIView *)snapView {
    objc_setAssociatedObject(self, "snapView", snapView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSIndexPath *)selectedIndexPath {
    return objc_getAssociatedObject(self, "selectedIndexPath");
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    objc_setAssociatedObject(self, "selectedIndexPath", selectedIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UITableViewCell *)customMoveCell {
    return objc_getAssociatedObject(self, "customMoveCell");
}

- (void)setCustomMoveCell:(UITableViewCell *)customMoveCell {
    objc_setAssociatedObject(self, "customMoveCell", customMoveCell, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(TIoTSnapshotEdge)scrollDirection {
    return (TIoTSnapshotEdge)[objc_getAssociatedObject(self, "scrollDirection") integerValue];
}

-(void)setScrollDirection:(TIoTSnapshotEdge)scrollDirection {
    objc_setAssociatedObject(self, "scrollDirection", @(scrollDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CADisplayLink *)scrollTimer {
    return objc_getAssociatedObject(self, "scrollTimer");
}

-(void)setScrollTimer:(CADisplayLink *)scrollTimer {
    objc_setAssociatedObject(self, "scrollTimer", scrollTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
