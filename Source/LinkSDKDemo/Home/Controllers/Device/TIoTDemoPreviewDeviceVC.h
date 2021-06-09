//
//  TIoTDemoPreviewDeviceVC.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/5.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoBaseViewController.h"
#import "TIoTExploreOrVideoDeviceModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TIoTDemoPreviewDeviceVC : TIoTDemoBaseViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *selectedModel;
@end

NS_ASSUME_NONNULL_END
