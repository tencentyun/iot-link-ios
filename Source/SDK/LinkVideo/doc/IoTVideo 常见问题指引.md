## ToT Video 常见问题



### **APP SDK 开发常见问题**

**Q**：设备到app使用的传输格式是什么？

**A**：IoTVideo 步骤如下：

```
IoTVideo SDK 采用 HTTP-FLV 传输方式。在设备端推流传入（h264/h265/aac/pcm）等压缩格式，APP SDK 接收到 FLV 视频格式
```


**Q**：推流直播过程中如何保存接受到的原始FLV流？

**A**：保存步骤如下：

```
APP SDK 提供了保存接受到原始流的功能

Android SDK 保存方式：
1.调用 recordstream 接口，在启动播放器前调用这个即可
2.导出原始流文件：
adb pull  /storage/emulated/0/raw_video.data

iOS SDK 保存方式：
1.调用 recordstream 接口，在启动播放器前调用这个即可
2.导出原始流文件：
运行 SDKDemo 可通过iOS系统“文件APP” 进入“我的iPhone”查看到保存的原始流文件“video.data”
```


**Q**：推流直播过程中视频花屏现象如何排查？

**A**：排查步骤如下：

```
1.使用上面提供的保持原始流的方法导出原始流文件
2.排查原始流是否有 I 帧丢失，花屏一般因素主要由于丢帧造成，建议弱网以GOP为等单位丢帧
3.可以和设备推流端保存的原始流对比是否有丢弃
```

**Q**：查询设备状态信令是否可以去掉？？

**A**：排查步骤如下：

```
1.建议优先拉流，可节省耗时。查询状态和拉流并行的话，回优先返回处理信令，造成部分耗时
2.是否可去掉，需要看产品业务逻辑。该查询信令主要目的是用这个做设备拒绝服务的限制，超过设备端设置的连接数阈值，就返回错误state了
```


**Q**：直播耗时如何优化？

**A**：可优化点如下：

```
APP SDK 调用优化：
1.拆分调用 APP SDK StartService 接口和 setXp2pinfo 接口
2.可通过直接请求拉流，如设备拒绝服务，返回StreamEnd通知，状态信令可放后面请求节省耗时
3.重连触发后，可不用重新走start，直接重新设置setXp2pInfo和启动播放器拉流即可
4.设置播放器探测参数，通过 ijkplayer 播放器 setOption 接口设置 probesize 大小。
   该参数表示在推过来的这个大小里面需要包涵音频和视频的spspps I帧

设备SDK 调用优化:
1. 保障推流第一帧为 I 帧
2. 优化推视频流高于音频流，避免前几包数据都是音频的话，会消耗首开。可通过原始流的pts排查第一个视频帧消耗多少pts毫秒
3. 推流优化码率、分辨率

排查网络环境：
1.保存原始流后，查看第一帧 pkt_size 大小（如 pkt_size=17136），根据 APP SDK 日志中
‘recver:xx deliver seq:xx length:xxx wantSep:xx, readable=1’
根据 length 字段的大小预估出接受完整第一帧的时间戳
2.得到预估时间后，即可计算第一帧接收到所有分包后的耗时
```


**Q**：APP播放过程中画面卡住，丢包重传排查和处理？

**A**：排查方法如下：

```
APP 画面卡住主要有以下几点原因：
1. 直播过程中，出现丢包重传。需要设置设备端 mtu 参数大小，尝试改为1000
   丢包重传的现象确认： APP SDK 日志中长时间接收到只有 recver，断续才会有http200，证明           是有丢包重传了。
2. 直播过程中，设备停止推流。可通过 StreamEnd 回调判断。
3. 推流的 pts 单位是毫秒，需确认，音频和视频使用同一参考时间累加
```


**Q**：当前使用到的域名有哪些？

**A**：域名整理如下：

```
国内域名
设备端：
stun.iotvideo.tencentcs.com   
*.iotcloud.tencentdevices.com
log.qvb.qcloud.com
conf.qvb.qcloud.com
$productId.iotcloud.tencentdevices.com
*.cos.ap-guangzhou.myqcloud.com（云存）
*.cos.ap-beijing.myqcloud.com（云存）

小程序、app 端：
stun.iotvideo.tencentcs.com
log.qvb.qcloud.com
conf.qvb.qcloud.com
*.cos.ap-guangzhou.myqcloud.com（云存）
*.cos.ap-beijing.myqcloud.com（云存）
zylcb.iotvideo.tencentcs.com（云存）
+客户的自建后台域名
```
