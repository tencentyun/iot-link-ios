//
//  WCWebSocketManage.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketRocket.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^didReceiveMessage) (BOOL sucess, NSDictionary *data);

@interface WCWebSocketManage : NSObject

/** 连接状态 */
@property (nonatomic,assign) SRReadyState socketReadyState;
//@property (nonatomic,  copy) void (^didReceiveMessage)(BOOL sucess, NSDictionary *data);

+(instancetype)shared;
- (void)SRWebSocketOpen;//开启连接
- (void)SRWebSocketClose;//关闭连接
//- (void)sendData:(NSDictionary *)paramDic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess;//发送数据


/// 监听设备状态
//- (void)registerDevicecActive;

@end

NS_ASSUME_NONNULL_END
