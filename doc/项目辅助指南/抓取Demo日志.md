## 拉取demo app的日志

### 通过iPhone手机“文件” App 查看日志文件
1. 打开手机中的文件 APP

2. 进入 "我的iPhone" --> "LinkSDKDemo" --> "TTLog"

3. 此时也可通过右上角按钮导出日志文件



## 拉取demo app的裸流文件

### 通过iPhone手机“文件” App 查看裸流文件
1. 启动camera端，同时启动LinkSDKDemo

2. 在LinkSDKDemo端的 VIDEO事例中，设备列表前一页打开“数据帧写入文件”的开关

3. 运行直播或回看场景，切换到[裸流传输模式](https://github.com/tencentyun/iot-link-ios/blob/master/Source/SDK/LinkVideo/doc/iOS%20Video接入指引文档.md)(参考startAvRecvService接口)

4. 等待结束后进入 "我的iPhone" --> "LinkSDKDemo" --> "video"，提取裸流文件（可通过右上角按钮导出文件）
