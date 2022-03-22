## Windows&Linux 端直播场景延时优化参考

**测试说明：直播延时优化影响因素较多，需要通过采集、编码、发送、播放等整条链路整体优化，如下只针对播放端进行部分优化举例，数据仅供参考**

### **测试方法**

##### 使用 Android Camera 设备采集 win 系统左侧窗口北京时间戳，并推流，win/linux 观看端通过 ffplay 工具播放（右侧窗口），对比从采集到播放出图耗时

<img src="https://github.com/tencentyun/iot-link-ios/wiki/iot_video/video_win_delay_image.png" width = "254" height = "322" div align=center />



### **测试工具命令**

##### 通过调整 ffplay 工具参数，即可实现低延时播放端

```
ffplay -i http://127.0.0.1:63309/app.xnet/ipc.p2p.com/ipc.flv?action=live&channel=0 -probesize 25600  -fflags nobuffer+fastseek+flush_packets -sync video -flags low_delay -framedrop -vf setpts=PTS/2 -af atempo=2
```



### **标清码流信息参考**

```
Input #0, flv, from 'http://127.0.0.1:49944/app.xnet/ipc.p2p.com/ipc.flv?action=live':
Metadata:
interval : 0
encoder : libflv
Duration: N/A, start: 2426315.763000, bitrate: N/A
Stream #0:0: Audio: aac (LC), 44100 Hz, stereo, fltp, 131 kb/s
Stream #0:1: Video: h264 (High), yuv420p(tv, smpte170m/bt470bg/smpte170m, progressive), 640x360, 25 fps, 1k tbr, 1k tbn
```
![Watch the video](https://github.com/tencentyun/iot-link-ios/wiki/iot_video/video_win_delay_mov.gif)



### **标清码流延时数据统计参考**

##### win10 APP 拉直播流场景下网络延时数据参考如下：

| 耗时单位（s）       | case1        | case2        | case3        | case4        | case5        | case6        | case7        | case8        | case9        | case10       | 耗时平均值   |
|---------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|---------|
| camera端采集时间戳  | 14:14:28:345 | 14:14:30:126 | 14:14:32:168 | 14:14:33:749 | 14:14:35:105 | 14:14:56:280 | 15:20:32:661 | 15:20:36:657 | 15:20:58:675 | 15:21:02:435 |         |
| win 10播放渲染时间戳 | 14:14:26:570 | 14:14:28:371 | 14:14:30:475 | 14:14:32:076 | 14:14:33:380 | 14:14:54:315 | 15:20:30:318 | 15:20:34:306 | 15:20:56:316 | 15:21:00:086 |         |
| 延时            | 1.775        | 1.755        | 1.693        | 1.673        | 1.725        | 1.965        | 2.343        | 2.351        | 2.359        | 2.349        | 1.998 s |



### **高清码流信息参考**

```
Input #0, flv, from 'http://127.0.0.1:53131/app.xnet/ipc.p2p.com/ipc.flv?action=live':
  Metadata:
    interval        : 0
    encoder         : libflv
  Duration: N/A, start: 2895147.281000, bitrate: N/A
  Stream #0:0: Audio: aac (LC), 44100 Hz, stereo, fltp, 131 kb/s
  Stream #0:1: Video: h264 (High), yuv420p(tv, smpte170m/bt470bg/smpte170m, progressive), 1280x720, 25 fps, 1k tbr, 1k tbn
```
![Watch the video](https://github.com/tencentyun/iot-link-ios/wiki/iot_video/video_win_delay_high.gif)


### **高清码流延时数据统计参考**

##### win10 APP 拉直播流高清码流场景下网络延时数据参考如下：

| 耗时单位（s）       | case1        | case2        | case3        | case4        | case5        | case6        | case7        | case8        | case9        | case10       | 耗时平均值   |
|---------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|---------|
| camera端采集时间戳  | 10:44:14:678 | 10:44:24:554 | 10:44:34:921 | 10:44:43:029 | 10:44:54:365 | 11:16:45:994 | 11:16:57:208 | 11:17:06:887 | 11:17:17:271 | 11:17:32:231 |         |
| win 10播放渲染时间戳 | 10:44:13:070 | 10:44:22:842 | 10:44:33:289 | 10:44:41:357 | 10:44:52:746 | 11:16:44:599 | 11:16:55:739 | 11:17:05:606 | 11:17:15:923 | 11:17:30:895 |         |
| 延时            | 1.608        | 1.712        | 1.632        | 1.672        | 1.619        | 1.395        | 1.469        | 1.281        | 1.348        | 1.336        | 1.507 s |



### **APP 直播延时优化参考**
[APP 直播延时优化](./IoTVideo%20常见问题指引.md)
