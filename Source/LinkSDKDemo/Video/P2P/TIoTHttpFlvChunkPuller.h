//
//  TIoTHttpFlvChunkPuller.h
//  LinkSDKDemo
//
//  基于 NSURLSession 的 HTTP-FLV 分块（chunked）拉流器。
//  通过 `[[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:combinedId]`
//  返回的 base URL，拼接 `ipc.flv?action=live&channel=X&quality=Y` 后
//  发起标准 HTTP GET 请求，delegate 会以流式（chunk）方式持续回调数据。
//
//  相比 `startAvRecvService` + `getVideoPacketWithID` 方式：
//   * 通过 URL 参数 channel=X 天然区分不同通道，可并行拉多路
//   * 不受 SDK 内单例 delegate 限制
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTHttpFlvChunkPuller;

@protocol TIoTHttpFlvChunkPullerDelegate <NSObject>
@optional
/// 收到 HTTP 响应头（通常 200 才算连接成功）
/// 回调在内部 delegate 队列（非主线程）
- (void)puller:(TIoTHttpFlvChunkPuller *)puller
    didReceiveResponse:(NSHTTPURLResponse *)response;

/// 收到一段 FLV 分块数据
/// ⚠️ 该回调可能高频触发，切勿在此做耗时操作
/// 回调在内部 delegate 队列（非主线程）
- (void)puller:(TIoTHttpFlvChunkPuller *)puller
       didReceiveChunk:(NSData *)data;

/// 拉流结束（正常关闭 / 主动 stop / 出错）
/// error == nil 表示远端主动关闭连接
/// 回调在内部 delegate 队列（非主线程）
- (void)puller:(TIoTHttpFlvChunkPuller *)puller
    didFinishWithError:(nullable NSError *)error;
@end


@interface TIoTHttpFlvChunkPuller : NSObject

/// 通道标识（仅用于日志/区分），例如 @"ch0"
@property (nonatomic, copy, readonly) NSString *tag;

/// 完整拉流 URL
@property (nonatomic, copy, readonly) NSString *url;

/// 当前是否正在拉流
@property (nonatomic, assign, readonly) BOOL isRunning;

/// 本次会话累计收到的字节数
@property (nonatomic, assign, readonly) uint64_t receivedBytes;

@property (nonatomic, weak) id<TIoTHttpFlvChunkPullerDelegate> delegate;

/// 可选：若设置为一个沙盒完整路径，puller 会把收到的 chunk 追加写入该文件（用于调试保存 FLV）
@property (nonatomic, copy, nullable) NSString *dumpFilePath;

/// 初始化
/// @param tag 通道标识，如 @"ch0"
/// @param url 完整 HTTP-FLV URL，形如 http://127.0.0.1:xxxx/ipc.flv?action=live&channel=0
- (instancetype)initWithTag:(NSString *)tag url:(NSString *)url NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// 开始拉流
- (void)start;

/// 停止拉流（可多次调用；释放前会自动 stop）
- (void)stop;

@end

NS_ASSUME_NONNULL_END
