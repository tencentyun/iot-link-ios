//
//  TIoTDemoHttpFlvChunkVC.h
//  LinkSDKDemo
//
//  HTTP-FLV 分块拉流事例 —— 同时拉取两个不同 channel 的直播流。
//
//  ⚠️ 使用前提：
//   1. 已通过 [TIoTCoreXP2PBridge startAppWith:...] 启动 P2P 通道；
//   2. 已收到（或即将收到） TIoTCoreXP2PBridgeNotificationReady 通知，
//      本 VC 会同时监听该通知，在 ready 后自动获取 http-flv base url；
//   3. 设备端需支持通过 channel 参数区分通道（NVR 场景下常用，
//      例如 channel=0/1/2；IPC 一般都是 channel=0）。
//

#import "TIoTDemoBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDemoHttpFlvChunkVC : TIoTDemoBaseViewController

/// 设备 productId（必填）
@property (nonatomic, copy) NSString *productId;

/// 设备 deviceName（必填，与 SDK startAppWith: 传入的一致）
@property (nonatomic, copy) NSString *deviceName;

/// 通道 A，默认 @"0"
@property (nonatomic, copy, nullable) NSString *channelA;

/// 通道 B，默认 @"1"
@property (nonatomic, copy, nullable) NSString *channelB;

/// 清晰度：standard / high / super，默认 high
@property (nonatomic, copy, nullable) NSString *quality;

/// 是否把收到的 FLV chunk 落盘到沙盒 Documents 目录（用于调试），默认 YES
@property (nonatomic, assign) BOOL dumpToFile;

@end

NS_ASSUME_NONNULL_END
