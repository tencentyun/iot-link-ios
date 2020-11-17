//
//  TIoTTRTCSessionManager.h
//  TIoTLinkKit.default-TRTC
//
//  Created by eagleychen on 2020/11/19.
//

#import <Foundation/Foundation.h>
#import "TIoTCoreParts.h"
#import "TIOTTRTCModel.h"

NS_ASSUME_NONNULL_BEGIN

//0 表示设备空闲或者不愿意接听
//1 表示设备准备进入通话状态
//3 表示设备正在通话中

typedef enum : NSUInteger {
    TIoTTRTCSessionType_free,
    TIoTTRTCSessionType_pre,
    TIoTTRTCSessionType_calling,
    TIoTTRTCSessionType_end
} TIoTTRTCSessionType;

@interface TIoTTRTCSessionManager : NSObject
@property (nonatomic, readonly) TIoTTRTCSessionType state; //呼叫状态； 1 呼叫中

+ (instancetype)sharedManager ;
- (void)callDevice:(NSString *)DeviceId deviceName:(NSString *)DeviceName productId:(NSString *)ProductId success:(SRHandler)success failure:(FRHandler)failure ;
- (void)preEnterRoom:(NSString *)DeviceId deviceName:(NSString *)DeviceName failure:(FRHandler)failure;
- (void)leaveRoomRoom:(NSString *)DeviceId deviceName:(NSString *)DeviceName productId:(NSString *)ProductId trtcParams:(TIOTTRTCModel *)trtcParams success:(SRHandler)success failure:(FRHandler)failure;
@end

NS_ASSUME_NONNULL_END
