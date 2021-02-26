//
//  TIoTBaseMapViewController.m

#import "TIoTBaseMapViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface TIoTBaseMapViewController ()<CLLocationManagerDelegate>
@property (nonatomic, strong, readwrite) QMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation TIoTBaseMapViewController

- (void)handleTestAction
{
    
}

- (NSString *)testTitle
{
    return @"Test";
}

#pragma mark - Setup

- (void)setupNavigationBar
{
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *testItem = [[UIBarButtonItem alloc] initWithTitle:[self testTitle]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(handleTestAction)];
    self.navigationItem.rightBarButtonItem = testItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationwillenterforegound) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)setupMapView
{
    self.mapView = [[QMapView alloc]
                    initWithFrame: CGRectMake(0,
                                              0,
                                              CGRectGetWidth(self.view.frame),
                                              CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    self.mapView.delegate = self;
    
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(39.901268, 116.403854);
    self.mapView.zoomLevel        = 11;
    
    // 开启定位
    [self.mapView setShowsUserLocation:YES];
    self.mapView.userTrackingMode = QUserTrackingModeFollow;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
//    });
    
    [self.view addSubview:self.mapView];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    [self setupMapView];
    
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        {
            self.mapView.mapType = QMapTypeDark;
        }
        else
        {
            self.mapView.mapType = QMapTypeStandard;
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        {
            self.mapView.mapType = QMapTypeDark;
        }
        else
        {
            self.mapView.mapType = QMapTypeStandard;
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)applicationwillenterforegound
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    });
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [manager requestWhenInUseAuthorization];
    }
    else
    {
        [self showLocationTips];
    }
}

- (void)showLocationTips
{

    if(![CLLocationManager locationServicesEnabled]){
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Name = [infoDict objectForKey:@"CFBundleDisplayName"];
        if (app_Name == nil) {
            app_Name = [infoDict objectForKey:@"CFBundleName"];
        }
        
        NSString *messageString = [NSString stringWithFormat:@"[前往：设置 - 隐私 - 定位服务 - %@] 允许应用访问", app_Name];
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"APPacquireLocation", @"App需要访问您的位置用于获取Wi-Fi信息") message:messageString preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", @"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"turnon_LocationService", @"前往：设置开启定位服务")];
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"APPacquireLocation", @"App需要访问您的位置用于获取Wi-Fi信息") message:messageString preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", @"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"成功");
                }
                else
                {
                    NSLog(@"失败");
                }
            }];
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
        
    }
}

@end
