//
//  TIoTConfigScanVC.h
//  TIoTLinkKit
//
//  Created by ccharlesren on 2020/12/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTProductWelComeConfigModel.h"

/**
 配置扫码产品展示页面（扫一扫落地页）
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTConfigScanVC : UIViewController
@property (nonatomic, copy) TIoTProductWelComeConfigModel *productWelConfigModel; //落地页model
@property (nonatomic, copy) NSString *productID; //产品id
@property (nonatomic, strong) NSDictionary *welConfigDic;
@property (nonatomic, copy) NSString *roomId;
@end

NS_ASSUME_NONNULL_END
