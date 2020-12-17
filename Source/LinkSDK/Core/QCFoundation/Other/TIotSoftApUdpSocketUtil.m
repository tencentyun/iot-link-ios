//
//  TIotSoftApUdpSocketUtil.m
//  TIoTLinkKit
//
//  Created by ccharlesren on 2020/12/17.
//

#import "TIotSoftApUdpSocketUtil.h"
#import "TIoTCoreAddDevice.h"
#import "TIoTVideoDistributionNetModel.h"

@interface TIotSoftApUdpSocketUtil ()<TIoTCoreAddDeviceDelegate>
@property (nonatomic, strong) TIoTCoreSoftAP   *softAP;
@end

@implementation TIotSoftApUdpSocketUtil

- (instancetype)initWithInfo:(TIoTVideoDistributionNetModel *)model withGatewayIp:(NSString *)ip withFialdBlcok:(SoftApUdpSocketFaildBlock)fialdBlcok{
    self = [super init];
    if (self) {
        
        NSString *apSsid = model.ssid?:@"";
        NSString *apPwd = model.pwd?:@"";
        
        self.softAP = [[TIoTCoreSoftAP alloc] initWithSSID:apSsid PWD:apPwd];
        self.softAP.delegate = self;
        self.softAP.gatewayIpString = ip;
        self.softAP.udpFaildBlock = fialdBlcok;
        
    }
    return self;
}

/**
 softAp开始配网
 */
- (void)startSoftApUdpSocket {
    [self.softAP startAddDevice];
}

/**
 softAP停止配网
 */
- (void)stopSoftApUdpSocket {
    [self.softAP stopAddDevice];
}
@end
