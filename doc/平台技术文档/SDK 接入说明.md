## SDK 接入说明

**1、SDK 模块说明**

腾讯连连 SDK 由腾讯云物联网平台提供。设备厂商可通过 SDK 将设备接入腾讯云物联网平台，进行设备管理；SDK 核心模块包含设备配网（SmartConfig 模式和 Soft AP 模式）、设备消息操作、账户系统、设备管理。

**APP SDK 功能划分说明**

iOS：

| 子模块         | 实现相关功能                                |
| -------------- | ------------------------------------------- |
| QCDeviceCenter | 配网模块                                    |
| QCAPISets      | 设备控制、消息相关、家庭管理、账户管理等api |
| QCFoundation   | 工具类                                      |

Android：

| 子模块 | 实现相关功能                                |
| ------ | ------------------------------------------- |
| link   | 配网模块                                    |
| auth   | 设备控制、消息相关、家庭管理、账户管理等api |
| utils  | 工具类                                      |
| log    | 日志模块                                    |

**2、API 接口说明**

* 基础参数对照表

| phoneNumber   | 手机号                          |
| ------------- | ------------------------------- |
| countryCode   | 国际区号，如中国大陆区号为86    |
| email         | 邮箱地址                        |
| familyId      | 家庭ID                          |
| familyName    | 家庭名称                        |
| familyAddress | 家庭地址                        |
| Role          | 1 是所有者， 0 是普通成员       |
| roomId        | 房间ID                          |
| roomName      | 房间名                          |
| ProductId     | 设备产品ID                      |
| Avatar        | 用户信息中头像链接              |
| signature     | 使用绑定设备api时传入，设备签名 |
| DeviceId      | 设备ID                          |

* 设备控制面板列表参数对照表

| id            | 设备可控属性id，如”power_switch”、”color“        |
| ------------- | ------------------------------------------------ |
| name          | 设备可控属性名，如”电源开关”、“颜色”             |
| big           | 设备可控属性面板按钮是否是大按钮                 |
| type          | 设备可控属性面板按钮类型，如：btn-big、btn-col-1 |
| value         | 属性值                                           |
| familyAddress | 家庭地址                                         |
| LastUpdate    | 最后一次更新时间戳                               |

* 详细接口请参考 [官方文档](https://cloud.tencent.com/document/product/1081/40772) 或者 SDK Demo 工程 [iOS 版本 LinkSDKDemo](https://github.com/tencentyun/iot-link-ios/tree/master/Source/LinkSDKDemo)/[Android 版本 sdkdemo](https://github.com/tencentyun/iot-link-android/tree/master/sdkdemo)

| 物联网应用开发文档 | 对应文档地址                                                 |
| ------------------ | ------------------------------------------------------------ |
| 应用端API          | [应用端API文档](https://cloud.tencent.com/document/product/1081/40773) |
| 用户管理           | [用户管理文档](https://cloud.tencent.com/document/product/1081/40774) |
| 配网管理           | [配网管理文档](https://cloud.tencent.com/document/product/1081/44043) |
| 设备管理           | [设备管理文档](https://cloud.tencent.com/document/product/1081/40775) |
| 设备分享           | [设备分享文档](https://cloud.tencent.com/document/product/1081/43200) |
| 家庭管理           | [家庭管理文档](https://cloud.tencent.com/document/product/1081/40776) |
| 设备定时           | [设备定时文档](https://cloud.tencent.com/document/product/1081/40777) |
| 消息管理           | [消息管理文档](https://cloud.tencent.com/document/product/1081/40778) |
| 长连接通信         | [长连接通信文档](https://cloud.tencent.com/document/product/1081/40779) |
| 数据结构           | [数据结构文档](https://cloud.tencent.com/document/product/1081/40780) |

