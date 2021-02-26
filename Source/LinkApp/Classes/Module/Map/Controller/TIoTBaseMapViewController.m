//
//  TIoTBaseMapViewController.m

#import "TIoTBaseMapViewController.h"

@interface TIoTBaseMapViewController ()

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
}

- (void)setupMapView
{
    self.mapView = [[QMapView alloc]
                    initWithFrame: CGRectMake(0,
                                              0,
                                              CGRectGetWidth(self.view.frame),
                                              CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    self.mapView.delegate = self;
    
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(40.901268, 116.403854);
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

@end
