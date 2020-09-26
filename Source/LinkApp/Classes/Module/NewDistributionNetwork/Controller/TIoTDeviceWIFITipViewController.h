//
//  TIoTDeviceWIFITipViewController.h
//  LinkApp
//
//  Created by Sun on 2020/8/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDeviceWIFITipViewController : UIViewController

/// 配网类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;
/// WIFI信息(ssid name pwd)
@property (nonatomic, copy) NSDictionary *wifiInfo;
/// 绑定房间id
@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSString *currentDistributionToken;

@property (nonatomic, copy) NSDictionary *connectGuideData;
@end

NS_ASSUME_NONNULL_END
