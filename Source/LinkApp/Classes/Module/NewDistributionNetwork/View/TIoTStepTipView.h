//
//  TIoTStepTipView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTStepTipView : UIView


/// 初始化TIoTStepTipView 标题数据array
/// @param array 标题数据array
- (instancetype)initWithTitlesArray:(NSArray *)array;

/// 当前处于第几步
@property (nonatomic, assign) NSInteger step;
/// 展示进度条动画
@property (nonatomic, assign) BOOL showAnimate;

@end

NS_ASSUME_NONNULL_END
