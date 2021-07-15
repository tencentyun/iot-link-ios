## 概述

该演示Demo主要演示了 [LinkSDKDemo](https://https://github.com/tencentyun/iot-link-ios/tree/master/Source/LinkSDKDemo) 目录下三个 SDK ([CORE](https://https://github.com/tencentyun/iot-link-ios/tree/master/Source/LinkSDKDemo/Core) [RTC](https://https://github.com/tencentyun/iot-link-ios/tree/master/Source/LinkSDKDemo/RTC/ui) [VIDEO](https://https://github.com/tencentyun/iot-link-ios/tree/master/Source/LinkSDKDemo/Video)) 的基础功能，其中

1. `CORE`主要演示设备与物联网开发平台之间建立连接、通信、关闭连接等功能；
2. `RTC`主要演示了实时音视频通话场景；
3. `VIDEO`主要演示以下几个场景：
   * 实时监控
   * 音频对讲
   * 本地回放
   * 云端存储

## Demo入口示意图

```
├── LinkSDKDemo
│   ├── CORE 
│   ├── VIDEO 
│   └── RTC 
```

## 演示Demo的执行路径

### 1. CORE

待补充

### 2. RTC

待补充

### 3. VIDEO 

#### 操作路径：

`VIDEO ---> IoT Video（消费版） ---> 登录 ---> 预览 or 回放（本地回放/云端存储）`

#### 演示内容：

1. 预览
   * 对讲（开始对讲--->停止对讲）
   * 观看实时监控
   * 拍照
   * 移动端录像
2. 同屏
      * 多设备同屏幕播放
3. 回放
   * 本地回放（待补充）
   * 云端存储
     * 选择日期（选择要观看哪一天的远端视频）
     * 左右拖动日期下方的`时间刻度尺`，当`游标`落在蓝色部分时即可观看云端视频（蓝色部分代表当前日期可观看视频的时间段）