//
//  TIoTBaseMapViewController.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <QMapKit/QMapKit.h>
//#import <QMapKit/QMSSearchKit.h>

@protocol TIoTBaseMapViewControllerDelegate <NSObject>

/// 用户选择授权后代理
- (void)agreeLocationAuthorized;

/// 在seting里授权后，返回进入前台后代理
- (void)enterforegoundAuthorized;
@end

@interface TIoTBaseMapViewController : UIViewController //<QMapViewDelegate>

//@property (nonatomic, strong, readonly) QMapView *mapView;

@property (nonatomic, weak) id<TIoTBaseMapViewControllerDelegate>delegate;

#pragma mark - Override

- (void)handleTestAction;

- (NSString *)testTitle;

@end
