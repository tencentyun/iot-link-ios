//
//  XDPRefreshFooter.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/18.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "TIoTRefreshFooter.h"

@interface TIoTRefreshFooter ()

@property (nonatomic , weak) UIImageView *failureView;

@property (nonatomic , weak) UIActivityIndicatorView *loadingView;

@property (nonatomic , weak) UILabel *stateLabel;

/** 所有状态对应的文字 */
@property (strong, nonatomic) NSMutableDictionary *stateTitles;

@end

@implementation TIoTRefreshFooter

#pragma mark pubilc method
- (void)showFailStatus{
    [self setState:MJRefreshStateIdle];
    self.stateLabel.text = kXDPRefreshFooterFailure;
    self.failureView.hidden = NO;
    
}

- (void)setTitle:(NSString *)title forState:(MJRefreshState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
}

- (NSString *)titleForState:(MJRefreshState)state{
    return self.stateTitles[@(state)];
}

- (void)prepare{
    [super prepare];
    [self setTitle:@"" forState:MJRefreshStateIdle];
    [self setTitle:NSLocalizedString(@"loading", @"加载中...")  forState:MJRefreshStateRefreshing];
    [self setTitle:NSLocalizedString(@"no_more", @"没有更多了!") forState:MJRefreshStateNoMoreData];
}

- (void)placeSubviews{
    [super placeSubviews];
    
    // 状态标签
    self.stateLabel.frame = self.bounds;
    CGRect frame = self.stateLabel.frame;
    frame.origin.x += 10.5;
    self.stateLabel.frame = frame;
    
    // 失败的中心点
    CGFloat failureCenterX = self.mj_w * 0.5;
    CGFloat loadingCenterX = self.mj_w * 0.5;
    if (!self.stateLabel.hidden) {
        CGFloat stateWidth = [kXDPRefreshFooterFailure
                              boundingRectWithSize:self.stateLabel.frame.size
                              options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:@{NSFontAttributeName:self.stateLabel.font}
                              context:nil].size.width;
        failureCenterX -= stateWidth / 2 + 6;
        
        stateWidth = [NSLocalizedString(@"loading", @"加载中...")
                                boundingRectWithSize:self.stateLabel.frame.size
                                options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:self.stateLabel.font}
                                context:nil].size.width;
        loadingCenterX -= stateWidth / 2 + 6;
    }
    
    CGFloat iconCenterY = self.mj_h * 0.5;
    
    // 失败
    if (self.failureView.constraints.count == 0) {
        self.failureView.mj_size = self.failureView.image.size;
        self.failureView.center = CGPointMake(failureCenterX, iconCenterY);
    }
    
    // 圈圈
    if (self.loadingView.constraints.count == 0) {
        self.loadingView.center = CGPointMake(loadingCenterX, iconCenterY);
    }
    
    self.failureView.tintColor = self.stateLabel.textColor;
    
    if (self.state == MJRefreshStateNoMoreData) {
        CGRect frame = self.stateLabel.frame;
        frame.origin.x = 0;
        self.stateLabel.frame = frame;
    }
}

- (void)loadMoreData{
    if ([self.stateLabel.text isEqualToString:kXDPRefreshFooterFailure]) {
        [self beginRefreshing];
    }
}

#pragma mark private


- (void)setState:(MJRefreshState)state{
    MJRefreshCheckState
    if ([self.stateLabel.text isEqualToString:kXDPRefreshFooterFailure] && state == MJRefreshStateIdle) {
        self.failureView.hidden = NO;
        self.loadingView.hidden = YES;
        [self.loadingView stopAnimating];
        return;
    }
    
    if (state == MJRefreshStateNoMoreData || state == MJRefreshStateIdle) {
        self.failureView.hidden = YES;
        self.loadingView.hidden = YES;
        [self.loadingView stopAnimating];
        
    }
    
    if (state == MJRefreshStateRefreshing) {
        self.failureView.hidden = YES;
        self.loadingView.hidden = NO;
        [self.loadingView startAnimating];
    }
    
    self.stateLabel.text = self.stateTitles[@(state)];
}

#pragma mark - 懒加载子控件
- (UIImageView *)failureView
{
    if (!_failureView) {
        UIImageView *failureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_refreshFailure"]];
        [self addSubview:_failureView = failureView];
    }
    return _failureView;
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
        [_stateLabel xdp_addTarget:self action:@selector(loadMoreData)];
        
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
