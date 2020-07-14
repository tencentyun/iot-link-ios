## APP SDK接入指南

**SDK说明**

​	腾讯连连APP SDK是腾讯云物联网平台提供，设备厂商可通过SDK将设备接入腾讯云物联网平台，来进行设备管理。核心模块包含 设备配网的两种模式（SmartConfig与Soft AP）、设备消息操作、账户系统、设备管理

1. 设备配网模块

   

   参数对照表

   | phoneNumber | 手机号                       |
   | ----------- | ---------------------------- |
   | countryCode | 国际区号，如中国大陆区号为86 |
   | email       | 邮箱地址                     |
   | familyId    | 家庭ID                       |
   | Role        | 1 是所有者， 0 是普通成员    |
   | roomId      | 房间ID                       |
   | ProductId   | 设备产品ID                   |

   

   ```objective-c
   1.邮箱注册
   - (void)createEmailUserWithEmail:(NSString *)email verificationCode:(NSString *)code password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;
   
   2.校验验证码（用于邮箱注册）
   - (void)checkVerificationCodeWithEmail:(NSString *)email code:(NSString *)code success:(SRHandler)success failure:(FRHandler)failure;
   
   3.手机号码注册
   - (void)createPhoneUserWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;
   ```

2. 设备配网。

3. 设备相关。包含设备信息获取与控制，设备

4. 家庭相关接口，包含家庭成员操作、房间操作、