//
//  WC 配网 WCDistributionNetworkViewController.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/15.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTWIFINetViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDistributionNetworkViewController : UIViewController

@property (nonatomic, assign) EquipmentType equipmentType;
@property (nonatomic, copy) NSString *roomId;

@end

NS_ASSUME_NONNULL_END
