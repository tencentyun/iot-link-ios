//
//  TIoTMapViewController.m

#import "TIoTMapViewController.h"
#import <QMapKit/QMSSearchOption.h>
#import <QMapKit/QMSSearcher.h>
#import <QMapKit/QMSSearchServices.h>

@interface TIoTMapViewController () <UIGestureRecognizerDelegate, QMSSearchDelegate>
@property (nonatomic, strong) QMSSearcher *mySearcher;
@end

@implementation TIoTMapViewController

- (void)handleTestAction
{
//    self.mapView.mapType = self.mapView.mapType == QMapTypeStandard ? QMapTypeDark : QMapTypeStandard;
    
    QMSReverseGeoCodeSearchOption *revGeoOption = [[QMSReverseGeoCodeSearchOption alloc] init];

    [revGeoOption setLocationWithCenterCoordinate:CLLocationCoordinate2DMake(39.939791, 116.444579)];

    [revGeoOption setGet_poi:YES];

    revGeoOption.poi_options = @"radius=5000;page_size=20;page_index=1";

    [self.mySearcher searchWithReverseGeoCodeSearchOption:revGeoOption];
}

- (NSString *)testTitle
{
    return @"暗色样式";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [QMapServices sharedServices].APIKey = @"XXX";
    [[QMSSearchServices sharedServices] setApiKey:@"XXX"];
    
    self.mySearcher = [[QMSSearcher alloc] initWithDelegate:self];
    self.mapView.showsCompass = YES;
}

#pragma mark -QMSSearchDelegate
- (void)searchWithReverseGeoCodeSearchOption:(QMSReverseGeoCodeSearchOption *)reverseGeoCodeSearchOption didReceiveResult:(QMSReverseGeoCodeSearchResult *)reverseGeoCodeSearchResult {
    NSLog(@"pois--->%@", reverseGeoCodeSearchResult);
}

- (void)searchWithSearchOption:(QMSSearchOption *)searchOption didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}
@end
