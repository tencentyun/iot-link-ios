//
//  TIoTDemoSameScreenVC.m
//  LinkApp
//
//

#import "TIoTDemoSameScreenVC.h"
#import "UIDevice+TIoTDemoRotateScreen.h"
#import "AppDelegate.h"
#import "UIImage+TIoTDemoExtension.h"
#import "TIoTCoreXP2PBridge.h"
#import "NSString+Extension.h"
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import "TIoTCoreAppEnvironment.h"

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

@property(atomic, retain) IJKFFMoviePlayerController *playerOne;
@property (nonatomic, strong) NSString *videoUrlOne;
@property(atomic, retain) IJKFFMoviePlayerController *playerTwo;
@property (nonatomic, strong) NSString *videoUrlTwo;
@property(atomic, retain) IJKFFMoviePlayerController *playerThree;
@property (nonatomic, strong) NSString *videoUrlThree;
@property(atomic, retain) IJKFFMoviePlayerController *playerFour;
@property (nonatomic, strong) NSString *videoUrlFour;

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
    
    [self stopPlayMovie];
    [self.videoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TIoTExploreOrVideoDeviceModel *model = obj;
            [[TIoTCoreXP2PBridge sharedInstance] stopService:model.DeviceName?:@""];
    }];
    
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
                [self setupOffLineTipWithView:self.viewOne];
                [self setupOffLineTipWithView:self.viewTwo];
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
                
                [self setupOffLineTipWithView:self.viewOne];
                [self setupOffLineTipWithView:self.viewTwo];
                [self setupOffLineTipWithView:self.viewThree];
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

                [self setupOffLineTipWithView:self.viewOne];
                [self setupOffLineTipWithView:self.viewTwo];
                [self setupOffLineTipWithView:self.viewThree];
                [self setupOffLineTipWithView:self.viewFour];
                break;
            }
            default:
                break;
        }
    }
    
    [self setupSameScreenSubviews];

    [self installMovieNotificationObservers];
    
    [self addLoadStateDidChangeNotificationScreenNumber:self.videoArray.count];
    
    // 初始化播放器
    [self initVideoPlayer];
    
    [self configVideo];
}

///MARK: viewarray 约束更新适配屏幕
- (void)resetScreenSubviewsWithLandscape:(BOOL)rotation viewArray:(NSArray *)viewArray{
    if (rotation == YES) { //横屏
        self.screenRect = [UIApplication sharedApplication].delegate.window.frame;
        [self.rotateScreenBtn setTitle:@"切换竖屏" forState:UIControlStateNormal];
        switch (self.videoArray.count) {
            case TIoTDemoSameScreenOne: {
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.height/kScreenScale);
                    make.height.mas_equalTo(self.screenRect.size.height);
                    make.center.equalTo(self.view);
                }];
                break;
            }
            case TIoTDemoSameScreenTwo: {
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_offset(self.screenRect.size.width/2);
                    make.height.mas_equalTo(self.screenRect.size.width/2*kScreenScale);
                    make.right.equalTo(self.view.mas_centerX);
                    make.centerY.equalTo(self.view);
                }];
                
                [self.viewTwo mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.equalTo(self.viewOne);
                    make.left.equalTo(self.viewOne.mas_right);
                    make.centerY.equalTo(self.viewOne);
                }];
                break;
            }
            case TIoTDemoSameScreenThree: {
                
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.screenRect.size.height/2);
                    make.width.mas_equalTo(self.screenRect.size.height/2/kScreenScale);
                    make.right.equalTo(self.view.mas_centerX);
                }];
                
                [self.viewTwo mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.equalTo(self.viewOne);
                    make.left.equalTo(self.viewOne.mas_right);
                }];
                
                [self.viewThree mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.equalTo(self.viewOne);
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
                    make.height.mas_equalTo(self.screenRect.size.height);
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.center.equalTo(self.view);
                    make.top.equalTo(self.view.mas_top).offset(-self.navigationController.navigationBar.frame.size.height);
                }];
                
                self.scrollView.contentSize = CGSizeMake(self.screenRect.size.height, self.screenRect.size.width);
                
                [self.viewOne mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.screenRect.size.height/2);
                    make.width.mas_equalTo(self.screenRect.size.height/2/kScreenScale);
                    make.right.equalTo(self.scrollView.mas_centerX);
                    make.top.equalTo(self.scrollView.mas_top);
                }];
                
                [self.viewTwo mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.equalTo(self.viewOne);
                    make.left.equalTo(self.viewOne.mas_right);
                    make.top.equalTo(self.viewOne.mas_top);
                }];
                
                [self.viewThree mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.equalTo(self.viewOne);
                    make.right.equalTo(self.scrollView.mas_centerX);
                    make.top.equalTo(self.viewOne.mas_bottom);
                }];
                
                [self.viewFour mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.equalTo(self.viewOne);
                    make.left.equalTo(self.viewThree.mas_right);
                    make.top.equalTo(self.viewTwo.mas_bottom);
                }];
                break;
            }
            default:
                break;
        }
    }else { //竖屏
        self.screenRect = [UIApplication sharedApplication].delegate.window.frame;
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

#pragma mark -设置 play
///MARK: 初始化播放器
- (void)initVideoPlayer {
    
    if (self.videoArray.count != 0) {
        [self.videoArray enumerateObjectsUsingBlock:^(TIoTExploreOrVideoDeviceModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TIoTExploreOrVideoDeviceModel *model = obj;
            [[TIoTCoreXP2PBridge sharedInstance] startAppWith:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretId
                                                      sec_key:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretKey
                                                       pro_id:[TIoTCoreAppEnvironment shareEnvironment].cloudProductId
                                                     dev_name:model.DeviceName?:@""];
        }];
        
        switch (self.videoArray.count) {
            case TIoTDemoSameScreenOne: {
                TIoTExploreOrVideoDeviceModel *model = self.videoArray[TIoTDemoSameScreenOne - TIoTDemoSameScreenOne];
                NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:model.DeviceName]?:@"";
                self.videoUrlOne = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
                break;
            }
            case TIoTDemoSameScreenTwo: {
                TIoTExploreOrVideoDeviceModel *modelOne = self.videoArray[TIoTDemoSameScreenTwo - TIoTDemoSameScreenTwo];
                TIoTExploreOrVideoDeviceModel *modelTwo = self.videoArray[TIoTDemoSameScreenTwo - TIoTDemoSameScreenOne];
                
                NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:modelOne.DeviceName]?:@"";
                self.videoUrlOne = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
                
                NSString *urlStringTwo = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:modelTwo.DeviceName]?:@"";
                self.videoUrlTwo = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlStringTwo];
                break;
            }
            case TIoTDemoSameScreenThree: {
                TIoTExploreOrVideoDeviceModel *modelOne = self.videoArray[TIoTDemoSameScreenThree - TIoTDemoSameScreenThree];
                TIoTExploreOrVideoDeviceModel *modelTwo = self.videoArray[TIoTDemoSameScreenThree - TIoTDemoSameScreenTwo];
                TIoTExploreOrVideoDeviceModel *modelThree = self.videoArray[TIoTDemoSameScreenThree - TIoTDemoSameScreenOne];
                
                NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:modelOne.DeviceName]?:@"";
                self.videoUrlOne = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
                
                NSString *urlStringTwo = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:modelTwo.DeviceName]?:@"";
                self.videoUrlTwo = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlStringTwo];
                
                NSString *urlStringThree = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:modelThree.DeviceName]?:@"";
                self.videoUrlThree = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlStringThree];
                
                break;
            }
            case TIoTDemoSameScreenFour: {
                TIoTExploreOrVideoDeviceModel *modelOne = self.videoArray[TIoTDemoSameScreenFour - TIoTDemoSameScreenFour];
                TIoTExploreOrVideoDeviceModel *modelTwo = self.videoArray[TIoTDemoSameScreenFour - TIoTDemoSameScreenThree];
                TIoTExploreOrVideoDeviceModel *modelThree = self.videoArray[TIoTDemoSameScreenFour - TIoTDemoSameScreenTwo];
                TIoTExploreOrVideoDeviceModel *modelFour = self.videoArray[TIoTDemoSameScreenFour - TIoTDemoSameScreenOne];
                
                NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:modelOne.DeviceName]?:@"";
                self.videoUrlOne = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
                
                NSString *urlStringTwo = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:modelTwo.DeviceName]?:@"";
                self.videoUrlTwo = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlStringTwo];
                
                NSString *urlStringThree = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:modelThree.DeviceName]?:@"";
                self.videoUrlThree = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlStringThree];
                
                NSString *urlStringFour = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:modelFour.DeviceName]?:@"";
                self.videoUrlFour = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlStringFour];
                
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark -IJKPlayer
- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started

    switch (self.videoArray.count) {
        case TIoTDemoSameScreenOne: {
            IJKMPMovieLoadState loadState = self.playerOne.loadState;

            if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
                NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
                TIoTExploreOrVideoDeviceModel *modelOne = self.videoArray[TIoTDemoSameScreenOne - TIoTDemoSameScreenOne];
                [self setupDeviceOneWithName:modelOne.DeviceName];
            }
            
            break;
        }
        case TIoTDemoSameScreenTwo: {
            IJKMPMovieLoadState loadState = self.playerTwo.loadState;

            if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
                NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
                TIoTExploreOrVideoDeviceModel *modelTwo = self.videoArray[TIoTDemoSameScreenTwo - TIoTDemoSameScreenOne];
                [self setupDeviceTwoWithName:modelTwo.DeviceName];
            }
            break;
        }
        case TIoTDemoSameScreenThree: {
            IJKMPMovieLoadState loadState = self.playerThree.loadState;

            if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
                NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
                TIoTExploreOrVideoDeviceModel *modelThree = self.videoArray[TIoTDemoSameScreenThree - TIoTDemoSameScreenOne];
                [self setupDeviceThreeWithName:modelThree.DeviceName];
            }
            break;
        }
        case TIoTDemoSameScreenFour: {
            IJKMPMovieLoadState loadState = self.playerFour.loadState;

            if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
                NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
                TIoTExploreOrVideoDeviceModel *modelFour = self.videoArray[TIoTDemoSameScreenFour - TIoTDemoSameScreenOne];
                
                [self setupDeviceFourWithName:modelFour.DeviceName];
            }
            break;
        }
        default:
            break;
    }
    
}

#pragma mark Install Movie Notifications
-(void)installMovieNotificationObservers
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refushVideo:)
                                                 name:@"xp2preconnect"
                                               object:nil];
}

- (void)addLoadStateDidChangeNotificationScreenNumber:(TIoTDemoSameScreen)screenType {
    switch (self.videoArray.count) {
        case TIoTDemoSameScreenOne: {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadStateDidChange:)
                                                         name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.playerOne];
            break;
        }
        case TIoTDemoSameScreenTwo: {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadStateDidChange:)
                                                         name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.playerOne];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadStateDidChange:)
                                                         name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.playerTwo];
            break;
        }
        case TIoTDemoSameScreenThree: {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadStateDidChange:)
                                                         name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.playerOne];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadStateDidChange:)
                                                         name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.playerTwo];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadStateDidChange:)
                                                         name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.playerThree];
            break;
        }
        case TIoTDemoSameScreenFour: {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadStateDidChange:)
                                                         name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.playerOne];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadStateDidChange:)
                                                         name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.playerTwo];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadStateDidChange:)
                                                         name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.playerThree];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadStateDidChange:)
                                                         name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.playerFour];
            break;
        }
        default:
            break;
    }
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [self removeStatusChangeNotificationWithScreenNumber:self.videoArray.count];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"xp2preconnect" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeStatusChangeNotificationWithScreenNumber:(TIoTDemoSameScreen)screenType {
    switch (self.videoArray.count) {
        case TIoTDemoSameScreenOne: {
            [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.playerOne];
            break;
        }
        case TIoTDemoSameScreenTwo: {
            [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.playerOne];
            [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.playerTwo];
            break;
        }
        case TIoTDemoSameScreenThree: {
            [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.playerOne];
            [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.playerTwo];
            [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.playerThree];
            break;
        }
        case TIoTDemoSameScreenFour: {
            [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.playerOne];
            [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.playerTwo];
            [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.playerThree];
            [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.playerFour];
            break;
        }
        default:
            break;
    }
}
- (void)refushVideo:(NSNotification *)notify {
    
    NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
    
    [self.videoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TIoTExploreOrVideoDeviceModel *model = obj;
        if ([DeviceName isEqualToString:model.DeviceName]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:model.DeviceName]?:@"";
                switch (idx+1) {
                    case TIoTDemoSameScreenOne: {
                        self.videoUrlOne = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
                        
                        [self refreshConfig:TIoTDemoSameScreenOne];

                        [self.playerOne prepareToPlay];
                        [self.playerOne play];
                        break;
                    }
                    case TIoTDemoSameScreenTwo: {
                        self.videoUrlTwo = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
                        
                        [self refreshConfig:TIoTDemoSameScreenTwo];

                        [self.playerTwo prepareToPlay];
                        [self.playerTwo play];
                        break;
                    }
                    case TIoTDemoSameScreenThree: {
                        self.videoUrlThree = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
                        
                        [self refreshConfig:TIoTDemoSameScreenThree];
                        
                        [self.playerThree prepareToPlay];
                        [self.playerThree play];
                        break;
                    }
                    case TIoTDemoSameScreenFour: {
                        self.videoUrlFour = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
                        
                        [self refreshConfig:TIoTDemoSameScreenFour];
                        
                        [self.playerFour prepareToPlay];
                        [self.playerFour play];
                        
                        break;
                    }
                    default:
                        break;
                }
            });
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    switch (self.videoArray.count) {
        case TIoTDemoSameScreenOne: {
            [self.playerOne shutdown];
            break;
        }
        case TIoTDemoSameScreenTwo: {
            [self.playerOne shutdown];
            [self.playerTwo shutdown];
            break;
        }
        case TIoTDemoSameScreenThree: {
            [self.playerOne shutdown];
            [self.playerTwo shutdown];
            [self.playerThree shutdown];
            break;
        }
        case TIoTDemoSameScreenFour: {
            [self.playerOne shutdown];
            [self.playerTwo shutdown];
            [self.playerThree shutdown];
            [self.playerFour shutdown];
            break;
        }
        default:
            break;
    }
    
    [self removeMovieNotificationObservers];
    
    if ([TIoTCoreXP2PBridge sharedInstance].writeFile) {
        [self.videoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TIoTExploreOrVideoDeviceModel *model = obj;
            [[TIoTCoreXP2PBridge sharedInstance] stopAvRecvService:model.DeviceName];
        }];
        
    }
}

- (void)stopPlayMovie {
    
    switch (self.videoArray.count) {
        case TIoTDemoSameScreenOne: {
            [self.playerOne stop];
            break;
        }
        case TIoTDemoSameScreenTwo: {
            [self.playerOne stop];
            [self.playerTwo stop];
            break;
        }
        case TIoTDemoSameScreenThree: {
            [self.playerOne stop];
            [self.playerTwo stop];
            [self.playerThree stop];
            break;
        }
        case TIoTDemoSameScreenFour: {
            [self.playerOne stop];
            [self.playerTwo stop];
            [self.playerThree stop];
            [self.playerFour stop];
            break;
        }
        default:
            break;
    }
}

- (void)configVideo {
    if ([TIoTCoreXP2PBridge sharedInstance].writeFile) {

        switch (self.videoArray.count) {
            case TIoTDemoSameScreenOne: {
                UILabel *fileTip = [[UILabel alloc] initWithFrame:self.viewOne.bounds];
                [fileTip setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewOne addSubview:fileTip];
                break;
            }
            case TIoTDemoSameScreenTwo: {
                UILabel *fileTipOne = [[UILabel alloc] initWithFrame:self.viewOne.bounds];
                [fileTipOne setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewOne addSubview:fileTipOne];
                UILabel *fileTipTwo = [[UILabel alloc] initWithFrame:self.viewTwo.bounds];
                [fileTipTwo setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewTwo addSubview:fileTipTwo];
                break;
            }
            case TIoTDemoSameScreenThree: {
                UILabel *fileTipOne = [[UILabel alloc] initWithFrame:self.viewOne.bounds];
                [fileTipOne setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewOne addSubview:fileTipOne];
                UILabel *fileTipTwo = [[UILabel alloc] initWithFrame:self.viewTwo.bounds];
                [fileTipTwo setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewTwo addSubview:fileTipTwo];
                UILabel *fileTipThree = [[UILabel alloc] initWithFrame:self.viewTwo.bounds];
                [fileTipThree setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewThree addSubview:fileTipThree];
                break;
            }
            case TIoTDemoSameScreenFour: {
                UILabel *fileTipOne = [[UILabel alloc] initWithFrame:self.viewOne.bounds];
                [fileTipOne setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewOne addSubview:fileTipOne];
                UILabel *fileTipTwo = [[UILabel alloc] initWithFrame:self.viewTwo.bounds];
                [fileTipTwo setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewTwo addSubview:fileTipTwo];
                UILabel *fileTipThree = [[UILabel alloc] initWithFrame:self.viewTwo.bounds];
                [fileTipThree setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewThree addSubview:fileTipThree];
                UILabel *fileTipFour = [[UILabel alloc] initWithFrame:self.viewTwo.bounds];
                [fileTipFour setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewFour addSubview:fileTipFour];
                break;
            }
            default:
                break;
        }
        
        [self.videoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TIoTExploreOrVideoDeviceModel *model = obj;
            [[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:model.DeviceName cmd:@"action=live"];
        }];
        
    }else {
        [self stopPlayMovie];
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:YES];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
        
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];
        
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        
        
        switch (self.videoArray.count) {
            case TIoTDemoSameScreenOne: {
                self.playerOne = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlOne] withOptions:options];
                self.playerOne.view.frame = self.viewOne.bounds;
                [self setupPlayerPropertyWith:self.playerOne];
                [self.viewOne addSubview:self.playerOne.view];
                [self setupPlayerParamWith:self.playerOne];
                break;
            }
            case TIoTDemoSameScreenTwo: {
                self.playerOne = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlOne] withOptions:options];
                self.playerOne.view.frame = self.viewOne.bounds;
                [self setupPlayerPropertyWith:self.playerOne];
                [self.viewOne addSubview:self.playerOne.view];
                [self setupPlayerParamWith:self.playerOne];
                
                self.playerTwo = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlTwo] withOptions:options];
                self.playerTwo.view.frame = self.viewTwo.bounds;
                [self setupPlayerPropertyWith:self.playerTwo];
                self.view.autoresizesSubviews = YES;
                [self.viewTwo addSubview:self.playerTwo.view];
                [self setupPlayerParamWith:self.playerTwo];
                
                break;
            }
            case TIoTDemoSameScreenThree: {
                self.playerOne = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlOne] withOptions:options];
                self.playerOne.view.frame = self.viewOne.bounds;
                [self setupPlayerPropertyWith:self.playerOne];
                [self.viewOne addSubview:self.playerOne.view];
                [self setupPlayerParamWith:self.playerOne];
                
                self.playerTwo = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlTwo] withOptions:options];
                self.playerTwo.view.frame = self.viewTwo.bounds;
                [self setupPlayerPropertyWith:self.playerTwo];
                [self.viewTwo addSubview:self.playerTwo.view];
                [self setupPlayerParamWith:self.playerTwo];
                
                self.playerThree = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlThree] withOptions:options];
                self.playerThree.view.frame = self.viewThree.bounds;
                [self setupPlayerPropertyWith:self.playerThree];
                [self.viewThree addSubview:self.playerThree.view];
                [self setupPlayerParamWith:self.playerThree];
                
                break;
            }
            case TIoTDemoSameScreenFour: {
                
                self.playerOne = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlOne] withOptions:options];
                self.playerOne.view.frame = self.viewOne.bounds;
                [self setupPlayerPropertyWith:self.playerOne];
                [self.viewOne addSubview:self.playerOne.view];
                [self setupPlayerParamWith:self.playerOne];
                
                self.playerTwo = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlTwo] withOptions:options];
                self.playerTwo.view.frame = self.viewTwo.bounds;
                [self setupPlayerPropertyWith:self.playerTwo];
                [self.viewTwo addSubview:self.playerTwo.view];
                [self setupPlayerParamWith:self.playerTwo];
                
                self.playerThree = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlThree] withOptions:options];
                self.playerThree.view.frame = self.viewThree.bounds;
                [self setupPlayerPropertyWith:self.playerThree];
                [self.viewThree addSubview:self.playerThree.view];
                [self setupPlayerParamWith:self.playerThree];
                
                self.playerFour = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlFour] withOptions:options];
                self.playerFour.view.frame = self.viewFour.bounds;
                [self setupPlayerPropertyWith:self.playerFour];
                [self.viewFour addSubview:self.playerFour.view];
                [self setupPlayerParamWith:self.playerFour];
                break;
            }
            default:
                break;
        }
        
    }
}

#pragma mark - ijkPlayer启动/重连设置
- (void)refreshConfig:(TIoTDemoSameScreen)type {
    switch (type) {
        case TIoTDemoSameScreenOne: {
            
            if ([TIoTCoreXP2PBridge sharedInstance].writeFile) {
                
                UILabel *fileTipOne = [[UILabel alloc] initWithFrame:self.viewOne.bounds];
                [fileTipOne setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewOne addSubview:fileTipOne];
                
                [self.videoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    TIoTExploreOrVideoDeviceModel *model = obj;
                    [[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:model.DeviceName cmd:@"action=live"];
                }];
            }else {
                [self stopPlayerOne];
                
                IJKFFOptions *option = [self setupCommonIJKPlayerProperty];
                [self setupIJKPlayerParamWith:option withType:TIoTDemoSameScreenOne];
            }
            break;
        }
        case TIoTDemoSameScreenTwo: {
            
            if ([TIoTCoreXP2PBridge sharedInstance].writeFile) {
                UILabel *fileTipTwo = [[UILabel alloc] initWithFrame:self.viewTwo.bounds];
                [fileTipTwo setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewTwo addSubview:fileTipTwo];
                
                [self.videoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    TIoTExploreOrVideoDeviceModel *model = obj;
                    [[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:model.DeviceName cmd:@"action=live"];
                }];
                
            }else {
                [self stopPlayerTwo];
                
                IJKFFOptions *option = [self setupCommonIJKPlayerProperty];
                [self setupIJKPlayerParamWith:option withType:TIoTDemoSameScreenTwo];
            }
            break;
        }
        case TIoTDemoSameScreenThree: {
            
            if ([TIoTCoreXP2PBridge sharedInstance].writeFile) {
                
                UILabel *fileTipThree = [[UILabel alloc] initWithFrame:self.viewTwo.bounds];
                [fileTipThree setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewThree addSubview:fileTipThree];
                
                [self.videoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    TIoTExploreOrVideoDeviceModel *model = obj;
                    [[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:model.DeviceName cmd:@"action=live"];
                }];
                
            }else {
                [self stopPlayerThree];
                
                IJKFFOptions *option = [self setupCommonIJKPlayerProperty];
                [self setupIJKPlayerParamWith:option withType:TIoTDemoSameScreenThree];
            }
            
            break;
        }
        case TIoTDemoSameScreenFour: {
            
            if ([TIoTCoreXP2PBridge sharedInstance].writeFile) {
                
                UILabel *fileTipFour = [[UILabel alloc] initWithFrame:self.viewTwo.bounds];
                [fileTipFour setLabelFormateTitle:@"数据帧写文件中..." font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
                [self.viewFour addSubview:fileTipFour];
                
                [self.videoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    TIoTExploreOrVideoDeviceModel *model = obj;
                    [[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:model.DeviceName cmd:@"action=live"];
                }];
                
            }else {
                [self stopPlayerFour];
                
                IJKFFOptions *option = [self setupCommonIJKPlayerProperty];
                [self setupIJKPlayerParamWith:option withType:TIoTDemoSameScreenFour];
            }
            
            break;
        }
        default:
            break;
    }
}

///MARK: ijkPlayer销毁
- (void)stopPlayerOne {
    [self.playerOne stop];
    self.playerOne = nil;
}

- (void)stopPlayerTwo {
    [self.playerTwo stop];
    self.playerFour = nil;
}

- (void)stopPlayerThree {
    [self.playerThree stop];
    self.playerThree = nil;
}

- (void)stopPlayerFour {
    [self.playerFour stop];
    self.playerFour = nil;
}

///MARK: ijkPlayer准备设置
- (IJKFFOptions *)setupCommonIJKPlayerProperty {
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:YES];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
        
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];
        
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    
    return options;
}

- (void)setupIJKPlayerParamWith:(IJKFFOptions *)options withType:(TIoTDemoSameScreen)screenType {
    
    switch (screenType) {
        case TIoTDemoSameScreenOne: {
            self.playerOne = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlOne] withOptions:options];
            self.playerOne.view.frame = self.viewOne.bounds;
            [self setupPlayerPropertyWith:self.playerOne];
            [self.viewOne addSubview:self.playerOne.view];
            [self setupPlayerParamWith:self.playerOne];
            
            break;
        }
        case TIoTDemoSameScreenTwo: {
            
            self.playerTwo = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlTwo] withOptions:options];
            self.playerTwo.view.frame = self.viewTwo.bounds;
            [self setupPlayerPropertyWith:self.playerTwo];
            self.view.autoresizesSubviews = YES;
            [self.viewTwo addSubview:self.playerTwo.view];
            [self setupPlayerParamWith:self.playerTwo];
            
            break;
        }
        case TIoTDemoSameScreenThree: {
            self.playerThree = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlThree] withOptions:options];
            self.playerThree.view.frame = self.viewThree.bounds;
            [self setupPlayerPropertyWith:self.playerThree];
            [self.viewThree addSubview:self.playerThree.view];
            [self setupPlayerParamWith:self.playerThree];
            break;
        }
        case TIoTDemoSameScreenFour: {
            self.playerFour = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrlFour] withOptions:options];
            self.playerFour.view.frame = self.viewFour.bounds;
            [self setupPlayerPropertyWith:self.playerFour];
            [self.viewFour addSubview:self.playerFour.view];
            [self setupPlayerParamWith:self.playerFour];
            break;
        }
        default:
            break;
    }
    
}

- (void)setupPlayerPropertyWith:(IJKFFMoviePlayerController *)player {
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    player.scalingMode = IJKMPMovieScalingModeAspectFit;
    player.shouldAutoplay = YES;
    self.view.autoresizesSubviews = YES;
}

- (void)setupPlayerParamWith:(IJKFFMoviePlayerController *)player {
    [player setOptionIntValue:10 * 1000 forKey:@"analyzeduration" ofCategory:kIJKFFOptionCategoryFormat];
    [player setOptionIntValue:10 * 1024 forKey:@"probesize" ofCategory:kIJKFFOptionCategoryFormat];
    [player setOptionIntValue:0 forKey:@"packet-buffering" ofCategory:kIJKFFOptionCategoryPlayer];
    [player setOptionIntValue:1 forKey:@"start-on-prepared" ofCategory:kIJKFFOptionCategoryPlayer];
    [player setOptionIntValue:1 forKey:@"threads" ofCategory:kIJKFFOptionCategoryCodec];
    [player setOptionIntValue:0 forKey:@"sync-av-start" ofCategory:kIJKFFOptionCategoryPlayer];
}

#pragma mark - 添加设备名
- (void)setupDeviceOneWithName:(NSString *)name {
    UILabel *lableOne = [[UILabel alloc]init];
    lableOne.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [lableOne setLabelFormateTitle:name?:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    [self.viewOne addSubview:lableOne];
    [lableOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.viewOne.mas_left);
        make.bottom.equalTo(self.viewOne.mas_bottom);
    }];
}

- (void)setupDeviceTwoWithName:(NSString *)name {
    UILabel *lableTwo = [[UILabel alloc]init];
    lableTwo.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [lableTwo setLabelFormateTitle:name?:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    [self.viewTwo addSubview:lableTwo];
    [lableTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.viewTwo.mas_left);
        make.bottom.equalTo(self.viewTwo.mas_bottom);
    }];
}

- (void)setupDeviceThreeWithName:(NSString *)name {
    UILabel *lableThree = [[UILabel alloc]init];
    lableThree.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [lableThree setLabelFormateTitle:name?:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    [self.viewThree addSubview:lableThree];
    [lableThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.viewThree.mas_left);
        make.bottom.equalTo(self.viewThree.mas_bottom);
    }];
}

- (void)setupDeviceFourWithName:(NSString *)name {
    UILabel *lableFour = [[UILabel alloc]init];
    lableFour.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [lableFour setLabelFormateTitle:name?:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
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
