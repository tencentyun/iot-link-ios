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
@end

@implementation TIoTDemoSameScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSameScreenSubviews];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)setupSameScreenSubviews {
    self.view.backgroundColor = [UIColor blackColor];
    
    
    CGRect screenframe = [UIScreen mainScreen].bounds;
    CGFloat bottomPadding = 64;
    if (@available(iOS 11.0, *)) {
        bottomPadding = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top + 64 + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    
    self.rotateScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rotateScreenBtn.frame = CGRectMake(screenframe.size.width - 116 - 16, screenframe.size.height - bottomPadding - 40, 116, 40);
    self.rotateScreenBtn.backgroundColor = [UIColor yellowColor];
    [self.rotateScreenBtn addTarget:self action:@selector(rotateScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rotateScreenBtn];
}

- (void)rotateLandscapeRight {
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isRotation = YES;
    [UIDevice changeOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)ratetePortrait {
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isRotation = NO;
    [UIDevice changeOrientation:UIInterfaceOrientationPortrait];
}

#pragma mark - event

- (void)rotateScreen {
    
    CGRect viewFrame = self.view.frame;
    
    self.viewOne.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.height, viewFrame.size.width);
    [self.view layoutSubviews];
}

- (void)setupSameScreenArray:(NSArray <TIoTExploreOrVideoDeviceModel *>*)array {
    self.videoArray = [NSArray arrayWithArray:array?:@[]];
    if (self.videoArray.count != 0 && self.videoArray.count <= 4) {
        switch (self.videoArray.count) {
            case TIoTDemoSameScreenOne: {
                CGRect viewFrame = self.view.frame;
                
                self.viewOne = [[UIView alloc]initWithFrame:CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height/4)];
                self.viewOne.backgroundColor = [UIColor redColor];
                [self.view addSubview:self.viewOne];
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
