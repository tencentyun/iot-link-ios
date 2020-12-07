//
//  TIoTModifyDeviceNameVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/12/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ModifyDeviceNameBlcok)(NSString *name);

@interface TIoTModifyDeviceNameVC : UIViewController
@property (nonatomic, strong)NSString * titleText;
@property (nonatomic, strong)NSString * defaultText;
@property (nonatomic, strong) NSMutableDictionary *deviceDic;
@property (nonatomic, copy) ModifyDeviceNameBlcok modifyDeviceNameBlcok;
@end

NS_ASSUME_NONNULL_END
