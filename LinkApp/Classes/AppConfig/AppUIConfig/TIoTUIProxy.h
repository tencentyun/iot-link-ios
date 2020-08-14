//
//  XDPUIProxy.h
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/13.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 全面屏
#define kXDPiPhoneBottomSafeAreaHeight [TIoTUIProxy shareUIProxy].tabbarAddHeight

// screen
#define kScreenWidth [TIoTUIProxy shareUIProxy].screenWidth
#define kScreenHeight [TIoTUIProxy shareUIProxy].screenHeight
#define kScreenAllWidthScale [TIoTUIProxy shareUIProxy].screenAllWidthScale
#define kScreenAllHeightScale [TIoTUIProxy shareUIProxy].screenAllHeightScale

//rgb
#define kRGBAColor(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define kRGBColor(r,g,b) kRGBAColor(r,g,b,1.0f)

//navigation
#define kXDPNavigationBarIcon 30
#define kXDPNavigationBarTitleColor kRGBColor(0,0,0)
#define kXDPNavigationBarTitleFont 18
#define kXDPNavigationBackgroundColor [UIColor whiteColor]
#define kXDPNavigationLineColor kRGBColor(230,230,230)
#define kXDPNavigationBarHeight [TIoTUIProxy shareUIProxy].navigationBarHeight

//tabbar
#define kXDPTabbarTintColor kRGBColor(51,51,51)
#define kXDPTabbarNomalColor kRGBColor(51,51,51)
#define kXDPTabbarBackgroundColor [UIColor whiteColor]
#define kXDPTabbarTitleFont 8
#define kXDPTabbarHeight [TIoTUIProxy shareUIProxy].tabbarHeight
//tabbar 线颜色
#define kXDPTabbarLineColor kRGBAColor(0,0,0,0.1)

//edge
#define kHorEdge 16
#define kXDPContentRealWidth [TIoTUIProxy shareUIProxy].contentWidth

//主题色
#define kMainColor kRGBColor(0, 82, 217)
#define kMainColorDisable kRGBAColor(0, 82, 217, 0.2)
#define kWarnColor kRGBColor(229, 69, 69)
#define kWarnColorDisable kRGBAColor(229, 69, 69, 0.2)
//线颜色
#define kLineColor kRGBColor(245, 245, 245)
//字体颜色
#define kFontColor kRGBColor(51, 51, 51)
//背景颜色
#define kBgColor [UIColor whiteColor]
//背景颜色
#define kBackgroundHexColor @"#F5F5F5"
//红色
#define kSignoutHexColor @"#FF584C"

#define WeakObj(o) __weak typeof(o) o##Weak = o;
#define StrongObj(o) __strong typeof(o) o##strong = o##Weak;


typedef NS_ENUM(NSInteger,WCThemeStyle) {
    WCThemeSimple,
    WCThemeStandard,
    WCThemeDark,
};


typedef NS_ENUM(NSInteger, TIoTConfigHardwareStyle) {
    TIoTConfigHardwareStyleSmartConfig = 0,
    TIoTConfigHardwareStyleSoftAP = 1
};


NS_ASSUME_NONNULL_BEGIN

@interface TIoTUIProxy : NSObject

+ (TIoTUIProxy *)shareUIProxy;


/**
 以widht 375pt 为标准(不含p的放大)
 @return 比例
 */
@property (nonatomic , assign) CGFloat screenWidthScale;
/**
 以widht 375pt 为标准(含p的放大)
 @return 比例
 */
@property (nonatomic , assign) CGFloat screenAllWidthScale;
/**
 以height 375pt 为标准(含p的放大)
 @return 比例
 */
@property(nonatomic, assign) CGFloat screenAllHeightScale;

@property (nonatomic , assign) CGSize screenSize;
@property (nonatomic , assign) CGFloat screenWidth;
@property (nonatomic , assign) CGFloat screenHeight;

@property (nonatomic , assign) CGFloat contentWidth;

// 是否iPhoneX
@property (nonatomic , assign) BOOL iPhoneX;

// tab高度(包括全面屏)
@property (nonatomic , assign) CGFloat tabbarHeight;
// 全面屏增加的高度
@property (nonatomic , assign) CGFloat tabbarAddHeight;
// 状态栏高度（包括全面屏）
@property (nonatomic , assign) CGFloat statusHeight;
// 导航栏高度
@property (nonatomic , assign) CGFloat navigationBarHeight;

+ (UIColor *)colorWithHexColor:(NSString *)hexColor alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
