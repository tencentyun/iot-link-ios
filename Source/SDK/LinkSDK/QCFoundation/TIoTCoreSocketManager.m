//
//  WCWebSocketManage.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTCoreSocketManager.h"
#import "TIoTCoreWebSocket.h"
#import "NSString+Extension.h"
#import "TIoTCoreAppEnvironment.h"

#import "TIoTCoreQMacros.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define WeakSelf(type)  __weak typeof(type) weak##type = type;



static NSString *heartBeatReqID = @"5002";

@interface TIoTCoreSocketManager ()<QCWebSocketDelegate>

@property (nonatomic, strong) TIoTCoreWebSocket *socket;
@property (nonatomic, strong) NSTimer *heartBeat;
@property (nonatomic, assign) NSTimeInterval reConnectTime;


@end

@implementation TIoTCoreSocketManager

+(instancetype)shared{
    static TIoTCoreSocketManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)socketOpen{
    
    if(self.socket.readyState == QC_OPEN){
        return;
    }
    
    [self socketClose];
    QCLog(@"请求的websocket地址：%@",self.socket.url.absoluteString);
    [self.socket open];
}

-(void)socketClose{
    if (self.socket){
        [self.socket close];
        self.socket = nil;
        //断开连接时销毁心跳
        [self stopHeartBeat];
    }
}

- (void)startHeartBeat:(NSNotification *)noti
{
    NSDictionary *params = noti.object;
    
    dispatch_main_async_safe(^{
        [self stopHeartBeat];
        
        [self startHeartBeatWith:params];
    })
}

- (void)stopHeartBeat
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

- (void)startHeartBeatWith:(id)userInfo {
    
    self.heartBeat = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(heartBeatAction:) userInfo:userInfo repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.heartBeat forMode:NSRunLoopCommonModes];
    [self.heartBeat fire];
}

//ping
- (void)heartBeatAction:(NSTimer *)timer {
//    NSDictionary *params = timer.userInfo;
    NSDictionary *params = @{@"action": @"Hello", @"reqId": heartBeatReqID}; //心跳包格式
    
    if ([TIoTCoreSocketManager shared].socketReadyState == WC_OPEN) {
        [[TIoTCoreSocketManager shared] sendData:params];
    }
}



#pragma mark - socket delegate

- (void)webSocketDidOpen:(TIoTCoreWebSocket *)webSocket {
    
    //每次正常连接的时候清零重连时间
    self.reConnectTime = 0;
    
    if (webSocket == self.socket) {
        
        QCLog(@"************************** socket 连接成功************************** ");
        if ([self.delegate respondsToSelector:@selector(socketDidOpen:)]) {
            [self.delegate socketDidOpen:self];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:socketDidOpenNotification object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startHeartBeat:) name:@"heartBeatStart" object:nil];
        }
    }
}

- (void)webSocket:(TIoTCoreWebSocket *)webSocket didFailWithError:(NSError *)error {

    if (webSocket == self.socket) {
        QCLog(@"************************** socket 连接失败************************** ");
        //连接失败就重连
        [self reConnect];
        
        if ([self.delegate respondsToSelector:@selector(socket:didFailWithError:)]) {
            [self.delegate socket:self didFailWithError:error];
        }
    }
}

- (void)webSocket:(TIoTCoreWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    if (webSocket == self.socket) {
        QCLog(@"************************** socket连接断开************************** ");
        QCLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",(long)code,reason,wasClean);
        [self socketClose];
        if ([self.delegate respondsToSelector:@selector(socket:didCloseWithCode:reason:wasClean:)]) {
            [self.delegate socket:self didCloseWithCode:code reason:reason wasClean:wasClean];
        }
    }

}

/*该函数是接收服务器发送的pong消息，其中最后一个是接受pong消息的，
在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，
用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，
我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的
*/

-(void)webSocket:(TIoTCoreWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
//    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
//    QCLog(@"reply===%@",reply);
}

#pragma mark - 收到的回调
- (void)webSocket:(TIoTCoreWebSocket *)webSocket didReceiveMessage:(id)message  {
    
    if (webSocket == self.socket) {
        if(!message){
            return;
        }
        [self handleReceivedMessage:message];

    }
}


- (void)handleReceivedMessage:(id)message{
    NSDictionary *dic = [NSString jsonToObject:message];
    QCLog(@"message:%@",dic);
    NSString *reqId = [NSString stringWithFormat:@"%@",dic[@"reqId"]];
    if ([heartBeatReqID isEqualToString:reqId]) {//心跳回包
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(socket:didReceiveMessage:)]) {
        [self.delegate socket:self didReceiveMessage:message];
    }
}

#pragma mark - private

//- (void)goForeground {
//
//    if (self.socket.readyState == QC_CLOSING || self.socket.readyState == QC_CLOSED) {
//        // websocket 断开了，调用 reConnect 方法重连
//        [self reConnect];
//    }
//}

//重连
- (void)reConnect
{
    [self socketClose];
    //超过5次后不再重连,等待重连时间分别为 0，2，4，8，16
    //超过一分钟就不再重连 所以只会重连5次
    if (self.reConnectTime > 16) {
        //您的网络状况不是很好，请检查网络后重试
        return;
    }
   
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self socketOpen];
        QCLog(@"重连");
    });
    
    //重连时间2的指数级增长
    if (self.reConnectTime == 0) {
        self.reConnectTime = 2;
    }else{
        self.reConnectTime *= 2;
    }
    
}


- (void)sendData:(NSDictionary *)obj {
    
    NSError *error;
    NSString *data;
    //(NSJSONWritingOptions) (paramDic ? NSJSONWritingPrettyPrinted : 0)
    //采用这个格式的json数据会比较好看，但是不是服务器需要的
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        QCLog(@" error: %@", error.localizedDescription);
        return;
    } else {
        data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //这是为了取代requestURI里的"\"
        //data = [data stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    }
    WeakSelf(self);
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakself.socket != nil) {
            // 只有 QC_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakself.socket.readyState == QC_OPEN) {
                [weakself.socket send:data];    // 发送数据
                
            } else if (weakself.socket.readyState == QC_CONNECTING) {

                [weakself reConnect];
                
            } else if (weakself.socket.readyState == QC_CLOSING || weakself.socket.readyState == QC_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                QCLog(@"重连");
                
                [weakself reConnect];
            }
        } else {
            // 这里要看你的具体业务需求；不过一般情况下，调用发送数据还是希望能把数据发送出去，所以可以再次打开链接；不用担心这里会有多个socketopen；因为如果当前有socket存在，会停止创建哒
            [weakself socketOpen];
        }
    });
}



#pragma mark - getter


- (TIoTCoreWebSocket *)socket
{
    if (!_socket) {
        NSString *urlStr = self.socketedRequestURL ? self.socketedRequestURL: [TIoTCoreAppEnvironment shareEnvironment].wsUrl;
        _socket = [[TIoTCoreWebSocket alloc] initWithURLRequest:
                   [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
        _socket.delegate = self;
    }
    return _socket;
}

- (WCReadyState)socketReadyState{
    switch (self.socket.readyState) {
        case QC_OPEN:
            return WC_OPEN;
            break;
        case QC_CONNECTING:
            return WC_CONNECTING;
            break;
        case QC_CLOSING:
            return WC_CLOSING;
            break;
        case QC_CLOSED:
            return WC_CLOSED;
            break;
        default:
            break;
    }
}
@end
