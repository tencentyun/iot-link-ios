//
//  TIoTResponseJSModel.h
//  LinkApp
//
//  Created by ccharlesren on 2020/10/28.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIotResponseJSShareParamsModel;

@interface TIoTResponseJSModel : NSObject
@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, assign) NSInteger isShareDevice;
@property (nonatomic, assign) NSInteger reload;
@property (nonatomic, copy) NSString *shareParams;   //调试中 显示的是json字符串 设备分享有用到

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;   //用户分享有用到
@property (nonatomic, copy) NSString *imgUrl;  //用户分享有用到
@end

@interface TIotResponseJSShareParamsModel : NSObject


@end

NS_ASSUME_NONNULL_END
