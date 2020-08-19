//
//  TIoTChooseTimeZoneVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/8/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^returnTimeZoneBlock) (NSString * _Nonnull timeZone,NSString * _Nonnull cityName);

NS_ASSUME_NONNULL_BEGIN

@interface TIoTChooseTimeZoneVC : UIViewController

@property (nonatomic, copy) returnTimeZoneBlock returnTimeZoneBlock;

@end

NS_ASSUME_NONNULL_END
