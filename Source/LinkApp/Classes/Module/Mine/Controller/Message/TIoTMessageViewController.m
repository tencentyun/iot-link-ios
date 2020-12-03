//
//  WCMessageViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTMessageViewController.h"
#import "CMPageTitleView.h"

@interface TIoTMessageViewController ()


@property (nonatomic,strong) CMPageTitleView *pageView;
@property (nonatomic,strong) NSArray *childControllers;
@end

@implementation TIoTMessageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
}

#pragma mark -

- (void)setupUI{
    self.view.backgroundColor = kBgColor;
    self.title = NSLocalizedString(@"message_notification", @"消息通知");
    self.fd_interactivePopDisabled = YES;
    
    [self.view addSubview:self.pageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.height.mas_equalTo(kScreenHeight - [TIoTUIProxy shareUIProxy].navigationBarHeight);
        
    }];
    
    CMPageTitleConfig *config = [CMPageTitleConfig defaultConfig];
    config.cm_childControllers = self.childControllers;
    config.cm_switchMode = CMPageTitleSwitchMode_Underline;
    config.cm_additionalMode = CMPageTitleAdditionalMode_Seperateline;
    config.cm_seperaterLineColor = kRGBColor(230, 230, 230);
    config.cm_underlineColor = kMainColor;
    config.cm_underlineWidth = 80;
    config.cm_selectedColor = kFontColor;
    config.cm_font = [UIFont systemFontOfSize:16];
    config.cm_slideGestureEnable = YES;
    config.cm_contentMode = CMPageTitleContentMode_Center;
    config.cm_titleMargin = 0.0;
    config.cm_minTitleMargin = 0.0;
    self.pageView.cm_config = config;
    self.pageView.titleView.scrollEnabled = NO;
    
}

#pragma mark - getter

- (CMPageTitleView *)pageView {
    if (!_pageView) {
        CMPageTitleView *pageTitleView = [[CMPageTitleView alloc] init];
        
        _pageView = pageTitleView;
    }
    
    return _pageView;
}

- (NSArray *)childControllers {
    
    if (!_childControllers) {
        UIViewController *vc0 = [NSClassFromString(@"TIoTMessageDeviceVC") new];
        UIViewController *vc1 = [NSClassFromString(@"TIoTMessageFamilyVC") new];
        UIViewController *vc2 = [NSClassFromString(@"TIoTMessageNoticeVC") new];
        
        vc0.title = @"设备";
        vc1.title = @"家庭";
        vc2.title = @"通知";
        
        
        vc0.view.backgroundColor = kBgColor;
        vc1.view.backgroundColor = kBgColor;
        vc2.view.backgroundColor = kBgColor;
        
        
        _childControllers =@[vc0,vc1,vc2];
        
    }
    
    return _childControllers;
}

@end
