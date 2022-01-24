//
//  TIOTTRTCModel.h
//  TIoTLinkKit.default-TRTC
//
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
//@property (nonatomic, strong) NSString *_sys_userid;
@property (nonatomic, strong) NSString *_sys_user_agent; //谁呼叫的
@property (nonatomic, strong) NSString *_sys_extra_info; //_sys_extra_info: "{ \ "rejectUserId \ ": \ "userb \ "}"消息，判断rejectUserId是否为自己的用户id，，如果为自己的用户id，则退出呼叫通话的流程
@property (nonatomic, strong) NSString *deviceName;//UI展示的名字
@property (nonatomic, strong) NSString *username; //用户名
@property (nonatomic, strong) NSString *_sys_caller_id; //主呼叫方id
@property (nonatomic, strong) NSString *_sys_called_id; //被呼叫方id
@end

@interface TIOTtrtcPayloadModel : NSObject
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *clientToken;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) TIOTtrtcPayloadParamModel *params;
@end

@interface TIOTtrtcRejectModel : NSObject
@property (nonatomic, strong) NSString *rejectUserId;
@end


NS_ASSUME_NONNULL_END
