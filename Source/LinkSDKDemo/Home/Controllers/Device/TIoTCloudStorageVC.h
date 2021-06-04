//
//  TIoTCloudStorageVC.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTDemoBaseViewController.h"
#import "TIoTExploreOrVideoDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCloudStorageVC : TIoTDemoBaseViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *eventModel;
@end

NS_ASSUME_NONNULL_END
