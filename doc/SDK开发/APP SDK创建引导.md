## APP SDK创建引导

**使用说明**   
- iOS
打开 Appdelegate.m 文件，引入SDK 头文件 ,并添加 SDK 配置。   

```
    #import <QCFoundation/TIoTCoreFoundation.h>
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         // Override point for customization after application launch.

         [[TIoTCoreServices shared] setAppKey:@"物联网开发平台申请的 App Key"];
         [TIoTCoreServices shared].logEnable = YES;

         self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[UIViewController new]];
         }

         return YES;
    }    
```   
