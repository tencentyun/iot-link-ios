//
//  TIoTIntelligentBottomActionView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 自定义底部视图
 */
typedef NS_ENUM(NSInteger, IntelligentBottomViewType) {
    IntelligentBottomViewTypeSingle = 0,
    IntelligentBottomViewTypeDouble = 1,
};

typedef void(^ResponseConfirmSingleButtonTypeBlock)(void);

typedef void(^ResponseDoubleTypeBlock)(void);

@interface TIoTIntelligentBottomActionView : UIView

/**
 显示底部视图button数量，和button的title
 */
- (void)bottomViewType:(IntelligentBottomViewType)type withTitleArray:(NSArray *)titleArray;

/**
 单个button的响应block
 */
@property (nonatomic, copy) ResponseConfirmSingleButtonTypeBlock confirmBlock;

@property (nonatomic, copy) ResponseDoubleTypeBlock firstBlock;
@property (nonatomic, copy) ResponseDoubleTypeBlock secondBlock;
@end

NS_ASSUME_NONNULL_END
