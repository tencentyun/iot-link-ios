//
//  TIoTAppDelegate.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/16.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>
@import TrueTime;

@interface TIoTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) TrueTimeClient *timeClient;
@property (nonatomic, assign) BOOL isDebug;
@end

