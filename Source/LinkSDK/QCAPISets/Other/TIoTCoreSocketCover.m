//
//  WCWebSocketManage.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "QCSocketCover.h"
#import "WCRequestObj.h"
#import "NSObject+additions.h"

#import <QCFoundation/QCFoundation.h>


#define QQCLog(fmt, ...) if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pLogEnable"] boolValue]) {NSLog((@"\n--------------\n" fmt @"\n================================="), ##__VA_ARGS__);}

static NSString *registDeviceReqID = @"5001";

@interface QCSocketCover ()<QCSocketManagerDelegate>

@property (nonatomic, assign) NSTimeInterval reConnectTime;


@property (nonatomic, strong) NSMutableDictionary *reqArray;

@end

@implementation QCSocketCover

+ (instancetype)shared{
    static QCSocketCover *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [QCSocketManager shared].delegate = self;
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//注册设备监听
- (void)registerDeviceActive:(NSArray *)deviceIds complete:(didReceiveMessage)success
{
    //每次请求需要判断登录是否失效
    if (![QCUserManage shared].isValidToken) {
        return;
    }
    
    NSDictionary *dataDic = @{
                                @"action":@"ActivePush",
                                @"reqId":registDeviceReqID,
                                @"params":@{
                                                @"AccessToken" :[QCUserManage shared].accessToken ?: @"",
                                                @"DeviceIds" :deviceIds
                                            },
                                    };
    
    WCRequestObj *obj = [WCRequestObj new];
    obj.sucess = success;
    [self.reqArray setObject:obj forKey:registDeviceReqID];
    
    QQCLog(@"send======%@",dataDic);
    [[QCSocketManager shared] sendData:dataDic];
}

- (void)sendData:(NSDictionary *)paramDic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess{
    //每次请求需要判断登录是否失效
    if (![QCUserManage shared].isValidToken) {
        return;
    }
    
    NSMutableDictionary *actionParams = [NSMutableDictionary dictionaryWithDictionary:paramDic];
    [actionParams setObject:@"iOS" forKey:@"Platform"];
    [actionParams setObject:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    if ([QCUserManage shared].accessToken.length > 0) {
        [actionParams setObject:[QCUserManage shared].accessToken forKey:@"AccessToken"];
    }
    
    NSInteger reqID = 100;
    @synchronized (self.reqArray) {
        if (self.reqArray.count > 0) {
            NSArray *arr = [self.reqArray.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1 compare:obj2];
            }];
            NSInteger lastReqId = [arr.lastObject integerValue];
            reqID = lastReqId + 10;
        }
        WCRequestObj *obj = [WCRequestObj new];
        obj.sucess = sucess;
        [self.reqArray setObject:obj forKey:[NSString stringWithFormat:@"%zi",reqID]];
    }
    
    NSDictionary *dataDic = @{
                                @"action":@"YunApi",
                                @"reqId":@(reqID),
                                @"params":@{
                                                @"AppKey" :[QCServices shared].appKey,
                                                @"Action" :requestURL,
                                                @"ActionParams":actionParams
                                    },
                                
                                };
    
    
    QQCLog(@"send======%@",dataDic);
    [[QCSocketManager shared] sendData:dataDic];
    
}


#pragma mark - socket delegate

- (void)socket:(QCSocketManager *)manager didReceiveMessage:(id)message
{
    if(!message){
        return;
    }
    [self handleReceivedMessage:message];
}
- (void)socketDidOpen:(QCSocketManager *)manager
{
    
}
- (void)socket:(QCSocketManager *)manager didFailWithError:(NSError *)error
{
    
}
- (void)socket:(QCSocketManager *)manager didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    
}


- (void)deviceReceivedData:(NSDictionary *)data{
    BOOL sucess = YES;
    if (![NSObject isNullOrNilWithObject:data[@"data"]]) {
        sucess = YES;
    }
    else{
        sucess = NO;
    }
    
    NSString *reqID = [NSString stringWithFormat:@"%@",data[@"reqId"]];
    WCRequestObj *reqObj = self.reqArray[reqID];
    
    if (reqObj.sucess) {
        reqObj.sucess(sucess, data[@"data"]);
        [self.reqArray removeObjectForKey:reqID];
    }
}


- (void)handleReceivedMessage:(id)message{
    
    NSDictionary *dic = [NSString jsonToObject:message];
    
    NSString *reqId = [NSString stringWithFormat:@"%@",dic[@"reqId"]];
    
    if ([NSObject isNullOrNilWithObject:dic[@"reqId"]])
    {
        
        if ([dic[@"action"] isEqualToString:@"DeviceChange"]) {
            
            if (self.deviceChange) {
                
                self.deviceChange(dic[@"params"]);
            }
            return;
        }
    }
    
    
    if ([registDeviceReqID isEqualToString:reqId]) {//
        [self deviceReceivedData:dic];
        return;
    }
    
    
    
    BOOL sucess = YES;
    NSDictionary *result = nil;
    if (![NSObject isNullOrNilWithObject:dic[@"data"]]) {
        if (dic[@"data"][@"Response"][@"Error"]) {
            
            sucess = NO;
            result = dic[@"data"][@"Response"][@"Error"];
        }
        if ([dic[@"data"][@"result"] isEqualToString:@"hello world"]) {
            return;
        }
    }
    else{
        sucess = NO;
        result = dic;
    }
    
    
    NSString *reqIDStr = [NSString stringWithFormat:@"%@",reqId];
    WCRequestObj *reqObj = self.reqArray[reqIDStr];
    if(reqObj.sucess){
        if (sucess) {
            if ([NSObject isNullOrNilWithObject:dic[@"data"][@"Response"][@"Data"]]) {
                
                reqObj.sucess(sucess,sucess ? dic[@"data"][@"Response"] : [NSDictionary dictionary]);
            }
            else{
                reqObj.sucess(sucess,sucess ? dic[@"data"][@"Response"][@"Data"] : [NSDictionary dictionary]);
            }
        }
        else{
            reqObj.sucess(sucess, result);
        }
        [self.reqArray removeObjectForKey:reqIDStr];
    }
    
}



#pragma mark - getter

- (NSMutableDictionary *)reqArray
{
    if (!_reqArray) {
        _reqArray = [NSMutableDictionary dictionary];
    }
    return _reqArray;
}

@end
