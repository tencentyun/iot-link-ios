//
//  TIoTCoreXP2PBridge.h
//  TIoTLinkKitDemo
//
//

#import <Foundation/Foundation.h>
//#include "AppWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TIoTLocalNetDetchDelegate <NSObject>

/*
 * 裸流接口使用方式:
 * 通过 startAvRecvService 和 stopAvRecvService 接口，可以启动和停止裸流传输
 * 客户端拉取到的裸流数据对应 data 参数
 */
- (void)reviceDeviceMessage:(NSData *)deviceMessage;
@end


@interface TIoTLocalNetDetch : NSObject
@property (nonatomic, strong) NSString *p2pVersion;
@property (nonatomic, weak) id<TIoTLocalNetDetchDelegate> delegate;

/*
 * 停止监听本地设备信号
 */
- (void)stopLocalMonitor;

/*
 * 开始监听本地设备信号
 */
-(void)startLocalMonitorService:(NSString *)port;

/*
 * 发送组播探测包
 */
-(void)sendUDPData:(NSString *)productID clientToken:(NSString *)clientToken ;

@end

NS_ASSUME_NONNULL_END
