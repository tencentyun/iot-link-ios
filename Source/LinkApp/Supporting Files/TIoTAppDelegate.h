//
//  TIoTAppDelegate.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>
@import TrueTime;

@interface TIoTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) TrueTimeClient *timeClient;
@property (nonatomic, assign) BOOL isDebug;
@end

