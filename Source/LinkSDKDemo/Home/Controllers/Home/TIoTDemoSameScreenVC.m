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

@property (nonatomic, strong) UIButton *rotateScreenBtn;
@property (nonatomic, assign) CGRect screenRect; //屏幕竖屏尺寸
@end

@implementation TIoTDemoSameScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.screenRect = [UIScreen mainScreen].bounds;
    
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
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self recoverNavigationBar];
    
    [self ratetePortrait];
}

- (void)setupSameScreenSubviews {
    self.view.backgroundColor = [UIColor blackColor];
    CGFloat kSafeBottomHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    
    self.rotateScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rotateScreenBtn.backgroundColor = [UIColor yellowColor];
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
    [self recoverNavigationBar];
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
            [self recoverNavigationBar];
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

- (void)setupSameScreenArray:(NSArray <TIoTExploreOrVideoDeviceModel *>*)array {
    self.videoArray = [NSArray arrayWithArray:array?:@[]];
    if (self.videoArray.count != 0 && self.videoArray.count <= 4) {
        switch (self.videoArray.count) {
            case TIoTDemoSameScreenOne: {
//                CGRect viewFrame = self.view.frame;
                self.viewOne = [[UIView alloc]init];
                self.viewOne.backgroundColor = [UIColor redColor];
                [self.view addSubview:self.viewOne];
                [self.viewOne mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.screenRect.size.width);
                    make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
                    make.center.equalTo(self.view);
                }];
                break;
            }
            case TIoTDemoSameScreenTwo: {
                break;;
            }
            case TIoTDemoSameScreenThree: {
                break;
            }
            case TIoTDemoSameScreenFour: {
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
                break;
            }
            case TIoTDemoSameScreenThree: {
                break;
            }
            case TIoTDemoSameScreenFour: {
                break;
            }
            default:
                break;
        }
    }else { //竖屏
//        CGRect viewFrame = self.view.frame;
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
                break;
            }
            case TIoTDemoSameScreenThree: {
                break;
            }
            case TIoTDemoSameScreenFour: {
                break;
            }
            default:
                break;
        }
    }
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
