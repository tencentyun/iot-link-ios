//
//  QCAddDevice.h
//  QCDeviceCenter
//
//

#import <Foundation/Foundation.h>
#import "TIoTCoreObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,TIoTConfigHardwareType) {
    TIoTConfigHardwareTypeSmartConfig,
    TIoTConfigHardwareTypeSoftAp,
};

@protocol TIoTCoreAddDeviceProtocol

@property (nonatomic,readonly) BOOL isConnecting;//是否正在配网中

/// 开始配网流程
- (void)startAddDevice;

/// 终止配网流程
- (void)stopAddDevice;

@end

@class TCSocket;
@class GCDAsyncUdpSocket;

@protocol TIoTCoreAddDeviceDelegate <NSObject>
@optional

/**
 smartConfig配网流程代理
 */

/**
  配网流程(将要废弃)
 */

/// softAP 连接成功
- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address;
/// softAP 发送消息成功
- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag;
/// softAP 发送消息失败
- (void)softApuUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;
/// softAP 设备接收消息成功
- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext;

/**
 配网代理 (推荐使用)
 */
/// Udp 连接成功
- (void)distributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address;
/// Udp 连接失败
- (void)distributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error;
/// App 发送消息成功
- (void)distributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag;
/// App 发送消息失败
- (void)distributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;
/// 设备端接收消息或返回数据代理
- (void)distributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext;
/// udp 关闭
- (void)distributionNetudpSocket:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error;

/**
 socket 代理
 */

///socket open
- (void)smartConfigOnHandleSocketOpen:(TCSocket *)socket;
///socket closed
- (void)smartConfigOnHandleSocketClosed:(TCSocket *)socket;
///socket received data
- (void)smartConfigOnHandleDataReceived:(TCSocket *)socket data:(NSData *)data;

/**
 TIoTCoreWired 端口监听代理
 */

/// 连接成功
- (void)wiredDistributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address;
/// 连接失败
- (void)wiredDistributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error;
/// 发送成功
- (void)wiredDistributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag;
/// 发送失败
- (void)wiredDistributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;
/// 接收消息成功
- (void)wiredDistributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext;

/**
 - (void)onResult: 代理方法可选实现，但是 TIoTCoreSmartConfig 对象和 TIoTCoreSoftAP 对象中的 updConnectBlock 、connectFaildBlock 、udpFaildBlock必须要实现
 */
- (void)onResult:(TIoTCoreResult *)result;

@end

typedef void(^createUpdBlock)(NSString *ipaAddrData);
typedef void(^connectFaildBlock)(void);


//***********************************************************//
@interface TIoTCoreSmartConfig : NSObject<TIoTCoreAddDeviceProtocol>

@property (nonatomic,copy,readonly) NSString *ssid;
@property (nonatomic,copy,readonly) NSString *password;
@property (nonatomic,copy,readonly) NSString *bssid;
@property (nonatomic,copy,readonly) NSString *token;    /// 当次配网token

@property (nonatomic,weak) id<TIoTCoreAddDeviceDelegate> delegate;
/*
 必须实现
*/

/// 创建udp链接block  初始化采用 - (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password BSSID:(NSString *)bssid Token:(NSString *)token 必须实现
@property (nonatomic, copy) createUpdBlock updConnectBlock;

/// 链接失败后block   必须实现
@property (nonatomic, copy) connectFaildBlock connectFaildBlock;

/// WiFi信息 （将要废弃）
/// @param ssid 必填
/// @param password 必填
/// @param bssid 必填
- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password BSSID:(NSString *)bssid;

/// WiFi信息 （推荐使用）
/// @param ssid 必填
/// @param password 必填
/// @param bssid 必填
/// @param token 必填  初次配网token
- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password BSSID:(NSString *)bssid Token:(NSString *)token;


@end


//*************************************************************//

typedef void(^connectUdpFaildBlock)(void);
//typedef NSString *_Nullable(^gatewayIPBlock)(void);

@interface TIoTCoreSoftAP : NSObject<TIoTCoreAddDeviceProtocol>

@property (nonatomic,copy,readonly) NSString *ssid;
@property (nonatomic,copy,readonly) NSString *password;
@property (nonatomic,copy,readonly) NSString *bssid;
@property (nonatomic,copy,readonly) NSString *token;
@property (nonatomic,weak) id<TIoTCoreAddDeviceDelegate> delegate;
@property (nonatomic, assign) NSInteger serverProt;
/*
 必须实现
*/


/// 获取 gateway 的ip   必填
@property (nonatomic, copy) NSString *gatewayIpString;

/// dup连接失败 block   必须实现
@property (nonatomic ,copy) connectUdpFaildBlock udpFaildBlock;

/// WiFi信息 （将要废弃）
/// @param ssid 必填
/// @param password 必填
- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password;

/// WiFi信息 （推荐使用）
/// @param ssid 必填
/// @param password 必填
/// @param bssid 必填
/// @param token 必填
/// @param netType 必填
- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password BSSID:(NSString *)bssid Token:(nonnull NSString *)token distributeNet:(TIoTConfigHardwareType)netType;


@end


//********************************************************//

@interface TIoTCoreWired : NSObject

@property (nonatomic,weak) id<TIoTCoreAddDeviceDelegate> delegate;


/// 初始化
/// @param port 端口号  *****必传*****
/// @param address 组播/广播IP地址 *****必传*****
- (instancetype)initWithPort:(NSString *)port multicastGroupOrHost:(NSString *)address;

/// 监听设备端
- (void)monitorDeviceSignal;

/// 发送信息
/// @param message （需要自行约定信息json格式）
- (void)sendDeviceMessage:(NSDictionary *)message;

/// 断开连接
- (void)stopConnect;

@end

NS_ASSUME_NONNULL_END
