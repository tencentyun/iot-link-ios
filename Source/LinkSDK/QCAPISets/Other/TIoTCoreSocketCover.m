//
//  WCWebSocketManage.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTCoreSocketCover.h"
#import "TIoTCoreRequestObj.h"
#import "NSObject+additions.h"

#import <QCFoundation/TIoTCoreFoundation.h>


#define QQCLog(fmt, ...) if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pLogEnable"] boolValue]) {NSLog((@"\n--------------\n" fmt @"\n================================="), ##__VA_ARGS__);}

static NSString *registDeviceReqID = @"5001";

@interface TIoTCoreSocketCover ()<QCSocketManagerDelegate>

@property (nonatomic, assign) NSTimeInterval reConnectTime;


@property (nonatomic, strong) NSMutableDictionary *reqArray;

@end

@implementation TIoTCoreSocketCover

+ (instancetype)shared{
    static TIoTCoreSocketCover *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [TIoTCoreSocketManager shared].delegate = self;
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
    if (![TIoTCoreUserManage shared].isValidToken) {
        return;
    }
    
    NSDictionary *dataDic = @{
                                @"action":@"ActivePush",
                                @"reqId":registDeviceReqID,
                                @"params":@{
                                                @"AccessToken" :[TIoTCoreUserManage shared].accessToken ?: @"",
                                                @"DeviceIds" :deviceIds
                                            },
                                    };
    
    TIoTCoreRequestObj *obj = [TIoTCoreRequestObj new];
    obj.sucess = success;
    [self.reqArray setObject:obj forKey:registDeviceReqID];
    
    QQCLog(@"send======%@",dataDic);
    [[TIoTCoreSocketManager shared] sendData:dataDic];
}

- (void)sendData:(NSDictionary *)paramDic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess{
    //每次请求需要判断登录是否失效
    if (![TIoTCoreUserManage shared].isValidToken) {
        return;
    }
    
    NSMutableDictionary *actionParams = [NSMutableDictionary dictionaryWithDictionary:paramDic];
    [actionParams setObject:@"iOS" forKey:@"Platform"];
    [actionParams setObject:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    if ([TIoTCoreUserManage shared].accessToken.length > 0) {
        [actionParams setObject:[TIoTCoreUserManage shared].accessToken forKey:@"AccessToken"];
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
        TIoTCoreRequestObj *obj = [TIoTCoreRequestObj new];
        obj.sucess = sucess;
        [self.reqArray setObject:obj forKey:[NSString stringWithFormat:@"%zi",reqID]];
    }
    
    NSDictionary *dataDic = @{
                                @"action":@"YunApi",
                                @"reqId":@(reqID),
                                @"params":@{
                                                @"AppKey" :[TIoTCoreServices shared].appKey,
                                                @"Action" :requestURL,
                                                @"ActionParams":actionParams
                                    },
                                
                                };
    
    
    QQCLog(@"send======%@",dataDic);
    [[TIoTCoreSocketManager shared] sendData:dataDic];
    
}


#pragma mark - socket delegate

- (void)socket:(TIoTCoreSocketManager *)manager didReceiveMessage:(id)message
{
    if(!message){
        return;
    }
    [self handleReceivedMessage:message];
}
- (void)socketDidOpen:(TIoTCoreSocketManager *)manager
{
    
}
- (void)socket:(TIoTCoreSocketManager *)manager didFailWithError:(NSError *)error
{
    
}
- (void)socket:(TIoTCoreSocketManager *)manager didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
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
    TIoTCoreRequestObj *reqObj = self.reqArray[reqID];
    
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
    TIoTCoreRequestObj *reqObj = self.reqArray[reqIDStr];
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
