//
//  TIoTStartConfigViewController.h
//  LinkApp
//
//  Created by Sun on 2020/7/30.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTStartConfigViewController : UIViewController

/// 配网类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;
/// WIFI信息(ssid name pwd)
@property (nonatomic, copy) NSDictionary *wifiInfo;
/// 绑定房间id
@property (nonatomic, copy) NSString *roomId;

@end

NS_ASSUME_NONNULL_END
