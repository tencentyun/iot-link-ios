## APP 发布前确认事项   

* 确认填写用户自己的 Bundle ID 和对应的发布证书。

* 请根据实际情况调整配置文件中的内容，[详情可见](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/WeChat_Login/Development_Guide.html)，需要配置的内容如下：

  ```json
  {
    "WXAccessAppId": "",
    "TencentIotLinkAppkey": "请输入从物联网开发平台申请的 App key，正式发布前务必填写",
    "TencentIotLinkAppSecret": "请输入从物联网开发平台申请的 App Secret，App Secret 请保存在服务端，此处仅为演示，如有泄露概不负责",
    "XgAccessId": "",
    "XgAccessKey": "",
    "TencentMapSDKValue": "",
    "TencentIotLinkSDKDemoAppkey": ""
  }
  ```
  * 用户需要使用从物联网平台自建应用所获得的 **TencentIotLinkAppkey** 和 **TencentIotLinkAppSecret**，来替换 APP 中对应的字符串。
  * 用户需要使用从腾讯推送平台自建应用所获得的 **XgAccessId** 和 **XgAccessKey**，来替换 APP 中对应的字符串。
  * 用户需要使用从微信开发平台自建应用所获得的 **WXAccessAppId**，来替换 APP 中对应的字符串。

* 如果用户确认接入 Firebase，用户需要使用从 Firebase 官网自建应用获得 **GoogleService-Info.plist**，替换 APP 中 /LinkApp/Supporting Files 目录下的 **GoogleService-Info.plist** 文件。   

