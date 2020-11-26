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

@protocol TIoTTRTCSessionUIDelegate <NSObject>
//呼起被叫页面，如果当前正在主叫页面，则外界UI不处理
- (BOOL)isActiveCalling:(NSString *)deviceUserID;
@end

@interface TIoTTRTCSessionManager : NSObject
@property (nonatomic, readonly) TIoTTRTCSessionType state; //呼叫状态； 1 呼叫中
@property (nonatomic, weak) id<TIoTTRTCSessionUIDelegate> uidelegate;

+ (instancetype)sharedManager ;
- (void)callDevice:(NSString *)DeviceId deviceName:(NSString *)DeviceName productId:(NSString *)ProductId success:(SRHandler)success failure:(FRHandler)failure ;
- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure;
- (void)configRoom:(TIOTTRTCModel *)model ;
- (void)enterRoom;
@end

NS_ASSUME_NONNULL_END
