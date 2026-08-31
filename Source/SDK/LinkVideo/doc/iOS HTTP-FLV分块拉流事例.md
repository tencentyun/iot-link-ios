# iOS HTTP-FLV 分块（chunk）拉流事例

通过 `[[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:combinedId]` 获取本地 HTTP 服务的 base URL，
拼接 `ipc.flv?action=live&channel=X` 后发起标准 **HTTP GET** 请求，
利用 `NSURLSession` 的流式回调持续接收 chunked 分块数据。
相比 `startAvRecvService`，可通过 URL 参数 `channel=X` 天然区分多通道，能并行拉多路，互不干扰。

---

## 1. URL 拼接规则

`getUrlForHttpFlv:` 返回的 base 形如：

```
http://127.0.0.1:<port>/
```

完整拉流 URL 拼接方式：

```
{base}ipc.flv?action={live|playback}&channel={N}&quality={standard|high|super}
```

| 参数 | 说明 | 取值 |
|---|---|---|
| `action` | 拉流类型 | `live` 直播 / `playback` 回看 |
| `channel` | 通道号 | IPC 通常 `0`；NVR 取设备列表 `Channel` 字段（`0`/`1`/`2`…） |
| `quality` | 清晰度（可选） | `standard` / `high` / `super` |

示例：

```objc
NSString *combinedId = @"pro_xxx/dev_xxx";
NSString *base = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:combinedId];

NSString *urlCh0 = [NSString stringWithFormat:@"%@ipc.flv?action=live&channel=0&quality=high", base];
NSString *urlCh1 = [NSString stringWithFormat:@"%@ipc.flv?action=live&channel=1&quality=high", base];
```

---

## 2. 事例代码

工程内已提供两个可直接使用的类：

| 文件 | 作用 |
|---|---|
| `Source/LinkSDKDemo/Video/P2P/TIoTHttpFlvChunkPuller.h/.m` | 通用 HTTP-FLV 分块拉流器，基于 `NSURLSession` 流式回调 |
| `Source/LinkSDKDemo/Video/P2P/Controller/TIoTDemoHttpFlvChunkVC.h/.m` | 双通道演示 VC：**同时拉取 channel=0 与 channel=1** |

### 2.1 `TIoTHttpFlvChunkPuller` 关键 API

```objc
@protocol TIoTHttpFlvChunkPullerDelegate <NSObject>
@optional
- (void)puller:(TIoTHttpFlvChunkPuller *)puller didReceiveResponse:(NSHTTPURLResponse *)response;
- (void)puller:(TIoTHttpFlvChunkPuller *)puller didReceiveChunk:(NSData *)data; // 高频回调
- (void)puller:(TIoTHttpFlvChunkPuller *)puller didFinishWithError:(nullable NSError *)error;
@end

@interface TIoTHttpFlvChunkPuller : NSObject
@property (nonatomic, weak) id<TIoTHttpFlvChunkPullerDelegate> delegate;
@property (nonatomic, copy, nullable) NSString *dumpFilePath; // 可选：落盘调试
- (instancetype)initWithTag:(NSString *)tag url:(NSString *)url;
- (void)start;
- (void)stop;
@end
```

内部实现要点：

1. `NSURLSessionConfiguration.timeoutIntervalForResource = 0`（不限）——流式请求必须；
2. `NSURLRequest` header 加 `Transfer-Encoding: chunked` + `Connection: keep-alive`；
3. 通过 `URLSession:dataTask:didReceiveData:` 回调持续接收分块；
4. delegate 回调运行在**独立 NSOperationQueue**（非主线程），业务侧使用需要注意线程切换。

### 2.2 双通道演示 VC 用法

在你已经调用过 `startAppWith:` 并进入某个预览页/入口页后，push `TIoTDemoHttpFlvChunkVC` 即可：

```objc
#import "TIoTDemoHttpFlvChunkVC.h"

TIoTDemoHttpFlvChunkVC *vc = [[TIoTDemoHttpFlvChunkVC alloc] init];
vc.productId  = @"pro_xxx";
vc.deviceName = @"dev_xxx";
vc.channelA   = @"0";     // 通道 A
vc.channelB   = @"1";     // 通道 B
vc.quality    = @"high";  // standard / high / super
vc.dumpToFile = YES;      // 可选：把两路 FLV 同时落盘（Documents 目录）
[self.navigationController pushViewController:vc animated:YES];
```

进入 VC 后点击「开始拉流(双通道)」按钮：

- 会向本地 SDK HTTP 服务同时发起两个独立 HTTP GET 请求；
- 两个 `TIoTHttpFlvChunkPuller` 实例分别处理各自 channel 的 chunk；
- 界面上会展示每一路的运行状态、累计字节数、完整 URL；
- 若开启了 `dumpToFile`，两路数据分别写入：
  - `Documents/httpflv_channel_0.flv`
  - `Documents/httpflv_channel_1.flv`

### 2.3 最小拉流事例（不含 UI）

```objc
NSString *combinedId = @"pro_xxx/dev_xxx";
NSString *base = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:combinedId];

// 通道 0
NSString *url0 = [NSString stringWithFormat:@"%@ipc.flv?action=live&channel=0&quality=high", base];
TIoTHttpFlvChunkPuller *pullerA = [[TIoTHttpFlvChunkPuller alloc] initWithTag:@"ch0" url:url0];
pullerA.delegate = self;
[pullerA start];

// 通道 1
NSString *url1 = [NSString stringWithFormat:@"%@ipc.flv?action=live&channel=1&quality=high", base];
TIoTHttpFlvChunkPuller *pullerB = [[TIoTHttpFlvChunkPuller alloc] initWithTag:@"ch1" url:url1];
pullerB.delegate = self;
[pullerB start];

// 数据回调（注意非主线程）
- (void)puller:(TIoTHttpFlvChunkPuller *)puller didReceiveChunk:(NSData *)data {
    NSLog(@"%@ 收到 %lu 字节 FLV 分块", puller.tag, (unsigned long)data.length);
    // TODO: 将 data 送入 FLV 解封装 / 播放器 / 转发
}
```

---

## 3. 使用前提

1. **SDK 已初始化并 ready**：调用 `startAppWith:` 后需等待 `TIoTCoreXP2PBridgeNotificationReady` 通知（`userInfo[@"id"]` 为对应 deviceName）；ready 之后 `getUrlForHttpFlv:` 才有返回值。
2. **`combinedId` 格式**：一律为 `"productId/deviceName"`，示例 VC 内已按此拼接。
3. **设备端支持多通道**：`channel` 参数由设备端解析，如设备（尤其是 NVR）本身未实现多通道，请先与设备侧确认。
4. **App Transport Security**：base URL 为 `http://127.0.0.1:xxxxx`，iOS 默认允许 loopback，无需额外 ATS 配置；如宿主 App 全局关闭了明文 HTTP 请求也需保证 loopback 例外未被覆盖。

---

## 4. 将文件加入工程

新增文件已放置在：

```
Source/LinkSDKDemo/Video/P2P/TIoTHttpFlvChunkPuller.h
Source/LinkSDKDemo/Video/P2P/TIoTHttpFlvChunkPuller.m
Source/LinkSDKDemo/Video/P2P/Controller/TIoTDemoHttpFlvChunkVC.h
Source/LinkSDKDemo/Video/P2P/Controller/TIoTDemoHttpFlvChunkVC.m
```

由于文件是脚本新增的，**需要在 Xcode 中手动加入 Target**：

1. 打开 `iot-link-ios.xcworkspace`
2. 右键对应分组 `Video/P2P` 与 `Video/P2P/Controller` → `Add Files to "LinkSDKDemo"…`
3. 勾选 `LinkSDKDemo` target，`Create groups`
4. Build 一次确认

---

## 5. 常见问题

| 现象 | 排查思路 |
|---|---|
| `getUrlForHttpFlv:` 返回空 | SDK 尚未 ready，检查是否收到 `TIoTCoreXP2PBridgeNotificationReady`；`combinedId` 是否为 `productId/deviceName` 拼接 |
| 连接返回 4xx / 5xx | ① URL 参数是否正确；② 设备是否上线；③ 对应 channel 是否存在 |
| 只有一路有数据 | ① 检查设备是否真的支持第二个 channel；② 尝试 `channel=1`、`channel=2` 逐一验证；③ 观察设备端日志 |
| 数据回调频繁但拉流几秒后卡住 | 业务侧 `didReceiveChunk:` 处理耗时，占满 delegate 队列，建议在回调里立即 `dispatch_async` 出去 |
| dump 出来的 `.flv` 无法播放 | 通常拉流被中断没写完；先在关卡按 `stop` 再复制文件；可用 VLC / ffplay 播放验证 |
