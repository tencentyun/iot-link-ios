//
//  TIotSoftApUdpSocketUtil.h
//  TIoTLinkKit
//
//  Created by ccharlesren on 2020/12/17.
//

#import <Foundation/Foundation.h>
@class TIoTVideoDistributionNetModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^SoftApUdpSocketFaildBlock)(void);

@interface TIotSoftApUdpSocketUtil : NSObject

/**
 初始化 参数必须传，不能为空
 */
- (instancetype)initWithInfo:(TIoTVideoDistributionNetModel *)model withGatewayIp:(NSString *)ip withFialdBlcok:(SoftApUdpSocketFaildBlock)fialdBlcok;

/**
 softAp开始配网
 */
- (void)startSoftApUdpSocket;

/**
 softAP停止配网
 */
- (void)stopSoftApUdpSocket;
@end

NS_ASSUME_NONNULL_END
