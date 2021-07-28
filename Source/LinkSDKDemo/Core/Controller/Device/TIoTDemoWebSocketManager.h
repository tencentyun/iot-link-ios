//
//  TIoTDemoWebSocketManager.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/7/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIoTCoreSocketManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^didReceiveMessage) (BOOL sucess, NSDictionary *data);

@interface TIoTDemoWebSocketManager : NSObject
/** 连接状态 */
@property (nonatomic,assign) WCReadyState socketReadyState;

+(instancetype)shared;
- (void)SRWebSocketOpen;//开启连接
- (void)SRWebSocketClose;//关闭连接
@end

NS_ASSUME_NONNULL_END
