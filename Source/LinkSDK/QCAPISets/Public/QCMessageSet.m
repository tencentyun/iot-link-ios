//
//  QCMessagePart.m
//  QCAccount
//
//  Created by Wp on 2020/3/2.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "QCMessageSet.h"
#import "WCRequestAction.h"
#import <QCFoundation/QCFoundation.h>

@implementation QCMessageSet

+ (instancetype)shared
{
    static QCMessageSet *_instance = nil;
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
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetMessages params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
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
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppDeleteMessage params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
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
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppBindXgToken params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
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
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppUnBindXgToken params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}
@end
