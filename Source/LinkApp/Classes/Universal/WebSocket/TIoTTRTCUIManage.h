//
//  TIoTWebSocketManage+TRTC.h
//  LinkApp
//
//  Created by eagleychen on 2020/11/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIoTTRTCSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTRTCUIManage: NSObject <TIoTTRTCSessionUIDelegate>
+ (instancetype)sharedManager ;

- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

//轮训设备状态，查看trtc设备是否要呼叫我
- (void)repeatDeviceData:(NSArray *)devices;
@end

NS_ASSUME_NONNULL_END
