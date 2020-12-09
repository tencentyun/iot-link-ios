//
//  QCMacros.h
//  QCAccount
//
//  Created by Wp on 2019/12/5.
//  Copyright © 2019 Reo. All rights reserved.
//

#ifndef QCMacros_h
#define QCMacros_h


#define kRGBAColor(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define kRGBColor(r,g,b) kRGBAColor(r,g,b,1.0f)

#define kMainColor kRGBColor(0, 110, 255)
#define kBgColor kRGBColor(242, 242, 242)
#define kFontColor kRGBColor(51, 51, 51)


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define Is_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Is_iphoneX kScreenWidth >=375.0f && kScreenHeight >=812.0f && Is_iphone

/*状态栏高度*/
#define kStatusBarHeight (CGFloat)(Is_iphoneX?(44.0):(20.0))
/*导航栏高度*/
#define kNavBarHeight (44)
/*状态栏和导航栏总高度*/
#define kNavBarAndStatusBarHeight (CGFloat)(Is_iphoneX?(88.0):(64.0))
/*TabBar高度*/
#define kTabBarHeight (CGFloat)(Is_iphoneX?(49.0 + 34.0):(49.0))
/*顶部安全区域远离高度*/
#define kTopBarSafeHeight (CGFloat)(Is_iphoneX?(44.0):(0))
/*底部安全区域远离高度*/
#define kBottomSafeHeight (CGFloat)(Is_iphoneX?(34.0):(0))

#import "UIFont+TIoTFont.h"
#import "TIoTCoreWMacros.h"

#endif /* QCMacros_h */
