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

@property (nonatomic, readonly) BOOL isActiveStatus; //YES主动  NO 被动
@property (nonatomic, readonly) BOOL isEnterError; //yes 正常进入房间，no  15s内没进入
//@property (nonatomic, assign) NSInteger audio_call_status;
//@property (nonatomic, assign) NSInteger video_call_status;

//面板中主动呼叫设备 0 audio； 1video
- (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString;

- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

- (void)preLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

//轮训设备状态，查看trtc设备是否要呼叫我
- (void)repeatDeviceData:(NSArray *)devices;
@end

NS_ASSUME_NONNULL_END
