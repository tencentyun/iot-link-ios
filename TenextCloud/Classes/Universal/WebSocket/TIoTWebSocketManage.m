//
//  WCWebSocketManage.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCWebSocketManage.h"
#import "WCAppEnvironment.h"
#import "UIViewController+GetController.h"
#import "WCNavigationController.h"
#import "WCLoginVC.h"
#import "WCRequestObj.h"
#import "ReachabilityManager.h"


#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define WeakSelf(type)  __weak typeof(type) weak##type = type;

static NSString *registDeviceReqID = @"5001";
static NSString *heartBeatReqID = @"5002";

@interface WCWebSocketManage ()<SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSTimer *heartBeat;
@property (nonatomic, assign) NSTimeInterval reConnectTime;

@property (nonatomic, strong) NSMutableDictionary *reqArray;


@end

@implementation WCWebSocketManage

+(instancetype)shared{
    static WCWebSocketManage *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self registerNetworkNotifications];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerNetworkNotifications{
    
    [[NetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(NetworkReachabilityStatus status) {
        switch (status) {
            case NetworkReachabilityStatusUnknown:
                NSLog(@"状态不知道");
                break;
            case NetworkReachabilityStatusNotReachable:
                NSLog(@"没网络");
                break;
            case NetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                [self SRWebSocketOpen];
                break;
            case NetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"移动网络");
                [self SRWebSocketOpen];
                break;
            default:
                break;
        }
    }];
    
    [[NetworkReachabilityManager sharedManager] startMonitoring];
    
}

/// 订阅
- (void)registerDevicecActive:(NSNotification *)noti {
    
    NSArray *deviceIds = noti.object;
    
    [[WCWebSocketManage shared] sendActiveData:deviceIds withRequestURL:@"ActivePush" complete:^(BOOL sucess, NSDictionary * _Nonnull data) {
        if (sucess) {

        }
    }];
}

-(void)SRWebSocketOpen{
    
    if(self.socket.readyState == SR_OPEN){
        return;
    }
    
    [self SRWebSocketClose];
    WCLog(@"请求的websocket地址：%@",self.socket.url.absoluteString);
    [self.socket open];
}

-(void)SRWebSocketClose{
    if (self.socket){
        [self.socket close];
        self.socket = nil;
        //断开连接时销毁心跳
        [self destoryHeartBeat];
    }
}

#pragma mark - socket delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
    //每次正常连接的时候清零重连等待时间
    self.reConnectTime = 0;
    
    if (webSocket == self.socket) {
        WCLog(@"************************** socket 连接成功************************** ");
        [HXYNotice addHeartBeatListener:self reaction:@selector(initHeartBeat:)];
        [HXYNotice addActivePushListener:self reaction:@selector(registerDevicecActive:)];
        
        [HXYNotice addSocketConnectSucessPost];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {

    if (webSocket == self.socket) {
        WCLog(@"************************** socket 连接失败************************** ");
        //连接失败就重连
        [self reConnect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    if (webSocket == self.socket) {
        WCLog(@"************************** socket连接断开************************** ");
        [self SRWebSocketClose];
    }

}

/*该函数是接收服务器发送的pong消息，其中最后一个是接受pong消息的，
 在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，
 用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，
 我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的
 */

-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
//    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
//    WCLog(@"reply===%@",reply);
}

#pragma mark - 收到的回调
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message  {
    
    if (webSocket == self.socket) {
        if(!message){
            return;
        }
        [self handleReceivedMessage:message];

    }
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

//监听到的设备上报信息
- (void)deviceInfo:(NSDictionary *)deviceInfo{
    [HXYNotice addReportDevicePost:deviceInfo];
}

- (void)handleReceivedMessage:(id)message{
    NSDictionary *dic = [NSString jsonToObject:message];
    WCLog(@"message:%@",dic);
    NSString *reqId = [NSString stringWithFormat:@"%@",dic[@"reqId"]];
    if ([NSObject isNullOrNilWithObject:dic[@"reqId"]])
    {
        if ([dic[@"action"] isEqualToString:@"DeviceChange"]) {
            [self deviceInfo:dic[@"params"]];
            return;
        }
    }
    
    if ([heartBeatReqID isEqualToString:reqId]) {//心跳回包
        return;
    }
    
    if ([registDeviceReqID isEqualToString:reqId]) {//
        [self deviceReceivedData:dic];
        return;
    }
    
    
    
    BOOL sucess = YES;
    NSDictionary *result = nil;
    
    if (![NSObject isNullOrNilWithObject:dic[@"data"]]) {
        if (dic[@"data"][@"Response"][@"Error"]) {
            [MBProgressHUD showError:dic[@"data"][@"Response"][@"Error"][@"Message"]];
            sucess = NO;
            result = dic[@"data"][@"Response"][@"Error"];
        }
        if ([dic[@"data"][@"result"] isEqualToString:@"hello world"]) {
            return;
        }
    }
    else{
        [MBProgressHUD showError:dic[@"error_message"]];
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

//重连
- (void)reConnect
{
    //超过5次后不再重连,等待重连时间分别为 0，2，4，8，16
    if (self.reConnectTime > 16) {
        //您的网络状况不是很好，请检查网络后重试
        return;
    }
   
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self SRWebSocketOpen];
        WCLog(@"重连");
    });
    
    //重连时间2的指数级增长
    if (self.reConnectTime == 0) {
        self.reConnectTime = 2;
    }else{
        self.reConnectTime *= 2;
    }
    
}

//初始化心跳
- (void)initHeartBeat:(NSNotification *)noti
{
    NSArray *deviceIds = noti.object;
    
    dispatch_main_async_safe(^{
        [self destoryHeartBeat];
       
        self.heartBeat = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(ping:) userInfo:deviceIds repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.heartBeat forMode:NSRunLoopCommonModes];
        [self.heartBeat fire];
    })
}


//取消心跳
- (void)destoryHeartBeat
{
    dispatch_main_async_safe(^{
        if (self.heartBeat) {
            if ([self.heartBeat respondsToSelector:@selector(isValid)]){
                if ([self.heartBeat isValid]){
                    [self.heartBeat invalidate];
                    self.heartBeat = nil;
                }
            }
        }
    })
}

//ping
- (void)ping:(NSTimer *)timer {
    NSArray *deviceIds = timer.userInfo;
    if (self.socket.readyState == SR_OPEN) {
        NSData *data= [NSJSONSerialization dataWithJSONObject:[self heartData:deviceIds] options:NSJSONWritingPrettyPrinted error:nil];
        [self.socket send:data];
    }
}


//心跳数据
- (NSDictionary *)heartData:(NSArray *)deviceIds {
    return @{
        @"action":[WCAppEnvironment shareEnvironment].action,
        @"reqId":[[NSUUID UUID] UUIDString],
        @"params":@{
            @"Action": @"AppDeviceTraceHeartBeat",
            @"AccessToken":[WCUserManage shared].accessToken,
            @"RequestId":@"weichuan-client",
            @"ActionParams": @{
                @"DeviceIds": deviceIds
            }
        }
    };
}

//判断是否重新登录
- (BOOL)needLogin{
    if ([[WCUserManage shared].expireAt integerValue] <= [[NSString getNowTimeString] integerValue] && [WCUserManage shared].accessToken.length > 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"登录已过期" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"重新登录" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
            [[WCAppEnvironment shareEnvironment] loginOut];
            
            WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:[[WCLoginVC alloc] init]];
            [UIViewController getCurrentViewController].view.window.rootViewController = nav;
        }];
        [alert addAction:alertA];
        [[UIViewController getCurrentViewController] presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    return NO;
}

//设备监听
- (void)sendActiveData:(NSArray *)deviceIds withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess{
    //每次请求需要判断登录是否失效
    if ([self needLogin]) {
        return;
    }
    
    
    NSDictionary *dataDic = @{
                                @"action":requestURL,
                                @"reqId":registDeviceReqID,
                                @"params":@{
                                                @"DeviceIds" :deviceIds,
                                                @"AccessToken" :[WCUserManage shared].accessToken,
                                            },
                                    };
    
    WCRequestObj *obj = [WCRequestObj new];
    obj.sucess = sucess;
    [self.reqArray setObject:obj forKey:registDeviceReqID];
    
    WCLog(@"socketSendData--------------- %@",dataDic);
    [self sendData:dataDic complete:sucess];
}

- (void)sendData:(NSDictionary *)paramDic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess{
    //每次请求需要判断登录是否失效
    if ([self needLogin]) {
        return;
    }
    
    NSMutableDictionary *actionParams = [NSMutableDictionary dictionaryWithDictionary:paramDic];
    [actionParams setObject:[WCAppEnvironment shareEnvironment].platform forKey:@"Platform"];
    [actionParams setObject:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    if ([WCUserManage shared].accessToken.length > 0) {
        [actionParams setObject:[WCUserManage shared].accessToken forKey:@"AccessToken"];
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
                                @"action":[WCAppEnvironment shareEnvironment].action,
                                @"reqId":@(reqID),
                                @"params":@{
                                                @"AppKey" :[WCAppEnvironment shareEnvironment].appKey,
                                                @"Action" :requestURL,
                                                @"ActionParams":actionParams
                                    },
                                
                                };
    
    
    WCLog(@"socketSendData--dataDic --------------- %@",dataDic);
    [self sendData:dataDic complete:sucess];
    
}

- (void)sendData:(NSDictionary *)dataDic complete:(didReceiveMessage)sucess{
    
    NSError *error;
    NSString *data;
    //(NSJSONWritingOptions) (paramDic ? NSJSONWritingPrettyPrinted : 0)
    //采用这个格式的json数据会比较好看，但是不是服务器需要的
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDic
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        WCLog(@" error: %@", error.localizedDescription);
        return;
    } else {
        data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //这是为了取代requestURI里的"\"
//        data = [data stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    }
    WeakSelf(self);
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakself.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakself.socket.readyState == SR_OPEN) {
                [weakself.socket send:data];    // 发送数据
                
            } else if (weakself.socket.readyState == SR_CONNECTING) {

                [weakself reConnect];
                
            } else if (weakself.socket.readyState == SR_CLOSING || weakself.socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                WCLog(@"重连");
                
                [weakself reConnect];
            }
        } else {
            // 这里要看你的具体业务需求；不过一般情况下，调用发送数据还是希望能把数据发送出去，所以可以再次打开链接；不用担心这里会有多个socketopen；因为如果当前有socket存在，会停止创建哒
            [weakself SRWebSocketOpen];
        }
    });
}

-(SRReadyState)socketReadyState{
    return self.socket.readyState;
}

#pragma mark - getter

- (NSMutableDictionary *)reqArray
{
    if (!_reqArray) {
        _reqArray = [NSMutableDictionary dictionary];
    }
    return _reqArray;
}

- (SRWebSocket *)socket
{
    if (!_socket) {
        _socket = [[SRWebSocket alloc] initWithURLRequest:
        [NSURLRequest requestWithURL:[NSURL URLWithString:[WCAppEnvironment shareEnvironment].wsUrl]]];
        _socket.delegate = self;
    }
    return _socket;
}
@end
