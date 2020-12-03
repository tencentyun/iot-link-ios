//
//  TIoTIntelligentHomeVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentHomeVC.h"
#import "CMPageTitleView.h"
#import "TIoTIntelligentVC.h"
#import "TIoTIntelligentLogVC.h"
#import "TIoTCustomSheetView.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTAddManualIntelligentVC.h"
#import "TIoTAddAutoIntelligentVC.h"

@interface TIoTIntelligentHomeVC ()
@property (nonatomic, strong) CMPageTitleView *pageView;
@property (nonatomic, strong) NSArray *childControllers;
@property (nonatomic, strong) UIView *navCustomTopView;
@property (nonatomic, strong) TIoTCustomSheetView *customSheet;
@property (nonatomic, strong) TIoTIntelligentVC *intelligentVC;
@end

@implementation TIoTIntelligentHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navCustomTopView.hidden = NO;
    self.navigationController.tabBarController.tabBar.hidden = NO;
    [self.intelligentVC loadSceneList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navCustomTopView.hidden = YES;
    if (self.customSheet) {
        [self.customSheet removeFromSuperview];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    self.navigationController.tabBarController.tabBar.hidden = YES;
}

- (void)setupUI {
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.navCustomTopView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.fd_interactivePopDisabled = YES;
    self.fd_prefersNavigationBarHidden = YES;
    
    [self.view addSubview:self.pageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.bottom.mas_equalTo(0);
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
    config.cm_slideGestureEnable = NO;
    config.cm_contentMode = CMPageTitleContentMode_Center;
    config.cm_titleMargin = 0.0;
    config.cm_minTitleMargin = 0.0;
    self.pageView.cm_config = config;
    self.pageView.titleView.scrollEnabled = NO; //进制titleview滚动
}

#pragma mark - event
- (void)addClick {
    self.customSheet = [[TIoTCustomSheetView alloc]init];
    [self.customSheet sheetViewTopTitleFirstTitle:NSLocalizedString(@"intelligent_manual", @"手动智能") secondTitle:NSLocalizedString(@"intelligent_auto", @"自动智能")];
    __weak typeof(self)weakSelf = self;
    self.customSheet.chooseIntelligentFirstBlock = ^{
        //MARK: 跳转手动智能
        TIoTAddManualIntelligentVC *addManualTask = [[TIoTAddManualIntelligentVC alloc]init];
        [weakSelf.navigationController pushViewController:addManualTask animated:YES];
        
    };
    self.customSheet.chooseIntelligentSecondBlock = ^{
        //MARK: 跳转自动智能
        TIoTAddAutoIntelligentVC *addAutoTask = [[TIoTAddAutoIntelligentVC alloc]init];
        addAutoTask.paramDic = @{@"FamilyId":[TIoTCoreUserManage shared].familyId,@"Offset":@(0),@"Limit":@(999)};
        [weakSelf.navigationController pushViewController:addAutoTask animated:YES];
    };
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.customSheet];
    [self.customSheet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([UIApplication sharedApplication].delegate.window);
        make.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
    }];
}

#pragma mark - lazy loading
- (UIView *)navCustomTopView {
    if (!_navCustomTopView) {
        
        CGFloat kTopHeight = [TIoTUIProxy shareUIProxy].statusHeight;
        
        _navCustomTopView = [[UIView alloc]initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, [TIoTUIProxy shareUIProxy].navigationBarHeight - [TIoTUIProxy shareUIProxy].statusHeight)];
        
        UIButton *addActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addActionButton setImage:[UIImage imageNamed:@"homeAdd"] forState:UIControlStateNormal];
        [addActionButton addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
        [_navCustomTopView addSubview:addActionButton];
        [addActionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-13*kScreenAllWidthScale);
            make.centerY.equalTo(_navCustomTopView.mas_centerY);
            make.width.height.mas_equalTo(24);
        }];
        
        
        UILabel *titleLab = [[UILabel alloc] init];
        [titleLab setLabelFormateTitle:NSLocalizedString(@"home_intelligent", @"智能") font:[UIFont boldSystemFontOfSize:20] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
        [_navCustomTopView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.centerX.equalTo(_navCustomTopView);
            make.height.mas_equalTo(kTopHeight);
            make.top.equalTo(_navCustomTopView.mas_top);
        }];
        
        _navCustomTopView.backgroundColor = [UIColor whiteColor];
        
    }
    return  _navCustomTopView;
}

- (CMPageTitleView *)pageView {
    if (!_pageView) {
        CMPageTitleView *pageTitleView = [[CMPageTitleView alloc] init];
        
        _pageView = pageTitleView;
    }
    
    return _pageView;
}

- (NSArray *)childControllers {
    if (!_childControllers) {
        
        self.intelligentVC = [[TIoTIntelligentVC alloc]init];
        TIoTIntelligentLogVC *intelligentVCLogVC = [[TIoTIntelligentLogVC alloc]init];
        
        self.intelligentVC.title = NSLocalizedString(@"mine_intelligent", @"我的智能");
        intelligentVCLogVC.title = NSLocalizedString(@"mine_intelligent_log", @"执行日志");
        
        _childControllers = @[self.intelligentVC,intelligentVCLogVC];
    }
    return _childControllers;
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
