//
//  QCAddDevice.m
//  QCDeviceCenter
//
//  Created by Wp on 2019/12/5.
//  Copyright © 2019 Reo. All rights reserved.
//

#import "TIoTCoreAddDevice.h"

#import "TIoTCoreWMacros.h"

//smartconfig
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "TCSocket.h"

//softap
#import "GCDAsyncUdpSocket.h"
//获取网关
#import <arpa/inet.h>
#import <ifaddrs.h>

#import "NSObject+additions.h"
#import "NSString+Extension.h"

#define SmartConfigPort 8266

@interface TIoTCoreSmartConfig()<TCSocketDelegate>
@property (atomic, strong) ESPTouchTask *esptouchTask;
@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) TCSocket *socket;

@property (nonatomic) BOOL connecting;

@end

@implementation TIoTCoreSmartConfig

- (BOOL)isConnecting
{
    return self.connecting;
}

- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password BSSID:(NSString *)bssid
{
    self = [super init];
    if (self) {
        _ssid = ssid;
        _password = password;
        _bssid = bssid;
    }
    return self;
}


- (void)startAddDevice {
    _connecting = YES;
    [self tapConfirmForResults];
}

- (void)stopAddDevice {
    _connecting = NO;
    [self.condition lock];
    if (self.esptouchTask != nil)
    {
        [self.esptouchTask interrupt];
    }
    [self.condition unlock];
    
    if (self.socket) {
        [self.socket close];
        self.socket = nil;
    }
}


#pragma mark - private

- (void)tapConfirmForResults{
    
    NSString *apSsid = self.ssid;
    NSString *apPwd = self.password;
    NSString *apBssid = self.bssid;
    
    
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // execute the task
        NSArray *esptouchResultArray = [self executeForResultsWithSsid:apSsid bssid:apBssid password:apPwd taskCount:1 broadcast:YES];
        // show the result to the user in UI Main Thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
            // check whether the task is cancelled and no results received
            if (!firstResult.isCancelled)
            {
                NSMutableString *mutableStr = [[NSMutableString alloc]init];
                NSUInteger count = 0;
                // max results to be displayed, if it is more than maxDisplayCount,
                // just show the count of redundant ones
                const int maxDisplayCount = 5;
                if ([firstResult isSuc])
                {
                    
                    for (int i = 0; i < [esptouchResultArray count]; ++i)
                    {
                        ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                        [mutableStr appendString:[resultInArray description]];
                        [mutableStr appendString:@"\n"];
                        count++;
                        NSString *ipAddrDataStr = [ESP_NetUtil descriptionInetAddr4ByData:resultInArray.ipAddrData];
                        if (ipAddrDataStr==nil) {
                            ipAddrDataStr = [ESP_NetUtil descriptionInetAddr6ByData:resultInArray.ipAddrData];
                        }
                        
                        if (self.updConnectBlock == nil) {
                            [self createConnect:ipAddrDataStr];
                        }else {
                            self.updConnectBlock(ipAddrDataStr);
                        }
                        
                        if (count >= maxDisplayCount)
                        {
                            break;
                        }
                    }
                    
                    if (count < [esptouchResultArray count])
                    {
                        [mutableStr appendString:[NSString stringWithFormat:@"\nthere's %lu more result(s) without showing\n",(unsigned long)([esptouchResultArray count] - count)]];
                    }
                }
                else
                {
                    if (self.connectFaildBlock == nil) {
                        [self foundNoDeviced];
                    }else {
                        self.connectFaildBlock();
                    }
                    
                }
            }
            
        });
    });
}

- (void)foundNoDeviced  {
    //没发现设备
    if ([self.delegate respondsToSelector:@selector(onResult:)]) {
        self.connecting = NO;
        TIoTCoreResult *result = [TIoTCoreResult new];
        result.code = 5000;
        result.errMsg = @"未发现设备";
        [self.delegate onResult:result];
    }
}

- (NSArray *) executeForResultsWithSsid:(NSString *)apSsid bssid:(NSString *)apBssid password:(NSString *)apPwd taskCount:(int)taskCount broadcast:(BOOL)broadcast
{
    [self.condition lock];
    self.esptouchTask = [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd andTimeoutMillisecond:30000];
    
    // set delegate
    //[self.esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self.esptouchTask setPackageBroadcast:broadcast];
    [self.condition unlock];
    NSArray * esptouchResults = [self.esptouchTask executeForResults:taskCount];
    QCLog(@"result is: %@",esptouchResults);
    return esptouchResults;
}


- (void)createConnect:(NSString *)ip{
    self.socket = [[TCSocket alloc] init];
    [self.socket setDeleagte:self];
    [self.socket openWithIP:ip port:SmartConfigPort];
}


#pragma mark - TCSocketDelegate

- (void)onHandleSocketOpen:(TCSocket *)socket {
    QCLog(@"%@ did open",socket);
    
    if ([self.delegate respondsToSelector:@selector(smartConfigOnHandleSocketOpen:)]) {
        [self.delegate smartConfigOnHandleSocketOpen:socket];
    }
}

- (void)onHandleSocketClosed:(TCSocket *)socket {
    QCLog(@"%@ did close",socket);
    
    if ([self.delegate respondsToSelector:@selector(smartConfigOnHandleSocketClosed:)]) {
        [self.delegate smartConfigOnHandleSocketClosed:socket];
    }
}

- (void)onHandleDataReceived:(TCSocket *)socket data:(NSData *)data {
    QCLog(@"%@ did receive data %@",socket,data);

    if ([self.delegate respondsToSelector:@selector(smartConfigOnHandleDataReceived:data:)]) {
        [self.delegate smartConfigOnHandleDataReceived:socket data:data];
    }
}

#pragma mark - getter

- (NSCondition *)condition
{
    if (!_condition) {
        _condition = [[NSCondition alloc] init];
    }
    return _condition;
}

@end


/*=======================================================================*/

@interface TIoTCoreSoftAP()<GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *socket;
@property (strong, nonatomic) dispatch_queue_t delegateQueue;

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic) NSUInteger sendCount;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic) NSUInteger sendCount2;


@property (nonatomic) BOOL connecting;

@end

@implementation TIoTCoreSoftAP

- (BOOL)isConnecting
{
    return self.connecting;
}

- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password
{
    self = [super init];
    if (self) {
        _ssid = ssid;
        _password = password;
    }
    return self;
}

- (void)startAddDevice {
    self.connecting = YES;
    [self getGatewayIp];
}

- (void)stopAddDevice {
    self.connecting = NO;
    if (self.timer != nil) {
        dispatch_source_cancel(self.timer);
    }
    if (self.timer2 != nil) {
        dispatch_source_cancel(self.timer2);
    }
    
    [self.socket close];
    self.socket = nil;
}


#pragma mark --------
- (void)getGatewayIp {
    
    NSString *ipString = nil;
 
    if (self.udpFaildBlock == nil) {
        ipString = [NSString getGateway];
        [self createudpConnect:ipString];
    }else {
        ipString = self.gatewayIpString;
        [self creatUdpWithIp:ipString connectFaildBlock:^{
            self.udpFaildBlock();
        }];
    }
}

//创建udp连接
- (void)createudpConnect:(NSString *)ip{
    
    QCLog(@"softap==start");

    [self creatUdpWithIp:ip connectFaildBlock:^{
       [self connectUdpFaild];
    }];
}

- (void)creatUdpWithIp:(NSString *)ip connectFaildBlock:(connectUdpFaildBlock)connectFialdBlock {

    self.delegateQueue = dispatch_queue_create("socketSoftAp.comDDD", DISPATCH_QUEUE_CONCURRENT);
    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    
    NSError *error = nil;
    
    if (![self.socket bindToPort:55551 error:&error]) {     // 端口绑定
        QCLog(@"bindToPort: %@", error);
        connectFialdBlock();
        return ;
    }
    if (![self.socket beginReceiving:&error]) {     // 开始监听
        QCLog(@"beginReceiving: %@", error);
        connectFialdBlock();
        return ;
    }
    
    // 服务端
    if (![self.socket connectToHost:ip onPort:8266 error:&error]) {   // 连接服务器
        QCLog(@"连接失败：%@", error);
        connectFialdBlock();
        return ;
    }
}

- (void)connectUdpFaild {
    //连接失败
    self.connecting = NO;
    if ([self.delegate respondsToSelector:@selector(onResult:)]) {
        TIoTCoreResult *result = [TIoTCoreResult new];
        result.code = 6003;
        result.errMsg = [NSString stringWithFormat:@"udp%@",NSLocalizedString(@"connect_fail", @"连接失败")];
        [self.delegate onResult:result];
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    QCLog(@"连接成功");
    
    if ([self.delegate respondsToSelector:@selector(softApUdpSocket:didConnectToAddress:)]) {
        [self.delegate softApUdpSocket:sock didConnectToAddress:address];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    QCLog(@"发送成功");
    if ([self.delegate respondsToSelector:@selector(softApUdpSocket:didSendDataWithTag:)]) {
        [self.delegate softApUdpSocket:sock didSendDataWithTag:tag];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    QCLog(@"发送失败 %@", error);
    if ([self.delegate respondsToSelector:@selector(softApuUdpSocket:didNotSendDataWithTag:dueToError:)]) {
        [self.delegate softApuUdpSocket:sock didNotSendDataWithTag:tag dueToError:error];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    if ([self.delegate respondsToSelector:@selector(softApUdpSocket:didReceiveData:fromAddress:withFilterContext:)]) {
        [self.delegate softApUdpSocket:sock didReceiveData:data fromAddress:address withFilterContext:filterContext];
    }
   
}

@end

