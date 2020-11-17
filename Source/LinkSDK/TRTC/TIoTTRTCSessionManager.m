//
//  TIoTTRTCSessionManager.m
//  TIoTLinkKit.default-TRTC
//
//  Created by eagleychen on 2020/11/19.
//

#import "TIoTTRTCSessionManager.h"
#import "NSObject+additions.h"
#import "TIoTCoreFoundation.h"
#import "TIoTCoreSocketCover.h"
#import "TIoTCoreRequestAction.h"
#import "YYModel.h"
#import "TRTCCloud.h"

@implementation TIoTTRTCSessionManager

+ (instancetype)sharedManager {
    static TIoTTRTCSessionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}


- (void)callDevice:(NSString *)DeviceId deviceName:(NSString *)DeviceName productId:(NSString *)ProductId success:(SRHandler)success failure:(FRHandler)failure {
    _state = TIoTTRTCSessionType_free;
    
    if (DeviceId == nil || DeviceName == nil || ProductId == nil) {
        failure(@"DeviceId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"DeviceId":DeviceId,@"DeviceName":DeviceName,@"ProductId":ProductId};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppIotRTCInviteDevice params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)preEnterRoom:(NSString *)DeviceId deviceName:(NSString *)DeviceName failure:(FRHandler)failure {
    _state = TIoTTRTCSessionType_pre;
    
    if (DeviceId == nil || DeviceName == nil) {
        failure(@"DeviceId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"DeviceId":DeviceId,@"DeviceName":DeviceName};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppIotRTCCallDevice params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
//        success(responseObject);
        NSDictionary *tempDic = responseObject[@"TRTCParams"];
        TIOTTRTCModel *model = [TIOTTRTCModel yy_modelWithJSON:tempDic];
        [self enterRoom:model];
        
        self->_state = TIoTTRTCSessionType_calling;
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)leaveRoomRoom:(NSString *)DeviceId deviceName:(NSString *)DeviceName productId:(NSString *)ProductId trtcParams:(TIOTTRTCModel *)trtcParams success:(SRHandler)success failure:(FRHandler)failure {
    _state = TIoTTRTCSessionType_end;
    
    if (DeviceId == nil || DeviceName == nil) {
        failure(@"DeviceId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"DeviceId":DeviceId,@"DeviceName":DeviceName,@"ProductId":ProductId, @"TRTCParams": @{
                                    @"SdkAppId": trtcParams.SdkAppId,
                                    @"UserId": trtcParams.UserId,
                                    @"UserSig": trtcParams.UserSig,
                                    @"RoomId": trtcParams.RoomId}
                            };
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppIotRTCLeavelRoom params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}


//MARK ########TRTCCloud
- (void)enterRoom:(TIOTTRTCModel *)model {
    TRTCCloud * cloud;// = [[TRTCCloud alloc] ini]
//    [TRTCCloud sharedInstance];
//    [TRTCCloud sharedInstance].delegate = self;
}

@end
