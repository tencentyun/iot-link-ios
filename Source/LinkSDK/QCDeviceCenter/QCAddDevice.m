//
//  QCAddDevice.m
//  QCDeviceCenter
//
//  Created by Wp on 2019/12/5.
//  Copyright © 2019 Reo. All rights reserved.
//

#import "QCAddDevice.h"

#import "WCMacros.h"
#import "NSObject+so.h"

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
#import "getgateway.h"


#define SmartConfigPort 8266

@interface QCSmartConfig()<TCSocketDelegate>
@property (atomic, strong) ESPTouchTask *esptouchTask;
@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) TCSocket *socket;

@property (nonatomic) BOOL connecting;

@end

@implementation QCSmartConfig

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
                        [self createConnect:ipAddrDataStr];

                        if (count >= maxDisplayCount)
                        {
                            break;
                        }
                    }
                }
                else
                {
                    //没发现设备
                    if ([self.delegate respondsToSelector:@selector(onResult:)]) {
                        self.connecting = NO;
                        QCResult *result = [QCResult new];
                        result.code = 5000;
                        result.errMsg = @"未发现设备";
                        [self.delegate onResult:result];
                    }
                }
            }

        });
    });
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
    NSLog(@"result is: %@",esptouchResults);
    return esptouchResults;
}


- (void)createConnect:(NSString *)ip{
    self.socket = [[TCSocket alloc] init];
    [self.socket setDeleagte:self];
    [self.socket openWithIP:ip port:SmartConfigPort];
}


#pragma mark - TCSocketDelegate

- (void)onHandleSocketOpen:(TCSocket *)socket {
//    NSLog(@"%@ did open",socket);
    [socket sendData: [NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"timestamp":@((long)[[NSDate date] timeIntervalSince1970])} options:NSJSONWritingPrettyPrinted error:nil]];
}

- (void)onHandleSocketClosed:(TCSocket *)socket {
//    NSLog(@"%@ did close",socket);
}

- (void)onHandleDataReceived:(TCSocket *)socket data:(NSData *)data {
//    NSLog(@"%@ did receive data %@",socket,data);
    //TCIotDevice *result;
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (JSONParsingError != nil) {
            //失败
            if ([self.delegate respondsToSelector:@selector(onResult:)]) {
                self.connecting = NO;
                QCResult *result = [QCResult new];
                result.code = 5001;
                result.errMsg = @"解析失败";
                [self.delegate onResult:result];
            }
        } else {
            //成功
            if ([self.delegate respondsToSelector:@selector(onResult:)]) {
                self.connecting = NO;
                QCResult *result = [QCResult new];
                result.code = 0;
                result.signatureInfo = [NSObject base64Encode:dictionary];
                [self.delegate onResult:result];
            }
        }
    });
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

@interface QCSoftAP()<GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *socket;
@property (strong, nonatomic) dispatch_queue_t delegateQueue;

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic) NSUInteger sendCount;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic) NSUInteger sendCount2;


@property (nonatomic) BOOL connecting;

@end

@implementation QCSoftAP

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
    NSString *gateway = [self getGateway];
    [self createudpConnect:gateway];
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

//创建udp连接
- (void)createudpConnect:(NSString *)ip{
    
    WCLog(@"softap==start");
    
    self.delegateQueue = dispatch_queue_create("qc.com", DISPATCH_QUEUE_CONCURRENT);
    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    
    NSError *error = nil;
    
    if (![self.socket bindToPort:55551 error:&error]) {     // 端口绑定
        WCLog(@"bindToPort: %@", error);
        //连接失败
        self.connecting = NO;
        if ([self.delegate respondsToSelector:@selector(onResult:)]) {
            QCResult *result = [QCResult new];
            result.code = 6003;
            result.errMsg = @"udp连接失败";
            [self.delegate onResult:result];
        }
        return ;
    }
    if (![self.socket beginReceiving:&error]) {     // 开始监听
        WCLog(@"beginReceiving: %@", error);
        //连接失败
        self.connecting = NO;
        if ([self.delegate respondsToSelector:@selector(onResult:)]) {
            QCResult *result = [QCResult new];
            result.code = 6003;
            result.errMsg = @"udp连接失败";
            [self.delegate onResult:result];
        }
        return ;
    }
    
    // 服务端
    if (![self.socket connectToHost:ip onPort:8266 error:&error]) {   // 连接服务器
        WCLog(@"连接失败：%@", error);
        //连接失败
        self.connecting = NO;
        if ([self.delegate respondsToSelector:@selector(onResult:)]) {
            QCResult *result = [QCResult new];
            result.code = 6003;
            result.errMsg = @"udp连接失败";
            [self.delegate onResult:result];
        }
        return ;
    }
}

- (NSString *)getGateway
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    WCLog(@"本机地址：%@",address);
                    
                    //routerIP----192.168.1.255 广播地址
                    WCLog(@"广播地址：%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                    
                    //--255.255.255.0 子网掩码地址
                    WCLog(@"子网掩码地址：%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                    
                    //--en0 接口
                    //  en0       Ethernet II    protocal interface
                    //  et0       802.3             protocal interface
                    //  ent0      Hardware device interface
                    WCLog(@"接口名：%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    in_addr_t i = inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    in_addr_t* x = &i;
    unsigned char *s = getdefaultgateway(x);
    NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
    free(s);
    return ip;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    WCLog(@"连接成功");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        
        if (self.sendCount >= 3) {
            dispatch_source_cancel(self.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
               //连接失败,模组有问题
                self.connecting = NO;
                if ([self.delegate respondsToSelector:@selector(onResult:)]) {
                    QCResult *result = [QCResult new];
                    result.code = 6000;
                    result.errMsg = @"模组有问题";
                    [self.delegate onResult:result];
                }
            });
            return ;
        }
        
        [sock sendData:[NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(1),@"ssid":self.ssid,@"password":self.password} options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
        self.sendCount ++;
    });
    dispatch_resume(self.timer);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    WCLog(@"发送成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    WCLog(@"发送失败 %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];
    
    
    if ([dictionary[@"cmdType"] integerValue] == 2) {
        //模组已经收到WiFi路由器的SSID/PSW，正在进行连接。这个时候app/小程序需要等待3秒钟，然后发送时间戳信息给模组
        if (![NSObject isEmptyWithObject:dictionary[@"deviceReply"]]) {
            if ([dictionary[@"deviceReply"] isEqualToString:@"dataRecived"]) {
                
                dispatch_source_cancel(self.timer);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    self.timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
                    dispatch_source_set_timer(self.timer2, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
                    dispatch_source_set_event_handler(self.timer2, ^{
                        
                        if (self.sendCount2 >= 3) {
                            dispatch_source_cancel(self.timer2);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //连接失败,发送时间戳失败
                                self.connecting = NO;
                                if ([self.delegate respondsToSelector:@selector(onResult:)]) {
                                    QCResult *result = [QCResult new];
                                    result.code = 6001;
                                    result.errMsg = @"模组有问题";
                                    [self.delegate onResult:result];
                                }
                            });
                            return ;
                        }
                        
                        [sock sendData:[NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"timestamp":@((long)[[NSDate date] timeIntervalSince1970])} options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
                        
                        self.sendCount2 ++;
                    });
                    dispatch_resume(self.timer2);
                    
                });
            }
            return;
        }
        
        
        if (![NSObject isEmptyWithObject:dictionary[@"signature"]] && [@"connected" isEqualToString:dictionary[@"wifiState"]]) {
            
            dispatch_source_cancel(self.timer2);
            
            self.connecting = NO;
            if ([self.delegate respondsToSelector:@selector(onResult:)]) {
                QCResult *result = [QCResult new];
                result.code = 0;
                result.signatureInfo = [NSObject base64Encode:dictionary];
                [self.delegate onResult:result];
            }
        }
        else
        {
            //连接失败,模组回复信息缺失或wifiState不为connected
            self.connecting = NO;
            if ([self.delegate respondsToSelector:@selector(onResult:)]) {
                QCResult *result = [QCResult new];
                result.code = 6002;
                result.errMsg = @"模组有问题";
                [self.delegate onResult:result];
            }
        }
        
    }
}



@end

