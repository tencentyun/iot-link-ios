//
//  TRTCCall+Signal.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/3.
//

#import "TRTCCalling+Signal.h"
#import "TRTCCallingUtils.h"
#import "TRTCCallingHeader.h"

@implementation TRTCCalling (Signal)

- (void)addSignalListener {
}

- (void)removeSignalListener {
}

- (NSString *)invite:(NSString *)receiver action:(CallAction)action model:(CallModel *)model {
    NSString *callID = @"";
    if (receiver.length <= 0) {
        return callID;
    }
    CallModel *realModel = [self generateModel:action];
    BOOL isGroup = [self.curGroupID isEqualToString:receiver];
    if (model) {
        realModel = [model copy];
        realModel.action = action;
        if (model.groupid.length > 0) {
            isGroup = YES;
        }
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(Version),SIGNALING_EXTRA_KEY_VERSION,@(realModel.calltype), SIGNALING_EXTRA_KEY_CALL_TYPE,nil];
    switch (realModel.action) {
    case CallAction_Call:
        {
            param[SIGNALING_EXTRA_KEY_ROOM_ID] = @(realModel.roomid);
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:param];
            if (isGroup) {
                @weakify(self)
                self.callID = callID;
            } else {
                @weakify(self)
                self.callID = callID;
            }
        }
            break;
        
    case CallAction_Accept:
        {
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:param];
        }
            break;
        
    case CallAction_Reject:
        {
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:param];
        }
            break;
        
    case CallAction_Linebusy:
        {
            param[SIGNALING_EXTRA_KEY_LINE_BUSY] = SIGNALING_EXTRA_KEY_LINE_BUSY;
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:param];
        }
            break;
        
    case CallAction_Cancel:
        {
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:param];
        }
            break;
        
    case CallAction_End:
        {
            if (isGroup) {
                param[SIGNALING_EXTRA_KEY_CALL_END] = @(0);  // 群通话不需要计算通话时长
                NSString *data = [TRTCCallingUtils dictionary2JsonStr:param];
                // 这里发结束事件的时候，inviteeList 已经为 nil 了，可以伪造一个被邀请用户，把结束的信令发到群里展示。
                // timeout 这里传 0，结束的事件不需要做超时检测
                
            } else {
                if (self.startCallTS > 0) {
                    NSDate *now = [NSDate date];
                    param[SIGNALING_EXTRA_KEY_CALL_END] = @((UInt64)[now timeIntervalSince1970] - self.startCallTS);
                    NSString *data = [TRTCCallingUtils dictionary2JsonStr:param];
                
                }
                self.startCallTS = 0;
            }
        }
            break;
    
    default:
            break;
    }
    if (realModel.action != CallAction_Reject &&
        realModel.action != CallAction_Accept &&
        realModel.action != CallAction_End &&
        realModel.action != CallAction_Cancel &&
        model == nil) {
        self.curLastModel = [realModel copy];
    }
    return callID;
}

- (void)sendAPNsForCall:(NSString *)receiver inviteeList:(NSArray *)inviteeList callID:(NSString *)callID groupid:(NSString *)groupid roomid:(UInt32)roomid {
    if (callID.length == 0 || inviteeList.count == 0 || roomid == 0) {
        NSLog(@"sendAPNsForCall failed");
        return;
    }
    int chatType; //单聊：1 群聊：2
    if (groupid.length > 0) {
        chatType = 2;
    } else {
        chatType = 1;
        groupid = @"";
    }
    //{"entity":{"version":1,"content":"{\"action\":1,\"call_type\":2,\"room_id\":804544637,\"call_id\":\"144115224095613335-1595234230-3304653590\",\"timeout\":30,\"version\":4,\"invited_list\":[\"2019\"],\"group_id\":\"@TGS#1PWYXLTGA\"}","sendTime":1595234231,"sender":"10457","chatType":2,"action":2}}
    NSDictionary *contentParam = @{@"action":@(1),//SignalingActionType_Invite),
                                   @"call_id":callID,
                                   @"call_type":@(self.curType),
                                   @"invited_list":inviteeList,
                                   @"room_id":@(roomid),
                                   @"group_id":groupid,
                                   @"timeout":@(SIGNALING_EXTRA_KEY_TIME_OUT),
                                   @"version":@(Version)};             // TUIkit 业务版本
    NSDictionary *entityParam = @{@"action" : @(APNs_Business_Call),   // 音视频业务逻辑推送
                                  @"chatType" : @(chatType),
                                  @"content" : [TRTCCallingUtils dictionary2JsonStr:contentParam],
                                  @"sendTime" : @((UInt32)[[NSDate date] timeIntervalSince1970]),
                                  @"sender" : [TRTCCallingUtils loginUser],
                                  @"version" : @(APNs_Version)};       // 推送版本
    NSDictionary *extParam = @{@"entity" : entityParam};
}

- (void)onReceiveGroupCallAPNs {
}

#pragma mark V2TIMSignalingListener

-(void)onReceiveNewInvitation:(NSString *)inviteID inviter:(NSString *)inviter groupID:(NSString *)groupID inviteeList:(NSArray<NSString *> *)inviteeList data:(NSString *)data {
    NSDictionary *param = [self check:data];
    
    if (param) {
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        model.groupid = groupID;
        model.inviter = inviter;
        model.invitedList = [NSMutableArray arrayWithArray:inviteeList];
        model.calltype = (CallType)[param[SIGNALING_EXTRA_KEY_CALL_TYPE] intValue];
        model.roomid = [param[SIGNALING_EXTRA_KEY_ROOM_ID] intValue];
        model.action = CallAction_Call;
        [self handleCallModel:inviter model:model];
    }
}

-(void)onInvitationCancelled:(NSString *)inviteID inviter:(NSString *)inviter data:(NSString *)data {
    NSDictionary *param = [self check:data];
    if (param) {
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        model.action = CallAction_Cancel;
        [self handleCallModel:inviter model:model];
    }
}

-(void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    [TRTCCloud sharedInstance].delegate = self;
    NSDictionary *param = [self check:data];
    if (param) {
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        model.action = CallAction_Accept;
        [self handleCallModel:invitee model:model];
    }
}

-(void)onInviteeRejected:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    NSDictionary *param = [self check:data];
    if (param) {
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        model.action = CallAction_Reject;
        if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
            model.action = CallAction_Linebusy;
        }
        [self handleCallModel:invitee model:model];
    }
}

-(void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)invitedList {
    CallModel *model = [[CallModel alloc] init];
    model.callid = inviteID;
    model.invitedList = [NSMutableArray arrayWithArray:invitedList];
    model.action = CallAction_Timeout;
    [self handleCallModel:@"" model:model];
}

- (NSDictionary *)check:(NSString *)data {
    NSDictionary *param = [TRTCCallingUtils jsonSring2Dictionary:data];
    if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_CALL_END]) {
        //结束的事件只用于 UI 展示通话时长，不参与业务逻辑的处理
        return nil;
    }
    if (![param.allKeys containsObject:SIGNALING_EXTRA_KEY_CALL_TYPE]) {
        return nil;
    }
    NSInteger version = [param[SIGNALING_EXTRA_KEY_VERSION] integerValue];
    if (version > Version) {
        return nil;
    }
    return param;
}

- (void)handleCallModel:(NSString *)user model:(CallModel *)model {
    switch (model.action) {
    case CallAction_Call:
        {
            void(^syncInvitingList)(void) = ^(){
                if (self.curGroupID.length > 0) {
                    for (NSString *invitee in model.invitedList) {
                        if (![self.curInvitingList containsObject:invitee]) {
                            [self.curInvitingList addObject:invitee];
                        }
                    }
                }
            };
            if (model.groupid != nil && ![model.invitedList containsObject:[TRTCCallingUtils loginUser]]
                ) { //群聊但是邀请不包含自己不处理
                if (self.curCallID == model.callid) { //在房间中更新列表
                    syncInvitingList();
                    if (self.curInvitingList.count > 0) {
                        if ([self canDelegateRespondMethod:@selector(onGroupCallInviteeListUpdate:)]) {
                            [self.delegate onGroupCallInviteeListUpdate:self.curInvitingList];
                        }
                    }
                }
                return;
            }
            if (self.isOnCalling) { // tell busy
                if (![model.callid isEqualToString:self.curCallID]) {
                    [self invite:model.groupid.length > 0 ? model.groupid : user action:CallAction_Linebusy model:model];
                }
            } else {
                self.isOnCalling = true;
                self.curCallID = model.callid;
                self.curRoomID = model.roomid;
                if (model.groupid.length > 0) {
                    self.curGroupID = model.groupid;
                }
                self.curType = model.calltype;
                self.curSponsorForMe = user;
                syncInvitingList();
                if ([self canDelegateRespondMethod:@selector(onInvited:userIds:isFromGroup:callType:)]) {
                    [self.delegate onInvited:user userIds:model.invitedList isFromGroup:self.curGroupID.length > 0 ? YES : NO callType:model.calltype];
                }
            }
            
        }
            break;
        
    case CallAction_Cancel:
        {
            if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
                self.isOnCalling = NO;
                [self.delegate onCallingCancel:user];
            }
        }
            break;
        
    case CallAction_Reject:
        {
            if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
                if ([self.curInvitingList containsObject:user]) {
                    [self.curInvitingList removeObject:user];
                }
                if ([self canDelegateRespondMethod:@selector(onReject:)]) {
                    [self.delegate onReject:user];
                }
                [self checkAutoHangUp];
            }
        }
            break;
        
    case CallAction_Timeout:
        if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
            // 这里需要判断下是否是自己超时了，自己超时，直接退出界面
            if ([model.invitedList containsObject:[TRTCCallingUtils loginUser]] && self.delegate) {
                self.isOnCalling = false;
                if ([self canDelegateRespondMethod:@selector(onCallingTimeOut)]) {
                     [self.delegate onCallingTimeOut];
                }
            } else {
                for (NSString *userID in model.invitedList) {
                    if ([self.curInvitingList containsObject:userID] && ![self.curRespList containsObject:userID]) {
                        if ([self canDelegateRespondMethod:@selector(onNoResp:)]) {
                            [self.delegate onNoResp:userID];
                        }
                        if ([self.curInvitingList containsObject:userID]) {
                            [self.curInvitingList removeObject:userID];
                        }
                    }
                }
            }
            [self checkAutoHangUp];
        }
            break;
        
    case CallAction_End:
        // 不需处理
            break;
        
    case CallAction_Linebusy:
        {
            if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
                if ([self.curInvitingList containsObject:user]) {
                    [self.curInvitingList removeObject:user];
                }
                [self.delegate onLineBusy:user];
                [self checkAutoHangUp];
            }
        }
            break;
        
    case CallAction_Error:
        if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
            if ([self.curInvitingList containsObject:user]) {
                [self.curInvitingList removeObject:user];
            }
            [self.delegate onError:-1 msg:@"系统错误"];
            [self checkAutoHangUp];
        }
            break;

    default:
        {
             NSLog(@"📳 👻 WTF ????");
        }
            break;
    }
}

#pragma mark utils
- (CallModel *)generateModel:(CallAction)action {
    CallModel *model = [self.curLastModel copy];
    model.action = action;
    return model;
}

//检查是否能自动挂断
- (void)checkAutoHangUp {
    if (self.isInRoom && self.curRoomList.count == 0) {
        if (self.curGroupID.length > 0) {
            if (self.curInvitingList.count == 0) {
                [self invite:self.curGroupID action:CallAction_End model:nil];
                [self autoHangUp];
            }
        } else {
            NSString *user = @"";
            if (self.curSponsorForMe.length > 0) {
                user = self.curSponsorForMe;
            } else {
                user = self.curLastModel.invitedList.firstObject;
            }
            [self invite:user action:CallAction_End model:nil];
            [self autoHangUp];
        }
    }
}

//自动挂断
- (void)autoHangUp {
    [self quitRoom];
    self.isOnCalling = NO;
    if ([self canDelegateRespondMethod:@selector(onCallEnd)]) {
        [self.delegate onCallEnd];
    }
}

#pragma mark - private method
- (BOOL)canDelegateRespondMethod:(SEL)selector {
    return self.delegate && [self.delegate respondsToSelector:selector];
}

@end
