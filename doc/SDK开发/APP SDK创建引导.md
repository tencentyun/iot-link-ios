## APP SDK创建引导

**使用说明**   
- iOS
打开 Appdelegate.m 文件，引入SDK 头文件 ,并添加 SDK 配置。   

```
#import <QCFoundation/TIoTCoreFoundation.h>
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

	/*
     * 此处仅供参考, 需自建服务接入物联网平台服务，以免 App Secret 泄露
     * 自建服务可参考此处 https://cloud.tencent.com/document/product/1081/45901#.E6.90.AD.E5.BB.BA.E5.90.8E.E5.8F.B0.E6.9C.8D.E5.8A.A1.2C-.E5.B0.86-app-api-.E8.B0.83.E7.94.A8.E7.94.B1.E8.AE.BE.E5.A4.87.E7.AB.AF.E5.8F.91.E8.B5.B7.E5.88.87.E6.8D.A2.E4.B8.BA.E7.94.B1.E8.87.AA.E5.BB.BA.E5.90.8E.E5.8F.B0.E6.9C.8D.E5.8A.A1.E5.8F.91.E8.B5.B7
     */
    
	TIoTCoreAppEnvironment *environment = [TIoTCoreAppEnvironment shareEnvironment];
	[environment setEnvironment];
    
	environment.appKey = @"物联网开发平台申请的 App Key";
	environment.appSecret = @"物联网开发平台申请的 App Secret";
	self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[UIViewController new]];
	
	return YES;
}    
```   
