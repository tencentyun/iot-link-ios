//
//  WCUserManage.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreUserManage : NSObject

+(instancetype)shared;

@property (nonatomic) BOOL isValidToken;

@property (nonatomic, copy, nullable) NSString *accessToken;
@property (nonatomic, copy, nullable) NSString *expireAt;

@property (nonatomic, copy, nullable) NSString *userId;
@property (nonatomic, copy, nullable) NSString *avatar;
@property (nonatomic, copy, nullable) NSString *nickName;
@property (nonatomic, copy, nullable) NSString *phoneNumber;
@property (nonatomic, copy, nullable) NSString *countryCode;
@property (nonatomic, copy, nullable) NSString *email;
@property (nonatomic, copy, nullable) NSString *hasPassword;    //0 用户没有设置密码  1 用户已经设置密码
@property (nonatomic, copy, nullable) NSString *WxOpenID;
@property (nonatomic, copy, nullable) NSString *requestID;
@property (nonatomic, copy, nullable) NSString *hasBindWxOpenID;       //判断微信是否绑定成功  0 没有绑定  1已经绑定成功
@property (nonatomic, copy, nullable) NSString *userRegionId;           // 22 美东  1 国内
@property (nonatomic, copy, nullable) NSString *userRegion;             // 美东 na-ashburn 国内 ap-guangzhou
@property (nonatomic, copy, nullable) NSString *countryTitle;          // 中国大陆  美国
@property (nonatomic, copy, nullable) NSString *countryTitleEN;        //Chinese Mainland U.S.A

@property (nonatomic,copy) NSString *familyId;//
@property (nonatomic,copy) NSString *currentRoomId;
@property (nonatomic,assign) NSInteger FamilyType;
/*
 注册页面 用户选择项
 */
@property (nonatomic, copy, nullable) NSString *signIn_countryCode;      //注册页面 手机 1 美东 86国内
@property (nonatomic, copy, nullable) NSString *signIn_Title;            //注册页面 手机 区域显示title
@property (nonatomic, copy, nullable) NSString *signIn_Phone_Numner;           //注册页面 手机号码
//@property (nonatomic, copy, nullable) NSString *signIn_Email_countryCode;      //注册页面 邮箱 1 美东 86 国内
//@property (nonatomic, copy, nullable) NSString *signIn_Email_Title;            //注册页面 邮箱 区域显示title
@property (nonatomic, copy, nullable) NSString *signIn_Email_Address;          //注册页面 邮箱地址

/*
 登录页面 用户选择项
 */
@property (nonatomic, copy, nullable) NSString *login_CountryCode;       //登录页面 验证码 1 美东 86 国内
@property (nonatomic, copy, nullable) NSString *login_Title;              //登录页面 验证码 区域显示title
@property (nonatomic, copy, nullable) NSString *login_Code_Text;             //登录页面 手机/邮箱
//@property (nonatomic, copy, nullable) NSString *login_PhoneEmail_CountryCode;        //登录页面 手机/邮箱 1 美东 86 国内
//@property (nonatomic, copy, nullable) NSString *login_PhoneEmail_Title;              //登录页面 手机/邮箱 区域显示title
//@property (nonatomic, copy, nullable) NSString *login_PhoneEmail_Text;            //登录页面 手机/邮箱

/**
 首次进入，选择生日日期
 */

@property (nonatomic, copy, nullable) NSString *isShowBirthDayView;  //是否弹出生日选择View

/*
 保存首次进入APP 设备
 */

@property (nonatomic, copy, nullable) NSString *addDeviceNumber; //用户首次进入APP，添加设备数量


/**
 TRTC 通话
 */
@property (nonatomic, copy, nullable) NSString *sys_call_status;

//保存accessToken 和 有效期
- (void)saveAccessToken:(NSString *)accessToken expireAt:(NSString *)expireAt;

//保存用户信息
- (void)saveUserInfo:(NSDictionary *)userInfo;


- (void)clear;

//注册后 用户选择项清空
- (void)signInClear;
@end

NS_ASSUME_NONNULL_END
