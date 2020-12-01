//
//  TIOTTRTCModel.h
//  TIoTLinkKit.default-TRTC
//
//  Created by eagleychen on 2020/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOTTRTCModel : NSObject
@property (nonatomic, strong) NSString *SdkAppId;
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *UserSig;
@property (nonatomic, strong) NSString *StrRoomId;
@end


@interface TIOTtrtcPayloadParamModel : NSObject
@property (nonatomic, strong) NSString *_sys_video_call_status;
@property (nonatomic, strong) NSString *_sys_audio_call_status;
@property (nonatomic, strong) NSString *_sys_userid;
@end

@interface TIOTtrtcPayloadModel : NSObject
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *clientToken;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) TIOTtrtcPayloadParamModel *params;
@end
NS_ASSUME_NONNULL_END
