//
//  TrackView.h
//  SliderView
//
//

#import <UIKit/UIKit.h>

@interface TrackView : UIView

/*
 *** 设置起点
 */
@property (nonatomic, assign) CGPoint startPoint;

/*
 *** 设置终点
 */
@property (nonatomic, assign) CGPoint endPoint;

/*
 *** 设置颜色区间
 */
@property (nonatomic, retain) NSArray *colors;


@end

