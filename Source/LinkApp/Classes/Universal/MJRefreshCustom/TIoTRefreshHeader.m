//
//  XDPRefreshHeader.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/18.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "TIoTRefreshHeader.h"
@interface TIoTRefreshHeader ()

@property (nonatomic , weak) UIImageView *arrowView;

@property (nonatomic , weak) UIActivityIndicatorView *loadingView;

@property (nonatomic , weak) UILabel *stateLabel;

/** 所有状态对应的文字 */
@property (strong, nonatomic) NSMutableDictionary *stateTitles;

@property (nonatomic , assign) CGFloat arrowX;

@end


@implementation TIoTRefreshHeader

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    
    // 初始化文字
    [self setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [self setTitle:@"松手更新" forState:MJRefreshStatePulling];
    [self setTitle:@"加载中..."  forState:MJRefreshStateRefreshing];

}

- (void)placeSubviews
{
    [super placeSubviews];
    
    self.stateLabel.frame = self.bounds;
    CGRect frame = self.stateLabel.frame;
    frame.origin.x += 10.5;
    self.stateLabel.frame = frame;
     
    // 箭头的中心点
    CGFloat arrowCenterX = self.mj_w * 0.5;
    if (!self.stateLabel.hidden) {
        CGFloat stateWidth = self.stateLabel.mj_textWith;
        arrowCenterX -= stateWidth / 2 + 6;
    }
    CGFloat arrowCenterY = self.mj_h * 0.5;
    CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);
    
    // 箭头
    if (self.arrowView.constraints.count == 0) {
        self.arrowView.mj_size = self.arrowView.image.size;
        self.arrowView.center = arrowCenter;
    }
    
    // 圈圈
    if (self.loadingView.constraints.count == 0) {
        self.loadingView.center = arrowCenter;
    }
    
    self.arrowView.tintColor = self.stateLabel.textColor;
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 设置状态文字
    self.stateLabel.text = self.stateTitles[@(state)];
    
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            self.arrowView.transform = CGAffineTransformIdentity;
            
            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                self.loadingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                if (self.state != MJRefreshStateIdle) return;
                
                self.loadingView.alpha = 1.0;
                [self.loadingView stopAnimating];
                self.arrowView.hidden = NO;
            }];
        } else {
            [self.loadingView stopAnimating];
            self.arrowView.hidden = NO;
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        }
    } else if (state == MJRefreshStatePulling) {
        [self.loadingView stopAnimating];
        self.arrowView.hidden = NO;
        [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
            self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
        }];
    } else if (state == MJRefreshStateRefreshing) {
        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        [self.loadingView startAnimating];
        self.arrowView.hidden = YES;
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
}

#pragma mark private
- (void)setTitle:(NSString *)title forState:(MJRefreshState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
}

#pragma mark - 懒加载子控件
- (UIImageView *)arrowView
{
    if (!_arrowView) {
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_refreshing"]];
        self.arrowX = ( kScreenWidth - 75 ) * 0.5;
        [self addSubview:_arrowView = arrowView];
    }
    return _arrowView;
}

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);
        loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}

- (UILabel *)stateLabel
{
    if (!_stateLabel) {
        [self addSubview:_stateLabel = [UILabel mj_label]];
        _stateLabel.textColor = kRGBColor(153, 153, 153);
    }
    return _stateLabel;
}

- (NSMutableDictionary *)stateTitles
{
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

@end
