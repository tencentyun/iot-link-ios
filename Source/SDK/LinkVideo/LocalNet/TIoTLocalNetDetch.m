//
//  TIoTCoreXP2PBridge.m
//  TIoTLinkKitDemo
//
//

#import "TIoTLocalNetDetch.h"
#import "GCDAsyncUdpSocket.h"

@interface TIoTLocalNetDetch()<GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) NSString *portString;

@end


@implementation TIoTLocalNetDetch


- (void)stopLocalMonitor {
    
    if (self.udpSocket) {
        [self.udpSocket close];
        self.udpSocket = nil;
    }
}

// 初始化发送 UDP socket
-(void)startLocalMonitorService:(NSString *)port {
    self.portString = port?:@"3072"; //需要更改接入端口号
    
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError * error = nil;
    [self.udpSocket bindToPort:self.portString.intValue error:&error];// bindToPort:是服务器的port
    if (error) {    //监听错误打印错误信息
        NSLog(@"error:%@",error);
    }else {         //监听成功则开始接收信息
        [self.udpSocket enableBroadcast:YES error:&error];
        if (error) {
            NSLog(@"开启组播失败: %@",error);
        }
        [self.udpSocket beginReceiving:&error];
    }
}

// 发送UDP
-(void)sendUDPData:(NSString *)productID clientToken:(NSString *)clientToken {

    if (!productID || productID.length < 1) {
        NSLog(@"请输入对应设备标识,设备 sdk 与 app sdk 需输入同一标识");
        return;
    }
    
    if (!clientToken || clientToken.length < 1) {
        clientToken = @"ios_client_detech";
    }
    
    NSNumber *timstamp = [NSNumber numberWithInteger:[[NSDate date]timeIntervalSince1970]];
    
    NSDictionary *monitorDic = @{
        @"method": @"probe",
        @"clientToken": clientToken,
        @"timestamp": timstamp,
        @"timeoutMs": @(5000),
        @"params": @{@"productId": productID}
    };
    NSLog(@"发送探测消息 : %@",monitorDic);
    
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:monitorDic options:NSJSONWritingPrettyPrinted error:&error];
    
    
    NSData *detchHeader = [self detchDataForPacketLength:1 version:self.p2pVersion?:@"2.4.3-beta.xxx" packetLength:jsonData.length];
    NSMutableData *fullData = [NSMutableData dataWithData:detchHeader];
    [fullData appendData:jsonData];
    
    [self.udpSocket sendData:fullData toHost:@"255.255.255.255" port:self.portString.intValue withTimeout:-1 tag:0];
}


- (NSData*)detchDataForPacketLength:(int)messageType version:(NSString *)version packetLength:(int)packetLength {
    
    NSArray<NSString *> *verArr = [version componentsSeparatedByString:@"."];
    if (verArr.count < 2) {
        NSLog(@"local video xp2p sdk 版本不匹配");
        return nil;
    }
    int versionHigh = verArr.firstObject.intValue;
    int versionLow = verArr[1].intValue;
    
    int byte3len = (packetLength / pow(2, 8));
    int byte2len = (packetLength % (int)pow(2, 8));
    
    Byte b0 = messageType & 0xff;
    Byte b1 = (((versionHigh & 0xf) << 4) | (versionLow & 0xf)) & 0xff;
    Byte b2 = byte2len & 0xff;
    Byte b3 = byte3len & 0xff;
    Byte result[] = {b0, b1, b2, b3};
    return [NSData dataWithBytes:result length:sizeof(result)];
}



#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"发送信息成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"发送信息失败");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    if (data.length < 5) {
        NSLog(@"接受到错误数据");
        return;
    }
    
    Byte messageHeader[4]; //1个字节消息类型
    [data getBytes:messageHeader length:4];
    int messageType = (int) (messageHeader[0]&0xff); //1：探测消息；2：探测响应消息；其他保留
    int messageVers_H = (int) (messageHeader[1]&0xf0)>>4; //高4bit：主版本号；低4bit：子版本号
    int messageVers_L = (int) (messageHeader[1]&0x0f); //高4bit：主版本号；低4bit：子版本号
    int messageLenth = (int) ((messageHeader[2]&0xff) | ((messageHeader[3] << 8)&0xff00)); //2个字节：payload长度，不包含消息头
    
    NSLog(@"收到回包:type===>%d,versionH===>%d,versionL===>%d,lenght===>%d",messageType,messageVers_H,messageVers_L,messageLenth);
    
    if (messageType == 2) {
        NSData *contentData = [data subdataWithRange:NSMakeRange(4, data.length-4)];
        NSString *aStr = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
        NSLog(@"接收到消息内容: %@-----\n%@",aStr, data);
        if ([self.delegate respondsToSelector:@selector(reviceDeviceMessage:)]) {
            [self.delegate reviceDeviceMessage:contentData];
        }
    }
}

@end
