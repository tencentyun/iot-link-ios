## 第三方定制 APP 接入指南

### 腾讯云物联网开发文档   
请先查看 [腾讯云物联网开发平台文档](https://cloud.tencent.com/document/product/1081/45901) 说明。

### App 接入详情   
* 将 AppAPI 调用由设备端接入用户自建后台服务   
   注意：
>!  登录前所使用的API URL 为 https://iot.cloud.tencent.com/api/exploreropen/appapi，不建议在设备端调用，需要替换为自建的后台服务，以避免密钥的泄漏。
     
   api/studioapp/* 为公版APP专用，OEM的App使用的是应用端 API(api/exploreropen/*)，当在[App 参数写入配置文件]()中配置 TencentIotLinkAppkey 后, api/studioapp/* 调用将自动切换为 应用端 API 调用。
     appapi(api/exploreropen/appapi)请在自建后台进行调用, tokenapi(api/exploreropen/tokenapi) 可安全在设备端调用。

    
  [iOS 接入指南详情](https://github.com/tencentyun/iot-link-ios/blob/master/doc/%E5%B9%B3%E5%8F%B0%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E6%8E%A5%E5%85%A5%E6%8C%87%E5%8D%97.md)      
    
  [Android 接入指南详情](https://github.com/tencentyun/iot-link-android/blob/master/doc/%E7%AC%AC%E4%B8%89%E6%96%B9%E5%AE%9A%E5%88%B6APP%E6%8E%A5%E5%85%A5%E6%8C%87%E5%8D%97.md)

