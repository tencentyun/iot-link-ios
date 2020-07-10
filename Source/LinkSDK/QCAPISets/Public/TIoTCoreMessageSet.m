//
//  QCMessagePart.m
//  QCAccount
//
//  Created by Wp on 2020/3/2.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "TIoTCoreMessageSet.h"
#import "TIoTCoreRequestAction.h"
#import "TIoTCoreFoundation.h"
//#import <QCFoundation/TIoTCoreFoundation.h>

@implementation TIoTCoreMessageSet

+ (instancetype)shared
{
    static TIoTCoreMessageSet *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


- (void)getMessagesWithMsgId:(NSString *)msgId msgTimestamp:(SInt64)msgTimestamp limit:(NSUInteger)limit category:(NSUInteger)category success:(SRHandler)success failure:(FRHandler)failure
{
    if (msgId == nil) {
        failure(@"msgId参数为空",nil);
        return;
    }
    
    
    NSDictionary *param = @{@"MsgID":msgId,@"MsgTimestamp":@(msgTimestamp),@"Limit":@(limit),@"Category":@(category)};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppGetMessages params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

/// 删除消息
- (void)deleteMessageByMsgId:(NSString *)msgId success:(SRHandler)success failure:(FRHandler)failure
{
    if (msgId == nil) {
        failure(@"msgId参数为空",nil);
        return;
    }
    
    NSDictionary *param = @{@"MsgID":msgId};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppDeleteMessage params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)bindXgToken:(NSString *)token success:(SRHandler)success failure:(FRHandler)failure
{
    if (token == nil) {
        failure(@"token参数为空",nil);
        return;
    }
    
    NSDictionary *param = @{@"Token":token,@"Platform":@"ios"};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppBindXgToken params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)unbindXgToken:(NSString *)token success:(SRHandler)success failure:(FRHandler)failure
{
    if (token == nil) {
        failure(@"token参数为空",nil);
        return;
    }
    
    NSDictionary *param = @{@"Token":token,@"Platform":@"ios"};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppUnBindXgToken params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}
@end
