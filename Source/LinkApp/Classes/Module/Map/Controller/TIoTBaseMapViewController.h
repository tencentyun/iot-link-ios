//
//  TIoTBaseMapViewController.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QMapKit/QMapKit.h>
#import <QMapKit/QMSSearchKit.h>

@interface TIoTBaseMapViewController : UIViewController <QMapViewDelegate>

@property (nonatomic, strong, readonly) QMapView *mapView;

#pragma mark - Override

- (void)handleTestAction;

- (NSString *)testTitle;

@end
