## 第三方定制 APP 部署流程   

###  部署前准备   
- 注册 [腾讯云账号](https://cloud.tencent.com/register?s_url=https%3A%2F%2Fcloud.tencent.com%2F) 并完成 [实名验证](https://console.cloud.tencent.com/developer)。   
- 登录腾讯云 [物联网开发平台控制台](https://cloud.tencent.com/document/product/1081/45901#.E8.8E.B7.E5.8F.96-app-key-.E5.92.8C-app-secret)，并注册[移动应用](https://console.cloud.tencent.com/tpns)。     

### 设置 App 配置文件     

- iOS 平台的配置文件为 **[app-config.json](https://github.com/tencentyun/iot-link-ios/blob/master/Source/LinkApp/Supporting%20Files/app-config.json)** 

- Android  平台的配置文件为 **[app-config.json](https://github.com/tencentyun/iot-link-android/blob/master/app-config.json)**    

具体可查看： [APP 配置文件设置](https://github.com/tencentyun/iot-link-ios/blob/master/doc/%E5%B9%B3%E5%8F%B0%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E9%83%A8%E7%BD%B2%E8%AE%BE%E7%BD%AE.md)   

### App 配网绑定设备
- 通过 [softAP 配网](https://cloud.tencent.com/document/product/1081/43695) 方式（自助配网）绑定真实设备。   
- 通过 [SmartConfig 配网](https://cloud.tencent.com/document/product/1081/43696) 方式（智能配网）绑定真实设备。   
   
>!在此配网方式下，目前只支持 Wi-Fi 2.4GHZ。


​	




