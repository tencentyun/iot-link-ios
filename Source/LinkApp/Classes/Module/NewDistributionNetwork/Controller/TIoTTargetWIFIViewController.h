//
//  TIoTTargetWIFIViewController.h
//  LinkApp
//
//  Created by Sun on 2020/7/29.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTargetWIFIViewController : UIViewController

/// 配网类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;

@property (nonatomic, assign) NSInteger step;
/// WIFI信息(ssid name pwd)
@property (nonatomic, copy) NSDictionary *softApWifiInfo;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *currentDistributionToken;
@property (nonatomic, copy) NSDictionary *configConnentData;
- (void)showWiFiListView;

@end

NS_ASSUME_NONNULL_END
