//
//  TIoTChooseRegionVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/8/18.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^returnRegionBlock) (NSString * _Nonnull Title,NSString * _Nonnull region,NSString * _Nonnull RegionID);

NS_ASSUME_NONNULL_BEGIN

@interface TIoTChooseRegionVC : UIViewController

@property (nonatomic, copy) returnRegionBlock returnRegionBlock;

@end

NS_ASSUME_NONNULL_END
