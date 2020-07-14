## APP SDK创建引导

**开发前准备**

- 请获取在 [物联网开发平台](https://cloud.tencent.com/product/iotexplorer) 创建应用时生成的 **APP Key**。<u>***App Key 和 App Secret 用于访问应用端 API 时生成签名串，参见[应用端 API 简介](https://cloud.tencent.com/document/product/1081/40773)。签名算法务必在服务端实现，腾讯连连 App 开源版的使用方式仅为演示，请勿将 App Key 和 App Secret 保存在客户端，避免泄露***</u>。
- 下载所需的 [APP SDK](https://github.com/tencentyun/iot-link-ios/tree/master/Source)

**安装环境**

- 安装工具 [Xcode开发工具](https://apps.apple.com/cn/app/xcode/id497799835?mt=12)

- 集成SDK方式

  - pod方式集成

    `pod TIoTLinkKit`

  - Framework方式集成

    `打开工程，将下载的Framework拖动到工程中，检查TARGETS-> Build Phases-> Link Binary With Libaries 中是否已包含添加的FrameWork`

**使用说明**

1. 打开 Appdelegate.m 文件，引入SDK头文件 `#import <QCFoundation/QCFoundation.h>`,并添加SDK配置。

   ```objective-c
   - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
       // Override point for customization after application launch.
       
       [[TIoTCoreServices shared] setAppKey:@"您的Key"];
       [TIoTCoreServices shared].logEnable = YES;
       
           self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[UIViewController new]];
       }
       
       return YES;
   } 
   ```

2. APP SDK 功能划分说明

   | 对             | 实现相关功能                                |
   | -------------- | ------------------------------------------- |
   | QCDeviceCenter | 配网模块                                    |
   | QCAPISets      | 设备控制、消息相关、家庭管理、账户管理等api |
   | QCFoundation   | 工具类                                      |

3. 账户相关接口，包含手机号、邮箱注册，登录登出，密码操作，用户信息操作。此处仅为Demo演示功能，***<u>强烈推荐遵从官方建议自建账户后台服务后，由自建服务接入物联网平台服务，保证 AppSecret 不被泄露</u>***。账户详细接口请参考 [官方文档](https://cloud.tencent.com/document/product/1081/40774) 或者 APP SDK 文件[TIoTCoreAccountSet.h](https://github.com/tencentyun/iot-link-ios/blob/master/Source/LinkSDK/QCAPISets/Public/TIoTCoreAccountSet.h)

   ```objective-c
   1.邮箱注册
   - (void)createEmailUserWithEmail:(NSString *)email verificationCode:(NSString *)code password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;
   
   2.校验验证码（用于邮箱注册）
   - (void)checkVerificationCodeWithEmail:(NSString *)email code:(NSString *)code success:(SRHandler)success failure:(FRHandler)failure;
   
   3.手机号码注册
   - (void)createPhoneUserWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;
   ```

4. 详细功能请参考 [APP SDK接入指南](https://github.com/tencentyun/iot-link-ios/blob/master/doc/SDK开发/APP SDK接入指南.md)