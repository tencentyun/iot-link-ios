//
//  TIoTEvaluationSharedView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/10/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTEvaluationSharedView.h"
#import "WxManager.h"

@interface TIoTEvaluationSharedView ()
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *actionBottomView;
@property (nonatomic, strong) UIButton *friendButton;
@property (nonatomic, strong) UIImageView *friendImageView;
@property (nonatomic, strong) UILabel *friendLabel;
@property (nonatomic, strong) UIButton *linkButton;
@property (nonatomic, strong) UIImageView *linkImageView;
@property (nonatomic, strong) UILabel *linkLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *safeView;
@end

@implementation TIoTEvaluationSharedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    
    CGFloat kPadding = 50;
    CGFloat kHeightWidth = 50;
    CGFloat kActionBottonHeight = 175;
    if (@available(iOS 11.0, *))  {
        kActionBottonHeight = kActionBottonHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissView)];
    [self addGestureRecognizer:tapGesture];
    
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.right.bottom.equalTo(self);
    }];
    
    
    [self.bottomView addSubview:self.actionBottomView];
    [self.actionBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.left.equalTo(self);
        make.height.mas_equalTo(kActionBottonHeight);
    }];
    
    [self.actionBottomView addSubview:self.friendButton];
    [self.friendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(27);
        make.width.height.mas_equalTo(kHeightWidth);
        make.left.mas_equalTo(kScreenWidth/2 - kHeightWidth - kPadding);
    }];
    
    [self.friendButton addSubview:self.friendImageView];
    [self.friendImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.friendButton);
        make.height.width.mas_equalTo(25);
    }];
    
    [self.actionBottomView addSubview:self.friendLabel];
    [self.friendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.friendButton);
        make.top.equalTo(self.friendButton.mas_bottom).offset(12);
    }];
    
    [self.actionBottomView addSubview:self.linkButton];
    [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.friendButton);
        make.width.height.mas_equalTo(kHeightWidth);
        make.left.mas_equalTo((kScreenWidth/2 + kPadding));
    }];
    
    [self.linkButton addSubview:self.linkImageView];
    [self.linkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.linkButton);
        make.height.width.mas_equalTo(25);
    }];
    
    [self.actionBottomView addSubview:self.linkLabel];
    [self.linkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.linkButton);
        make.top.equalTo(self.linkButton.mas_bottom).offset(12);
    }];
    
    [self.actionBottomView addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(50);
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_bottom).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self);
            }
        }else {
            make.bottom.equalTo(self);
        }
    }];
    
    [self.actionBottomView addSubview:self.safeView];
    [self.safeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.cancelButton.mas_bottom);
    }];
    
    [self changeViewRectConnerWithView:self.actionBottomView withRect:CGRectMake(0, 0, kScreenWidth, kActionBottonHeight)];
    
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    
    [self changeViewRectCircle:self.friendButton];
    [self changeViewRectCircle:self.linkButton];
    
    
}

#pragma mark - lazy load
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _bottomView;
}

- (UIView *)actionBottomView {
    if (!_actionBottomView) {
        _actionBottomView = [[UIView alloc]init];
        _actionBottomView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    }
    return _actionBottomView;
}

- (UIButton *)friendButton {
    if (!_friendButton) {
        _friendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_friendButton addTarget:self action:@selector(sharedWeichat) forControlEvents:UIControlEventTouchUpInside];
        _friendButton.backgroundColor = [UIColor whiteColor];
    }
    return _friendButton;
}

- (UIImageView *)friendImageView {
    if (!_friendImageView) {
        _friendImageView = [[UIImageView alloc]init];
        _friendImageView.image = [UIImage imageNamed:@"evalucation_weichat_friend"];
    }
    return _friendImageView;
}

- (UILabel *)friendLabel {
    if (!_friendLabel) {
        _friendLabel = [[UILabel alloc]init];
        _friendLabel.text = NSLocalizedString(@"evaluation_friend", @"微信好友");
        _friendLabel.font = [UIFont wcPfRegularFontOfSize:12];
        _friendLabel.textColor = [UIColor colorWithHexString:@"#6C7078"];
        _friendLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _friendLabel;
}

- (UIButton *)linkButton {
    if (!_linkButton) {
        _linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_linkButton addTarget:self action:@selector(copyLink) forControlEvents:UIControlEventTouchUpInside];
        _linkButton.backgroundColor = [UIColor whiteColor];
    }
    return _linkButton;
}

- (UIImageView *)linkImageView {
    if (!_linkImageView) {
        _linkImageView = [[UIImageView alloc]init];
        _linkImageView.image = [UIImage imageNamed:@"evalucation_copy"];
    }
    return _linkImageView;
}

- (UILabel *)linkLabel {
    if (!_linkLabel) {
        _linkLabel = [[UILabel alloc]init];
        _linkLabel.text = NSLocalizedString(@"evaluation_copyLink", @"复制链接");
        _linkLabel.font = [UIFont wcPfRegularFontOfSize:12];
        _linkLabel.textColor = [UIColor colorWithHexString:@"#6C7078"];
        _linkLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _linkLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setBackgroundColor: [UIColor whiteColor]];
        [_cancelButton setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"15161A"] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_cancelButton addTarget:self action:@selector(hideSharedView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIView *)safeView {
    if (!_safeView) {
        _safeView = [[UIView alloc]init];
        _safeView.backgroundColor = [UIColor whiteColor];
    }
    return _safeView;
}

#pragma mark - evetn method

- (void)changeViewRectConnerWithView:(UIView *)view withRect:(CGRect )rect{
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
    CAShapeLayer * layer = [[CAShapeLayer alloc]init];
    layer.frame = view.bounds;
    layer.path = path.CGPath;
    view.layer.mask = layer;

}

- (void)changeViewRectCircle:(UIView *)view {
    view.layer.cornerRadius = self.friendButton.frame.size.width / 2;

    view.clipsToBounds = YES;
}

- (void)sharedWeichat {
    
    [[WxManager sharedWxManager] authFromWxComplete:^(id obj, NSError *error) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_queue_create(0, 0), ^{
            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:weakSelf.sharedFriendDic[@"articleImg"]]]];
            
            [[WxManager sharedWxManager] shareMiniProgramToWXSceneSessionWithTitle:weakSelf.sharedFriendDic[@"articleTitle"] description:nil path:weakSelf.sharedPathString webpageUrl:weakSelf.sharedURLString userName:@"gh_2aa6447f2b7c" thumbImage:thumbImage thumbImageUrl:nil complete:^(id obj, NSError *error) {
                NSLog(@"-!!--%@",error);
            }];
        });
    }];
   
}

- (void)copyLink {
    
    UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
    pastboard.string = self.sharedURLString;
    
    [MBProgressHUD showSuccess:NSLocalizedString(@"evaluation_copyLink_success", @"已复制到剪切板")];
    
}

- (void)hideSharedView {
    [self dismissSharedView];
}

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
}
@end
