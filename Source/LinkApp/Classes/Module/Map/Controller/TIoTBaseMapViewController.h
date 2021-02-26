//
//  TIoTBaseMapViewController.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QMapKit/QMapKit.h>

@interface TIoTBaseMapViewController : UIViewController <QMapViewDelegate>

@property (nonatomic, strong) QMapView *mapView;

#pragma mark - Override

- (void)handleTestAction;

- (NSString *)testTitle;

- (void)setupMapView;

@end
