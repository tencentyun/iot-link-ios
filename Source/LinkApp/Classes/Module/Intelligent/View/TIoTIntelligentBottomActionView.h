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
typedef NS_ENUM(NSInteger, IntellignetBottomViewType) {
    IntellignetBottomViewTypeSingle = 0,
    IntellignetBottomViewTypeDouble = 1,
};

typedef void(^ResponseConfirmSingleButtonTypeBlock)(void);

@interface TIoTIntelligentBottomActionView : UIView

/**
 显示底部视图button数量，和button的title
 */
- (void)bottomViewType:(IntellignetBottomViewType)type withTitleArray:(NSArray *)titleArray;

/**
 单个button的响应block
 */
@property (nonatomic, copy) ResponseConfirmSingleButtonTypeBlock confirmBlock;

@end

NS_ASSUME_NONNULL_END
