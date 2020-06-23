## 第三方定制 APP 接入指南

### <font color=red>接入前必要准备</font>    

* 腾讯云物联网开发平台创建应用获取 APP Key 和 App Secret。   
*  腾讯推送创建应用，获取 AccessID 和 AccessKey。   
    1、注册腾讯云用户，请在[腾讯云物联网开发平台](https://cloud.tencent.com)完成注册操作   
    2、进入腾讯移动推送：   
    <img src="IMG/Picture2_Push_Entry.png" alt="Picture2_Push_Entry.png" style="zoom: 50%;" />   
    3、创建产品并填写信息：   
    <img src="IMG/Picture3_Push_CreateProduct.png" alt="Picture3_Push_CreateProduct.png" style="zoom: 50%;" />   
    <img src="IMG/Picture4_Push_ProductInfo.png" alt="Picture4_Push_ProductInfo.png" style="zoom:67%;" />   
    4、在 iOS 和 Android 平台上，填写对应的 BundleID 和包名：   
    <img src="IMG/Picture5_Push_managerConfiguration.png" alt="Picture5_Push_managerConfiguration.png" style="zoom: 50%;" />   

    <img src="IMG/Picture6_Push_iOSBundleID.png" alt="Picture6_Push_iOSBundleID.png" style="zoom: 80%;" />   
       
    5、 <font color=red>填写完 BundleID 后，一定要保存好 iOS 或 Android 平台的 AccessID 和 AccessKey，在 SDK 接入工程配置时会用到，并上传 iOS 平台对应的证书。</font>   
   
    <img src="IMG/Picture8_Push_Config_ios.png" alt="Picture8_Push_Config_ios.png" style="zoom: 50%;" />   

     6、如要接入使用需要购买或申请测试使用。   
     <img src="IMG/Picture10_Push_Purch.png" alt="Picture10_Push_Purch.png" style="zoom:50%;" />   
    
*   微信登录 AppID   
    1、登录[微信开放平台](https://open.weixin.qq.com/)   
    2、在微信开放平台中的**移动应用**模块下创建应用，填写对应信息，审核通过后，即可获取 AppID 和 AppSecret，<font color=red>注意一定要保存好 AppID，在 SDK 接入配置中需要用到。</font> 
* （可选）接入 Firebase 上报 Crash 信息方便用户分析排查问题。   
	1、注册 Firebase 账号并创建项目，在项目中注册应用。   
	2、按照步骤初始化添加 Firebase SDK。    
	   按照平台查看 firebase 文档。   
	   相关链接：[https://firebase.google.com/docs?authuser=0](https://firebase.google.com/docs?authuser=0)    
	   iOS 平台：   
	   相关链接  [https://firebase.google.com/docs/ios/setup?authuser=0](https://firebase.google.com/docs/ios/setup?authuser=0)   
  
	   3、接入 Crashlytics 功能。   
	   iOS 平台：   
	   接入相关链接  [https://firebase.google.com/docs/crashlytics/get-started?authuser=0&platform=iOS](https://firebase.google.com/docs/crashlytics/get-started?authuser=0&platform=iOS)   

### APP 源码获取
iOS 版本 APP 可通过[腾讯连连-iOS](https://github.com/tencentyun/iot-link-ios)下载源码 。

### APP Demo、SDK Demo 和 SDK 的关系   

APP 内已经包含 SDK Demo 和 SDK，不需要额外再引入，目录如下：

<img src="IMG/Picture1_APP_SDK_SDKDemo.png" alt="Picture1_APP_SDK_SDKDemo.png" style="zoom: 80%;" />

