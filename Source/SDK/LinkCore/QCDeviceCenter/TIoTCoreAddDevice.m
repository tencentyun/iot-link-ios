//
//  QCAddDevice.m
//  QCDeviceCenter
//
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

#import "TIoTCoreUserManage.h"
//#import "TIoTCoreSoftAP.h"

#define SmartConfigPort 8266

@interface TIoTCoreSmartConfig()<TCSocketDelegate,TIoTCoreAddDeviceDelegate>
@property (atomic, strong) ESPTouchTask *esptouchTask;
@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) TCSocket *socket;
@property (nonatomic, strong) TIoTCoreSoftAP *softAP;
@property (nonatomic, assign) TIoTConfigHardwareType distributionNet;
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

- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password BSSID:(NSString *)bssid Token:(NSString *)token
{
    self = [super init];
    if (self) {
        _ssid = ssid;
        _password = password;
        _bssid = bssid;
        _token = token;
        self.distributionNet = TIoTConfigHardwareTypeSmartConfig;
    }
    return self;
}


- (void)startAddDevice {
    __weak __typeof(self)weakSelf = self;
    self.updConnectBlock = ^(NSString * _Nonnull ipaAddrData) {
        [weakSelf createSoftAPWith:ipaAddrData ssid:weakSelf.ssid pwd:weakSelf.password bssid:weakSelf.bssid token:weakSelf.token];
    };
//    self.connectFaildBlock = ^{
//        [weakSelf connectFaild];
//    };
    
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
    [self.softAP stopAddDevice];
}

- (void)createSoftAPWith:(NSString *)ip ssid:(NSString *)ssid pwd:(NSString *)pwd bssid:(NSString *)bssid token:(NSString *)token {

    NSString *apSsid = ssid;
    NSString *apPwd = pwd;
    NSString *apBssid = bssid;
    NSString *apToken = token;
    
    self.softAP = [[TIoTCoreSoftAP alloc]initWithSSID:apSsid PWD:apPwd BSSID:apBssid Token:apToken distributeNet:TIoTConfigHardwareTypeSmartConfig];
    self.softAP.gatewayIpString = ip;
    self.softAP.delegate = self;
    __weak __typeof(self)weakSelf = self;
    self.softAP.udpFaildBlock = ^{
//        [weakSelf connectFaild];
        if (weakSelf.connectFaildBlock) {
            weakSelf.connectFaildBlock();
        }
    };
    [self.softAP startAddDevice];
}

#pragma mark - private

- (void)tapConfirmForResults{
    
    NSString *apSsid = self.ssid;
    NSString *apPwd = self.password;
    NSString *apBssid = self.bssid;
    
    
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // execute the task
        NSArray *esptouchResultArray = [self executeForResultsWithSsid:apSsid bssid:apBssid password:apPwd taskCount:1 broadcast:true];
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
    self.esptouchTask = [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd];
    
    // set delegate
    //[self.esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self.esptouchTask setPackageBroadcast:true];
    [self.condition unlock];
    NSArray * esptouchResults = [self.esptouchTask executeForResults:taskCount];
    DDLogInfo(@"smartConfig 发送设备报文 result is: %@",esptouchResults);
    return esptouchResults;
}


- (void)createConnect:(NSString *)ip{
    self.socket = [[TCSocket alloc] init];
    [self.socket setDeleagte:self];
    [self.socket openWithIP:ip port:SmartConfigPort];
}

#pragma mark -  Delegte
- (void)distributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
         
    if ([self.delegate respondsToSelector:@selector(distributionNetUdpSocket:didReceiveData:fromAddress:withFilterContext:)]) {
        [self.delegate distributionNetUdpSocket:sock didReceiveData:data fromAddress:address withFilterContext:filterContext];
    }else if ([self.delegate respondsToSelector:@selector(softApUdpSocket:didReceiveData:fromAddress:withFilterContext:)]) {
        [self.delegate softApUdpSocket:sock didReceiveData:data fromAddress:address withFilterContext:filterContext];
    }
    
}

#pragma mark - TCSocketDelegate

- (void)onHandleSocketOpen:(TCSocket *)socket {
    DDLogInfo(@"socket did open: %@",socket);
    if ([self.delegate respondsToSelector:@selector(smartConfigOnHandleSocketOpen:)]) {
        [self.delegate smartConfigOnHandleSocketOpen:socket];
    }
}

- (void)onHandleSocketClosed:(TCSocket *)socket {
    DDLogInfo(@"socket did close : %@",socket);
    if ([self.delegate respondsToSelector:@selector(smartConfigOnHandleSocketClosed:)]) {
        [self.delegate smartConfigOnHandleSocketClosed:socket];
    }
}

- (void)onHandleDataReceived:(TCSocket *)socket data:(NSData *)data {
    DDLogInfo(@"socket did receive data socket: %@ \n data: %@",socket,data);
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
@property (nonatomic, assign) TIoTConfigHardwareType distributionNet;

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
        self.distributionNet = TIoTConfigHardwareTypeSoftAp;
    }
    return self;
}

- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password BSSID:(NSString *)bssid Token:(nonnull NSString *)token distributeNet:(TIoTConfigHardwareType)netType {
    self = [super init];
    if (self) {
        _ssid = ssid;
        _password = password;
        _bssid = bssid;
        _token = token;
        self.distributionNet = netType;
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
    DDLogInfo(@"创建udp连接 softap start: ip: %@",ip);

    [self creatUdpWithIp:ip connectFaildBlock:^{
       [self connectUdpFaild];
    }];
}

- (void)creatUdpWithIp:(NSString *)ip connectFaildBlock:(connectUdpFaildBlock)connectFialdBlock {

    self.delegateQueue = dispatch_queue_create("socketSoftAp.comDDD", DISPATCH_QUEUE_CONCURRENT);
    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    
    NSError *error = nil;
    
    if (![self.socket bindToPort:55551 error:&error]) {     // 端口绑定
        DDLogInfo(@"端口绑定 bindToPort error : %@", error);
        connectFialdBlock();
        return ;
    }
    if (![self.socket beginReceiving:&error]) {     // 开始监听
        DDLogInfo(@"端口开始监听 beginReceiving error : %@", error);
        connectFialdBlock();
        return ;
    }
    
    // 服务端
    if (![self.socket connectToHost:ip onPort:(self.serverProt != 0?self.serverProt:8266) error:&error]) {   // 连接服务器
        DDLogInfo(@"socket 连接服务器失败 error ：%@", error);
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
    DDLogInfo(@"upd连接成功: \n sock : %@\n address: %@",sock,address);
    //设备收到WiFi的ssid/pwd/token，正在上报，此时2秒内，客户端没有收到设备回复，如果重复发送5次，都没有收到回复，则认为配网失败，Wi-Fi 设备有异常
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //定时器延迟时间
    NSTimeInterval delayTime = 2.0f;
       
    //定时器间隔时间
    NSTimeInterval timeInterval = 2.0f;
       
    //设置开始时间
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
       
    dispatch_source_set_timer(self.timer, startDelayTime, timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        
        if (self.sendCount >= 5) {
            dispatch_source_cancel(self.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.udpFaildBlock) {
                    self.udpFaildBlock();
                }
                
            });
            return ;
        }
        
        if (self.distributionNet == TIoTConfigHardwareTypeSoftAp) {
            
            NSString *Ssid = self.ssid?:@"";
            NSString *Pwd = self.password?:@"";
            NSString *Token = self.token?:@"";
            NSString *apBssid = self.bssid?:@"";
            NSDictionary *dic = @{@"cmdType":@(1),@"ssid":Ssid, @"bssid":apBssid, @"password":Pwd,@"token":Token,@"region":[TIoTCoreUserManage shared].userRegion};
            [sock sendData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
        } else {
            
            [sock sendData:[NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"token":self.token?:@"",@"region":[TIoTCoreUserManage shared].userRegion} options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
        }
        self.sendCount ++;
    });
    dispatch_resume(self.timer);
    
    if ([self.delegate respondsToSelector:@selector(distributionNetUdpSocket:didConnectToAddress:)]) {
        [self.delegate distributionNetUdpSocket:sock didConnectToAddress:address];
    }else if ([self.delegate respondsToSelector:@selector(softApUdpSocket:didConnectToAddress:)]) {
        [self.delegate softApUdpSocket:sock didConnectToAddress:address];
    }
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error {
    DDLogInfo(@"upd 连接失败: socket: %@\n 错误提示error: %@",sock,error);
    if ([self.delegate respondsToSelector:@selector(distributionNetUdpSocket:didNotConnect:)]) {
        [self.delegate distributionNetUdpSocket:sock didNotConnect:error];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    DDLogInfo(@"upd发送成功: socket: %@\n tag: %ld",sock,tag);
    if ([self.delegate respondsToSelector:@selector(distributionNetUdpSocket:didSendDataWithTag:)]) {
        [self.delegate distributionNetUdpSocket:sock didSendDataWithTag:tag];
    }else if ([self.delegate respondsToSelector:@selector(softApUdpSocket:didSendDataWithTag:)]) {
        [self.delegate softApUdpSocket:sock didSendDataWithTag:tag];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    DDLogInfo(@"upd发送失败: socket: %@\n errot: %@ \n tag: %ld", sock,error,tag);
    if ([self.delegate respondsToSelector:@selector(distributionNetUdpSocket:didNotSendDataWithTag:dueToError:)]) {
        [self.delegate distributionNetUdpSocket:sock didNotSendDataWithTag:tag dueToError:error];
    }else if ([self.delegate respondsToSelector:@selector(softApuUdpSocket:didNotSendDataWithTag:dueToError:)]) {
        [self.delegate softApuUdpSocket:sock didNotSendDataWithTag:tag dueToError:error];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    DDLogInfo(@"upd设备接收消息成功: socket: %@\n data: %@\n addrss: %@",sock,data,address);
    dispatch_source_cancel(self.timer);
    
    if (self.distributionNet == TIoTConfigHardwareTypeSoftAp) {
        if ([self.delegate respondsToSelector:@selector(distributionNetUdpSocket:didReceiveData:fromAddress:withFilterContext:)]) {
            [self.delegate distributionNetUdpSocket:sock didReceiveData:data fromAddress:address withFilterContext:filterContext];
        }else if ([self.delegate respondsToSelector:@selector(softApUdpSocket:didReceiveData:fromAddress:withFilterContext:)]) {
            [self.delegate softApUdpSocket:sock didReceiveData:data fromAddress:address withFilterContext:filterContext];
        }
    }else {
        
        if ([self.delegate respondsToSelector:@selector(distributionNetUdpSocket:didReceiveData:fromAddress:withFilterContext:)]) {
            [self.delegate distributionNetUdpSocket:sock didReceiveData:data fromAddress:address withFilterContext:filterContext];
        }
    }
   
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error {
    DDLogInfo(@"Upd 关闭: socket: %@\n error: %@",sock,error);
    if ([self.delegate respondsToSelector:@selector(distributionNetudpSocket:withError:)]) {
        [self.delegate distributionNetudpSocket:sock withError:error];
    }
}

@end


/*=======================================================================*/

@interface TIoTCoreWired()<GCDAsyncUdpSocketDelegate>
@property (nonatomic, strong) GCDAsyncUdpSocket   *socket;
@property (nonatomic, strong) NSString *portString;
@property (nonatomic, strong) NSString *addressString;

@end

@implementation TIoTCoreWired

- (instancetype)initWithPort:(NSString *)port multicastGroupOrHost:(NSString *)address {
    self = [super init];
    if (self) {
        self.portString = port?:@"7838"; //需要更改接入端口号
        self.addressString = address?:@"239.0.0.255"; //需要更改接入IP
    }
    return self;
}

- (void)releaseAlloc{
    
    if (self.socket) {
        [self.socket close];
        self.socket = nil;
    }
}

#pragma mark 代理-GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    DDLogInfo(@"--连接成功---udpSocketAddress--%@",address);
    if (self.delegate && [self.delegate respondsToSelector:@selector(wiredDistributionNetUdpSocket:didConnectToAddress:)]) {
        [self.delegate wiredDistributionNetUdpSocket:sock didConnectToAddress:address];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error {
    DDLogInfo(@"---连接失败--udp Socket Not Connect--%@",error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(wiredDistributionNetUdpSocket:didNotConnect:)]) {
        [self.delegate wiredDistributionNetUdpSocket:sock didNotConnect:error];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    DDLogInfo(@"--发送消息成功-----Socket Send Data Success");
    if (self.delegate && [self.delegate respondsToSelector:@selector(wiredDistributionNetUdpSocket:didSendDataWithTag:)]) {
        [self.delegate wiredDistributionNetUdpSocket:sock didSendDataWithTag:tag];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    DDLogInfo(@"---发送消息失败-----Socket Not Send Data Error--%@",error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(wiredDistributionNetUdpSocket:didNotSendDataWithTag:dueToError:)]) {
        [self.delegate wiredDistributionNetUdpSocket:sock didNotSendDataWithTag:tag dueToError:error];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    NSError *jsonerror = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
    DDLogInfo(@"---接收消息成功---收到设备端的响应 [%@:%d] %@", ip, port, dic);
    if (self.delegate && [self.delegate respondsToSelector:@selector(wiredDistributionNetUdpSocket:didReceiveData:fromAddress:withFilterContext:)]) {
        [self.delegate wiredDistributionNetUdpSocket:sock didReceiveData:data fromAddress:address withFilterContext:filterContext];
    }
}

- (void)monitorDeviceSignal {
    
    [self releaseAlloc];
    
    
    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    self.socket.delegate = self;
    
    NSError *error = nil;
    
    //绑定本地端口
    [self.socket bindToPort:self.portString.intValue error:&error];
    
    //加入组播
    [self.socket joinMulticastGroup:self.addressString error:&error];
    
    //启用广播
    [self.socket enableBroadcast:YES error:&error];

    //开始接收数据
    [self.socket beginReceiving:&error];
    
}

- (void)sendDeviceMessage:(NSDictionary *)message {
    
    [self.socket sendData:[NSJSONSerialization dataWithJSONObject:message?:@{} options:NSJSONWritingPrettyPrinted error:nil] toHost:self.addressString port:self.portString.intValue withTimeout:-1 tag:100];
}

- (void)stopConnect {
    [self.socket closeAfterSending];
    [self releaseAlloc];
}


@end
