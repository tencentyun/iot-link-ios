//
//  TIoTDemoPlaybackVC.m
//  LinkSDKDemo
//
//

#import "TIoTDemoPlaybackVC.h"
#import "CMPageTitleView.h"
#import "TIoTCloudStorageVC.h"
#import "TIoTDemoLocalRecordVC.h"


@interface TIoTDemoPlaybackVC ()<CMPageTitleViewDelegate>
@property (nonatomic, strong) CMPageTitleView *pageView;
@property (nonatomic, strong) NSArray *childControllers;
@end

@implementation TIoTDemoPlaybackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubViews];
}

- (void)initSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"回放";
//    self.fd_interactivePopDisabled = YES;
//    self.fd_prefersNavigationBarHidden = YES;
    
    CGFloat kNavHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat kTopMargin = 0;
    if (@available (iOS 11.0, *)) {
        kTopMargin = kNavHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
    }else {
        kTopMargin = kNavHeight + [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    
    [self.view addSubview:self.pageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo(kTopMargin);
        make.bottom.mas_equalTo(0);
    }];
    
    CMPageTitleConfig *config = [CMPageTitleConfig defaultConfig];
    config.cm_childControllers = self.childControllers;
    config.cm_switchMode = CMPageTitleSwitchMode_Underline;
    config.cm_additionalMode = CMPageTitleAdditionalMode_Seperateline;
    config.cm_seperaterLineColor = kRGBColor(230, 230, 230);
    config.cm_underlineColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    config.cm_underlineWidth = 30;
    config.cm_selectedColor = [UIColor colorWithHexString:@"#000000"];
    config.cm_selectedFont = [UIFont wcPfMediumFontOfSize:15];
    config.cm_font = [UIFont wcPfRegularFontOfSize:15];
    config.cm_normalColor = [UIColor colorWithHexString:kVideoDemoWeekLabelColor];
    config.cm_slideGestureEnable = NO;
    config.cm_contentMode = CMPageTitleContentMode_Center;
    config.cm_titleMargin = 0.0;
    config.cm_minTitleMargin = 0.0;
    self.pageView.cm_config = config;
    self.pageView.titleView.scrollEnabled = NO; //进制titleview滚动
    self.pageView.titleView.cm_size = CGSizeMake(kScreenWidth, 44);
}

- (CMPageTitleView *)pageView {
    if (!_pageView) {
        CMPageTitleView *pageTitleView = [[CMPageTitleView alloc] init];
        
        pageTitleView.delegate = self;
        _pageView = pageTitleView;
    }
    
    return _pageView;
}

- (NSArray *)childControllers {
    if (!_childControllers) {
        
        TIoTCloudStorageVC *cloudStorageVC = [[TIoTCloudStorageVC alloc]init];
        TIoTDemoLocalRecordVC *localRecordVC = [[TIoTDemoLocalRecordVC alloc]init];
        
        cloudStorageVC.title = @"云记录";
        localRecordVC.title = @"本地记录";
        _childControllers = @[cloudStorageVC,localRecordVC];
    }
    return _childControllers;
}


- (void)cm_pageTitleViewSelectedWithIndex:(NSInteger)index Repeat:(BOOL)repeat {

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
