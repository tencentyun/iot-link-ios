//
//  UIView+StatusCoast.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/13.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "UIView+StatusCoast.h"
#import <objc/runtime.h>

static const void *XDPLoadingStatusKey = &XDPLoadingStatusKey;
static const void *XDPLoadFailureStatusKey = &XDPLoadFailureStatusKey;
static const void *XDPLoadEmptyStatusKey = &XDPLoadEmptyStatusKey;

@implementation UIView (StatusCoast)

#pragma mark pubilc method

- (void)showLoading{
    
    if (![self loadingView]) {
        [self initLoadingView];
    }
    
    [self loadingView].hidden = NO;
    [[self loadingView] startLoading];
    [self failureView].hidden = YES;
    [self emptyView].hidden = YES;
}

- (void)showLoadFailureReloadBlock:(void(^)(void))reloadEvent{
    
    if (![self failureView]) {
        [self initFailureView];
    }

    [self failureView].hidden = NO;
    [self failureView].reloadEvent = reloadEvent;
    [[self loadingView] stopLoading];
    [self loadingView].hidden = YES;
    [self emptyView].hidden = YES;
}

- (void)showEmpty:(NSString *)title desc:(NSString *)desc image:(UIImage *)image block:(void(^)(void))block{
    if (![self emptyView]) {
        [self initEmptyView];
    }
    
    [self loadingView].hidden = YES;
    [[self loadingView] stopLoading];
    [self failureView].hidden = YES;
    [self emptyView].hidden = NO;
    [[self emptyView] showImage:image desc:desc title:title];
    [self emptyView].operation = block;
}

- (void)showEmpty2:(NSString *)title desc:(NSString *)desc image:(UIImage *)image block:(void(^)(void))block{
    if (![self emptyView]) {
        [self initEmptyView2];
    }
    
    [self loadingView].hidden = YES;
    [[self loadingView] stopLoading];
    [self failureView].hidden = YES;
    [self emptyView].hidden = NO;
    [[self emptyView] showImage:image desc:desc title:title];
    [self emptyView].operation = block;
}

- (void)hideStatus{
    [self failureView].hidden = YES;
    [self loadingView].hidden = YES;
    [self emptyView].hidden = YES;
    [[self loadingView] stopLoading];
}

#pragma mark private method

- (void)initLoadingView{
    
    XDPLoadingStatusView *loadingView = [[XDPLoadingStatusView alloc] initWithFrame:CGRectMake(0, 241 * kScreenAllWidthScale, 80, 80)];
    [self addSubview:loadingView];
    
    [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_top).offset(241 * kScreenAllWidthScale);
    }];
    objc_setAssociatedObject(self, XDPLoadingStatusKey, loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)initFailureView{
    
    XDPLoadFailureView *failureView = [[XDPLoadFailureView alloc] initWithFrame:CGRectMake(0, 118 * kScreenAllWidthScale, 150 * kScreenAllWidthScale, 175 * kScreenAllWidthScale)];
    CGPoint fcenter = failureView.center;
    fcenter.x = self.frame.size.width * 0.5;
    failureView.center = fcenter;
    [self addSubview:failureView];
    [failureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(150 * kScreenAllWidthScale);
        make.height.mas_equalTo(175 * kScreenAllWidthScale);
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_top).offset(118 * kScreenAllWidthScale);
    }];
    
     objc_setAssociatedObject(self, XDPLoadFailureStatusKey, failureView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)initEmptyView{
    XDPEmptyView *emptyView = [[XDPEmptyView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    emptyView.backgroundColor = kBgColor;
    [self addSubview:emptyView];
//    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(kScreenWidth);
//        if (self.frame.size.height > 0) {
//            make.height.mas_equalTo(self.frame.size.height);
//        }
//        else{
//            make.height.mas_equalTo(kScreenHeight - [WCUIProxy shareUIProxy].navigationBarHeight);
//        }
//
//        make.centerX.equalTo(self);
//        make.top.equalTo(self);
//    }];

    objc_setAssociatedObject(self, XDPLoadEmptyStatusKey, emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)initEmptyView2{
    XDPEmptyView *emptyView = [[XDPEmptyView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height)];
    emptyView.backgroundColor = [UIColor clearColor];
    [self addSubview:emptyView];
//    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(kScreenWidth);
//        if (self.frame.size.height > 0) {
//            make.height.mas_equalTo(self.frame.size.height);
//        }
//        else{
//            make.height.mas_equalTo(kScreenHeight - [WCUIProxy shareUIProxy].navigationBarHeight);
//        }
//
//        make.centerX.equalTo(self);
//        make.top.equalTo(self);
//    }];

    objc_setAssociatedObject(self, XDPLoadEmptyStatusKey, emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (XDPLoadingStatusView *)loadingView{
    return objc_getAssociatedObject(self, XDPLoadingStatusKey);
}

- (XDPLoadFailureView *)failureView{
    return objc_getAssociatedObject(self, XDPLoadFailureStatusKey);
}

- (XDPEmptyView *)emptyView{
    return objc_getAssociatedObject(self, XDPLoadEmptyStatusKey);
}

@end


@interface XDPLoadingStatusView ()

@property (nonatomic , weak) UIActivityIndicatorView *indicatorView;

@property (nonatomic , weak) UILabel *loadingL;

@end

@implementation XDPLoadingStatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self baseUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _indicatorView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5 - 15);
    _loadingL.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5 + 20);
    CGRect lframe = _loadingL.frame;
    lframe.size.width = self.frame.size.width;
    _loadingL.frame = lframe;
}

- (void)baseUI{
    
    UIActivityIndicatorView *indiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indiView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    _indicatorView = indiView;
    [self addSubview:indiView];
    _indicatorView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5 - 10);
    
    UILabel *loadingL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    loadingL.textAlignment = NSTextAlignmentCenter;
    loadingL.font = [UIFont wcPfRegularFontOfSize:13];
    loadingL.textColor = kRGBColor(153, 153, 153);
    loadingL.text = NSLocalizedString(@"now_loading", @"正在加载中...");
    [self addSubview:loadingL];
    self.loadingL = loadingL;
    
}

- (void)startLoading{
    [self.indicatorView startAnimating];
}

- (void)stopLoading{
    [self.indicatorView stopAnimating];
}

- (void)setText:(NSString *)text{
    self.loadingL.text = text;
}

@end

@interface XDPLoadFailureView ()

@property (nonatomic , weak) UILabel *statusL;

@property (nonatomic , weak) UIImageView *statusImg;

@property (nonatomic , weak) UILabel *reloadL;

@end

@implementation XDPLoadFailureView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self= [super initWithFrame:frame]) {
        [self baseUI];
    }
    return self;
}

- (void)baseUI{
    
    self.userInteractionEnabled = YES;
    
    UIImageView *statusImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150 * kScreenAllWidthScale, 72 * kScreenAllWidthScale)];
    statusImg.image = [UIImage imageNamed:@"main_loadFailure"];
    [self addSubview:statusImg];
    
    UILabel *statusL = [[UILabel alloc] initWithFrame:CGRectMake(0, statusImg.frame.origin.y + statusImg.frame.size.height + 26 * kScreenAllWidthScale, self.frame.size.width, 20)];
    statusL.textAlignment = NSTextAlignmentCenter;
    statusL.font = [UIFont wcPfRegularFontOfSize:13 * kScreenAllWidthScale];
    statusL.textColor = kRGBColor(204, 204, 204);
    statusL.text = NSLocalizedString(@"someError", @"似乎出了点问题...");
    [self addSubview:statusL];
    
    UILabel *reloadL = [[UILabel alloc] initWithFrame:CGRectMake(0, statusL.frame.origin.y + statusL.frame.size.height + 20 * kScreenAllWidthScale, 120 * kScreenAllWidthScale, 36 * kScreenAllWidthScale)];
    CGPoint rcenter = reloadL.center;
    rcenter.x = self.frame.size.width * 0.5;
    reloadL.center = rcenter;
    reloadL.textAlignment = NSTextAlignmentCenter;
    reloadL.font = [UIFont wcPfRegularFontOfSize:14 * kScreenAllWidthScale];
    reloadL.textColor = kRGBColor(255, 61, 106);
    reloadL.text = NSLocalizedString(@"reload", @"重新加载");
    reloadL.layer.cornerRadius = reloadL.frame.size.height * 0.5;
    reloadL.layer.masksToBounds = YES;
    reloadL.layer.borderWidth = 1;
    reloadL.layer.borderColor = kRGBColor(255, 61, 106).CGColor;
    [reloadL xdp_addTarget:self action:@selector(reloadData)];
    [self addSubview:reloadL];
    
}

- (void)reloadData{
    if (self.reloadEvent) {
        self.reloadEvent();
    }
}

@end


@interface XDPEmptyView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *descLab;
@property (nonatomic, strong) UIButton *opreatBtn;


@end

@implementation XDPEmptyView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI{
    
//    [self xdp_addTarget:self action:@selector(opreatClick:)];
    
    CGFloat kTopPadding = 110+55;
    if ([TIoTUIProxy shareUIProxy].iPhoneX) {
        kTopPadding = kTopPadding + 100;
    }
    self.imageView = [[UIImageView alloc] init];
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self).offset(kTopPadding);
        make.centerX.equalTo(self);
        make.height.mas_equalTo(160);
        make.width.mas_equalTo(256);
    }];
    
    self.descLab = [[UILabel alloc] init];
    self.descLab.textColor = [UIColor colorWithHexString:@"#6C7078"];
    self.descLab.font = [UIFont wcPfRegularFontOfSize:14];
    self.descLab.numberOfLines = 0;
    self.descLab.textAlignment = NSTextAlignmentCenter;
    [self.descLab sizeToFit];
    [self addSubview:self.descLab];
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.imageView);
        make.top.equalTo(self.imageView.mas_bottom).offset(16);
    }];
    
    self.opreatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.opreatBtn addTarget:self action:@selector(opreatClick:) forControlEvents:UIControlEventTouchUpInside];
    self.opreatBtn.layer.cornerRadius = 18;
    self.opreatBtn.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
    self.opreatBtn.layer.borderWidth = 1;
    [self.opreatBtn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    self.opreatBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
    [self addSubview:self.opreatBtn];
    [self.opreatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descLab.mas_bottom).offset(20);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(140);
        make.centerX.equalTo(self.imageView);
    }];
    
}

- (void)showImage:(UIImage *)image desc:(NSString *)desc title:(NSString *)title{
    self.descLab.text = desc;
    self.imageView.image = image;
    [self.opreatBtn setTitle:title forState:UIControlStateNormal];
    if (title.length == 0) {
        self.opreatBtn.hidden = YES;
    }
    if (image == nil) {
        self.imageView.hidden = YES;
    }
}

- (void)opreatClick:(id)sender{
    if (self.operation) {
        self.operation();
    }
}

@end
