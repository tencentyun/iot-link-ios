## APP SDK接入指南

**SDK模块说明**

​	腾讯连连APP SDK是腾讯云物联网平台提供，设备厂商可通过SDK将设备接入腾讯云物联网平台，来进行设备管理。核心模块包含 设备配网的两种模式（SmartConfig与Soft AP）、设备消息操作、账户系统、设备管理

APP SDK 功能划分说明

| 对             | 实现相关功能                                |
| -------------- | ------------------------------------------- |
| QCDeviceCenter | 配网模块                                    |
| QCAPISets      | 设备控制、消息相关、家庭管理、账户管理等api |
| QCFoundation   | 工具类                                      |



**SDK接入详情**

1. 接入前的API各参数对照表

   - 基础参数对照表

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

   - 设备控制面板列表参数对照表

   | id            | 设备可控属性id，如”power_switch”、”color“        |
   | ------------- | ------------------------------------------------ |
   | name          | 设备可控属性名，如”电源开关”、“颜色”             |
   | big           | 设备可控属性面板按钮是否是大按钮                 |
   | type          | 设备可控属性面板按钮类型，如：btn-big、btn-col-1 |
   | value         | 属性值                                           |
   | familyAddress | 家庭地址                                         |
   | LastUpdate    | 最后一次更新时间戳                               |

   

2. 设备配网接入。

   ```objective-c
   #1.创建配网对象QCSmartConfig或者QCSoftAP（视配网方式决定），注：sdk内不持有配网对象，需使用者自己持有
   self.sc = [[QCSmartConfig alloc] initWithSSID:name PWD:password BSSID:bssid];  
   self.sc.delegate = self;
   
   #2.遵循TIoTCoreAddDeviceDelegate协议，设置代理，并接入代理方法：
   - (void)onResult:(QCResult *)result{  
       if (result.code == 0) {// 配网成功 
       }  
       else  {// 配网失败 
       }  
   }
   
   #3.开始配网流程
   [self.sc startAddDevice];
   
   #4.配网成功后，可获取设备控制面板数据
   [[TIoTCoreDeviceSet shared] getDeviceDetailWithProductId:self.deviceInfo[@"ProductId"] deviceName:self.deviceInfo[@"DeviceName"] success:^(id  _Nonnull responseObject) {
     
     NSLog(@"==%@",responseObject);    
   } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {        
   }];
   
   #5.下发控制数据
   [[TIoTCoreDeviceSet shared] controlDeviceDataWithProductId:self.deviceInfo[@"ProductId"] deviceName:self.deviceInfo[@"DeviceName"] data:data success:^(id  _Nonnull responseObject) {
           [MBProgressHUD showSuccess:@"发送成功"];
   } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
   }];
   ```

3. 账户系统接口说明

   ```objective-c
   #1.邮箱注册
   - (void)createEmailUserWithEmail:(NSString *)email verificationCode:(NSString *)code password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;
   
   #2.校验验证码（用于邮箱注册）
   - (void)checkVerificationCodeWithEmail:(NSString *)email code:(NSString *)code success:(SRHandler)success failure:(FRHandler)failure;
   
   #3.手机号码注册
   - (void)createPhoneUserWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verificationCode:(NSString *)verificationCode password:(NSString *)password success:(SRHandler)success failure:(FRHandler)failure;
   ```

4. 家庭相关接口，包含家庭成员操作、房间操作

   ```objective-c
   #1. 获取某设备的用户列表
   [[TIoTCoreDeviceSet shared] getUserListForDeviceWithProductId:**self**.deviceInfo[@"ProductId"] deviceName:**self**.deviceInfo[@"DeviceName"] offset:0 limit:0 success:^(**id** **_Nonnull** responseObject){
   	   responseObject[@"Users"];
   } failure:^(NSString * **_Nullable** reason, NSError * **_Nullable** error) {
   }];
   
   #2.邀请家庭成员
   [[TIoTCoreFamilySet shared] sendInvitationToEmail:self.tf.text withFamilyId:self.familyId success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:@"发送成功"];
   } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {                
   }];
   
   #3.创建房间
   [[TIoTCoreFamilySet shared] createRoomWithFamilyId:self.familyId name:self.roomTF.text success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:@"添加成功"];
   } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {        
   }];
   ```

5. 详细接口请参考 [官方文档](https://cloud.tencent.com/document/product/1081/40772) 或者 APP SDK Demo 工程 [LinkSDKDemo](https://github.com/tencentyun/iot-link-ios/tree/master/Source/LinkSDKDemo)

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
   
   

若接入过程中有其他问题，请参考 [APP SDK开发常见问题](https://github.com/tencentyun/iot-link-ios/blob/master/doc/SDK开发/APP%20SDK开发常见问题.md) 
