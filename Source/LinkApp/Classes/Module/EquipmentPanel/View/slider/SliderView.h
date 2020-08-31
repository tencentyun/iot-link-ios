//
//  SliderView.h
//  SliderView
//
//  Created by Wp on 2018/4/11.


#import <UIKit/UIKit.h>

@interface SliderView : UIControl

/*
 ***  最小值
 */
@property (nonatomic, assign) CGFloat minValue;

/*
 *** 最大值
 */
@property (nonatomic, assign) CGFloat maxValue;

/*
 *** 默认值
 */
@property (nonatomic, assign) CGFloat value;

/*
 *** 轨道colors
 */
@property (nonatomic, retain) NSArray *trackColors;

/*
 *** 轨道默认color
 */
@property (nonatomic, strong) UIColor *normalColor;

/*
 *** 轨道size
 */
@property (nonatomic, assign) CGSize trackSize;

/*
 *** 滑块size
 */
@property (nonatomic, assign) CGSize thumbSize;

/*
 *** 滑块背景图片
 */
@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic, copy) void (^update)(CGFloat value);

//刷新视图
- (void)reloadData:(CGFloat)value;


@end
