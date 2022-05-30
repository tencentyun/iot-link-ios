### 概述
Video SDK 主要提供了 APP 端 P2P 接入、实时监控、语音对讲、本地回放等基本能力。


## iOS 接入流程

1、在 App 的 Podfile 文件中添加如下依赖项

```
pod 'TIoTLinkVideo'
```
具体版本号可参考 [LinkVideo](TODO: sdk发布页url)


2、运行SDKDemo 

* 打开Xcode，选择 Target --> LinkSDKDemo
* 需要在 [AppDelegate.m](../../LinkSDKDemo/Supporting%20Files/AppDelegate.m#L38~L40) 中，配置 SecretId、SecretKey、ProductId；
* <u>***SecretId、SecretKey、ProductId 用于访问 物联网智能视频服务，此处的使用方式仅为演示，请勿将 SecretId、SecretKey 保存在客户端，避免泄露***</u>

### SDK相关文档
* [iOS SDK说明](doc/iOS%20Video接入指引文档.md)
* [PC 观看端直播场景延时优化](doc/win%20观看端直播场景延时优化.md)
* [双向音视频延时测试](doc/双向音视频延时测试.md)
* [双向通话延时参数说明](doc/双向延时参数说明.md)
* [双向码率自适应说明](doc/双向码率自适应.md)
* [双向通话断网流程](doc/双向通话断网流程.md)