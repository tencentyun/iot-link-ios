//
//  TIoTDemoVideoCallVC.h
//  LinkSDKDemo
//
//  Created by eagleychen on 2023/4/7.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTExploreOrVideoDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDemoVideoCallVC : UIViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *selectedModel;   //选择设备的model
@property (nonatomic, assign) BOOL isNVR; //区分是NVR、IPC
@property (nonatomic, strong) NSString *deviceNameNVR;
@end

NS_ASSUME_NONNULL_END
