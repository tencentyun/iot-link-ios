//
//  TIoTLLSyncDeviceController.h
//  LinkApp
//
//  Created by eagleychen on 2021/7/19.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTLLSyncDeviceController : UIViewController
/// 配网类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;
/// WIFI信息(ssid name pwd)
@property (nonatomic, copy) NSDictionary *wifiInfo;
/// 绑定房间id
@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSString *currentDistributionToken;

@property (nonatomic, copy) NSDictionary *connectGuideData;

@property (nonatomic, copy) NSDictionary *configdata; //所有数据

@end

NS_ASSUME_NONNULL_END
