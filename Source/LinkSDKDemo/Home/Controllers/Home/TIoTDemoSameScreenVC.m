//
//  TIoTDemoSameScreenVC.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoSameScreenVC.h"
#import "UIDevice+TIoTDemoRotateScreen.h"
#import "AppDelegate.h"
#import "UIImage+TIoTDemoExtension.h"
static CGFloat const kScreenScale = 0.5625; //9/16 高宽比

typedef NS_ENUM(NSInteger,TIoTDemoSameScreen) {
    TIoTDemoSameScreenOne = 1,
    TIoTDemoSameScreenTwo = 2,
    TIoTDemoSameScreenThree = 3,
    TIoTDemoSameScreenFour = 4,
};

@interface TIoTDemoSameScreenVC ()
@property (nonatomic, strong) NSArray *videoArray; //同屏视频数组
@property (nonatomic, strong) UIView *viewOne;
@property (nonatomic, strong) UIView *viewTwo;
@property (nonatomic, strong) UIView *viewThree;
@property (nonatomic, strong) UIView *viewFour;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *rotateScreenBtn;
@property (nonatomic, assign) CGRect screenRect; //屏幕竖屏尺寸
@end

@implementation TIoTDemoSameScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.screenRect = [UIApplication sharedApplication].delegate.window.frame;
    self.title = @"IoT Video Demo";
    [self addRotateNotification];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
}

- (void)addRotateNotification {
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOrientationChange:)
                                                name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self setNavigationBarTransparency];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self recoverNavigationBar];
    
    [self ratetePortrait];
}

- (void)setupNavBar {
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#FFFFFF"],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:17]}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage getGradientImageWithColors:@[[UIColor colorWithHexString:@"#ffffff"],[UIColor colorWithHexString:@"#ffffff"]] imgSize:CGSizeMake(kScreenWidth, 44)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)setupSameScreenSubviews {
    self.view.backgroundColor = [UIColor blackColor];
    CGFloat kSafeBottomHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    
    self.rotateScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rotateScreenBtn.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    self.rotateScreenBtn.layer.cornerRadius = 20;
    [self.rotateScreenBtn setImage:[UIImage imageNamed:@"rotate_screen"] forState:UIControlStateNormal];
    [self.rotateScreenBtn setButtonFormateWithTitlt:@"切换横屏" titleColorHexString:@"#ffffff" font:[UIFont wcPfRegularFontOfSize:15]];
    [self.rotateScreenBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 8)];
    [self.rotateScreenBtn addTarget:self action:@selector(rotateScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rotateScreenBtn];
        [self.rotateScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(116);
            make.height.mas_equalTo(40);
            make.right.equalTo(self.view.mas_right).offset(-16);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
                if (kSafeBottomHeight == 0) {
                    make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-34);
                }
            }else {
                make.bottom.equalTo(self.view.mas_bottom).offset(-34);
            }
    
        }];
}

///MARK:横屏
- (void)rotateLandscapeRight {
    [self setNavigationBarTransparency];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isRotation = YES;
    [UIDevice changeOrientation:UIInterfaceOrientationLandscapeRight];
}

///MARK:竖屏
- (void)ratetePortrait {
    [self setNavigationBarTransparency];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isRotation = NO;
    [UIDevice changeOrientation:UIInterfaceOrientationPortrait];
}

///MARK: 设置导航栏透明
- (void)setNavigationBarTransparency {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

///MARK: 恢复导航栏
- (void)recoverNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

#pragma mark - event

- (void)handleOrientationChange:(NSNotification *)notification{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:{
            //屏幕向左横置
            appDelegate.isRotation = YES;
            [self resetScreenSubviewsWithLandscape:YES viewArray:self.videoArray];
            break;
            }
        case UIDeviceOrientationLandscapeRight: {
            //屏幕向右橫置
            appDelegate.isRotation = YES;
            [self resetScreenSubviewsWithLandscape:YES viewArray:self.videoArray];
            break;
        }
        case UIDeviceOrientationPortrait: {
            //屏幕直立
            appDelegate.isRotation = NO;
            [self resetScreenSubviewsWithLandscape:NO viewArray:self.videoArray];
            break;
        }
        default:
            //无法辨识
            break;
    }
}

- (void)rotateScreen {
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.isRotation == YES) {
        appDelegate.isRotation = NO;
        [self ratetePortrait];
    }else {
        appDelegate.isRotation = YES;
        [self rotateLandscapeRight];
    }
    [self resetScreenSubviewsWithLandscape:appDelegate.isRotation viewArray:self.videoArray];
}

///MARK: 设置同屏设备初始化
- (void)setupSameScreenArray:(NSArray <TIoTExploreOrVideoDeviceModel *>*)array {
    self.videoArray = [NSArray arrayWithArray:array?:@[]];
    if (self.videoArray.count != 0 && self.videoArray.count <= 4) {
        switch (self.videoArray.count) {
            case TIoTDemoSameScreenOne: {
                self.viewOne = [[UIView alloc]init];
                self.viewOne.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
                [self.view addSubview:self.viewOne];
                [self.viewOne mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.center.equalTo(self.view);
                }];
                
                [self setupDeviceOne];
                [self setupOffLineTipWithView:self.viewOne];
                break;
            }
            case TIoTDemoSameScreenTwo: {
                
                self.viewOne = [[UIView alloc]init];
                self.viewOne.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
                [self.view addSubview:self.viewOne];
                [self.viewOne mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.bottom.equalTo(self.view.mas_centerY);
                }];
                
                self.viewTwo = [[UIView alloc]init];
                self.viewTwo.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
                [self.view addSubview:self.viewTwo];
                [self.viewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.viewOne.mas_bottom);
                }];
                
                [self setupDeviceOne];
                [self setupDeviceTwo];
                break;
            }
            case TIoTDemoSameScreenThree: {
                self.viewThree = [[UIView alloc]init];
                self.viewThree.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
                [self.view addSubview:self.viewThree];
                [self.viewThree mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.center.equalTo(self.view);
                }];
                self.viewOne = [[UIView alloc]init];
                self.viewOne.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
                [self.view addSubview:self.viewOne];
                [self.viewOne mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.bottom.equalTo(self.viewThree.mas_top);
                }];
                self.viewTwo = [[UIView alloc]init];
                self.viewTwo.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
                [self.view addSubview:self.viewTwo];
                [self.viewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.viewThree.mas_bottom);
                }];
                
                [self setupDeviceOne];
                [self setupDeviceTwo];
                [self setupDeviceThree];
                break;
            }
            case TIoTDemoSameScreenFour: {
                
                CGFloat kTopSpace = 64;
                if (@available(iOS 11.0, *)) {
                    kTopSpace = 44+[UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
                }
                
                self.scrollView = [[UIScrollView alloc]init];
                self.scrollView.backgroundColor = [UIColor blackColor];
                [self.view addSubview:self.scrollView];
                [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.height+kTopSpace);
                    make.top.equalTo(self.view.mas_top).offset(-kTopSpace);
                }];
                
                self.scrollView.contentSize = CGSizeMake(self.screenRect.size.width, self.screenRect.size.width*kScreenScale*4);
                
                self.viewOne = [[UIView alloc]init];
                self.viewOne.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
                [self.scrollView addSubview:self.viewOne];
                [self.viewOne mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.scrollView.mas_top);
                }];
                
                self.viewTwo = [[UIView alloc]init];
                self.viewTwo.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
                [self.scrollView addSubview:self.viewTwo];
                [self.viewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.viewOne.mas_bottom);
                }];
                
                self.viewThree = [[UIView alloc]init];
                self.viewThree.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
                [self.scrollView addSubview:self.viewThree];
                [self.viewThree mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.viewTwo.mas_bottom);
                }];
                
                self.viewFour = [[UIView alloc]init];
                self.viewFour.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
                [self.scrollView addSubview:self.viewFour];
                [self.viewFour mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.viewThree.mas_bottom);
                }];

                [self setupDeviceOne];
                [self setupDeviceTwo];
                [self setupDeviceThree];
                [self setupDeviceFour];
                break;
            }
            default:
                break;
        }
    }
    
    [self setupSameScreenSubviews];
}

///MARK: viewarray 约束更新适配屏幕
- (void)resetScreenSubviewsWithLandscape:(BOOL)rotation viewArray:(NSArray *)viewArray{
    if (rotation == YES) { //横屏
        [self.rotateScreenBtn setTitle:@"切换竖屏" forState:UIControlStateNormal];
        switch (self.videoArray.count) {
            case TIoTDemoSameScreenOne: {
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.screenRect.size.width);
                    make.width.mas_equalTo(self.screenRect.size.width/kScreenScale);
                    make.center.equalTo(self.view);
                }];
                break;
            }
            case TIoTDemoSameScreenTwo: {
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.height/2);
                    make.height.mas_equalTo(self.screenRect.size.height/2*kScreenScale);
                    make.right.equalTo(self.view.mas_centerX);
                    make.centerY.equalTo(self.view);
                }];
                
                [self.viewTwo mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.height/2);
                    make.height.mas_equalTo(self.screenRect.size.height/2*kScreenScale);
                    make.left.equalTo(self.viewOne.mas_right);
                    make.centerY.equalTo(self.viewOne);
                }];
                break;
            }
            case TIoTDemoSameScreenThree: {
                
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.screenRect.size.width/2);
                    make.width.mas_equalTo(self.screenRect.size.width/2/kScreenScale);
                    make.right.equalTo(self.view.mas_centerX);
                }];
                
                [self.viewTwo mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.screenRect.size.width/2);
                    make.width.mas_equalTo(self.screenRect.size.width/2/kScreenScale);
                    make.left.equalTo(self.viewOne.mas_right);
                }];
                
                [self.viewThree mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.screenRect.size.width/2);
                    make.width.mas_equalTo(self.screenRect.size.width/2/kScreenScale);
                    make.top.equalTo(self.viewOne.mas_bottom);
                    make.centerX.equalTo(self.view);
                }];
                
                break;
            }
            case TIoTDemoSameScreenFour: {
                
                CGFloat kTopSpace = 64;
                if (@available(iOS 11.0, *)) {
                    kTopSpace = 44+[UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
                }
                
                [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.height);
                    make.height.mas_equalTo(self.screenRect.size.width);
                    make.center.equalTo(self.view);
                    make.top.equalTo(self.view.mas_top).offset(-self.navigationController.navigationBar.frame.size.height);
                }];
                
                self.scrollView.contentSize = CGSizeMake(self.screenRect.size.height, self.screenRect.size.width);
                
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.screenRect.size.width/2);
                    make.width.mas_equalTo(self.screenRect.size.width/2/kScreenScale);
                    make.right.equalTo(self.scrollView.mas_centerX);
                }];
                
                [self.viewTwo mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.screenRect.size.width/2);
                    make.width.mas_equalTo(self.screenRect.size.width/2/kScreenScale);
                    make.left.equalTo(self.viewOne.mas_right);
                }];
                
                [self.viewThree mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.screenRect.size.width/2);
                    make.width.mas_equalTo(self.screenRect.size.width/2/kScreenScale);
                    make.right.equalTo(self.scrollView.mas_centerX);
                    make.top.equalTo(self.viewOne.mas_bottom);
                }];
                
                [self.viewFour mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.screenRect.size.width/2);
                    make.width.mas_equalTo(self.screenRect.size.width/2/kScreenScale);
                    make.left.equalTo(self.viewThree.mas_right);
                    make.top.equalTo(self.viewTwo.mas_bottom);
                }];
                break;
            }
            default:
                break;
        }
    }else { //竖屏
        [self.rotateScreenBtn setTitle:@"切换横屏" forState:UIControlStateNormal];
        switch (self.videoArray.count) {
            case TIoTDemoSameScreenOne: {
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.center.equalTo(self.view);
                }];
                break;
            }
            case TIoTDemoSameScreenTwo: {
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.bottom.equalTo(self.view.mas_centerY);
                }];
                [self.viewTwo mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.viewOne.mas_bottom);
                }];
                break;
            }
            case TIoTDemoSameScreenThree: {
                
                [self.viewThree mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.center.equalTo(self.view);
                }];
                
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.bottom.equalTo(self.viewThree.mas_top);
                }];
                
                [self.viewTwo mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.viewThree.mas_bottom);
                }];
                break;
            }
            case TIoTDemoSameScreenFour: {
                CGFloat kTopSpace = 64;
                if (@available(iOS 11.0, *)) {
                    kTopSpace = 44+[UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
                }

                [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.height+kTopSpace);
                    make.top.equalTo(self.view.mas_top).offset(-kTopSpace);
                }];
                
                self.scrollView.contentSize = CGSizeMake(self.screenRect.size.width, self.screenRect.size.width*kScreenScale*4);
                
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.scrollView.mas_top);
                }];
                
                [self.viewTwo mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.viewOne.mas_bottom);
                }];
                
                [self.viewThree mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.viewTwo.mas_bottom);
                }];
                
                [self.viewFour mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.top.equalTo(self.viewThree.mas_bottom);
                }];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - 添加设备名
- (void)setupDeviceOne {
    UILabel *lableOne = [[UILabel alloc]init];
    lableOne.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [lableOne setLabelFormateTitle:@"XXX" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    [self.viewOne addSubview:lableOne];
    [lableOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.viewOne.mas_left);
        make.bottom.equalTo(self.viewOne.mas_bottom);
    }];
}

- (void)setupDeviceTwo {
    UILabel *lableTwo = [[UILabel alloc]init];
    lableTwo.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [lableTwo setLabelFormateTitle:@"XXX" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    [self.viewTwo addSubview:lableTwo];
    [lableTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.viewTwo.mas_left);
        make.bottom.equalTo(self.viewTwo.mas_bottom);
    }];
}

- (void)setupDeviceThree {
    UILabel *lableThree = [[UILabel alloc]init];
    lableThree.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [lableThree setLabelFormateTitle:@"XXX" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    [self.viewThree addSubview:lableThree];
    [lableThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.viewThree.mas_left);
        make.bottom.equalTo(self.viewThree.mas_bottom);
    }];
}

- (void)setupDeviceFour {
    UILabel *lableFour = [[UILabel alloc]init];
    lableFour.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [lableFour setLabelFormateTitle:@"XXX" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    [self.viewFour addSubview:lableFour];
    [lableFour mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.viewFour.mas_left);
        make.bottom.equalTo(self.viewFour.mas_bottom);
    }];
}

- (void)setupOffLineTipWithView:(UIView *)videoView {
    UILabel *offLineLabel = [[UILabel alloc]init];
    [offLineLabel setLabelFormateTitle:@"设备离线" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    offLineLabel.backgroundColor = [UIColor colorWithHexString:kVideoBackgroundColor];
    [videoView addSubview:offLineLabel];
    [offLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(videoView.mas_centerX);
        make.centerY.equalTo(videoView.mas_centerY);
    }];
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
