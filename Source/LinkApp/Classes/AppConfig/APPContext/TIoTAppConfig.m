//
//  TIoTAppConfig.m
//  LinkApp
//
//

#import "TIoTAppConfig.h"
#import <YYModel/YYModel.h>

@implementation TIoTAppConfigModel
@end

// Convert json to model:
//User *user = [User yy_modelWithJSON:json];
    
// Convert model to json:
//NSDictionary *json = [user yy_modelToJSONObject];

@implementation TIoTAppConfig

+ (TIoTAppConfigModel *)loadLocalConfigList {
    
    NSString *localPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"app-config.json"];
    
    NSData *data = [NSData dataWithContentsOfFile:localPath];
    
    if (!data) {
        if ([UIApplication sharedApplication].delegate.window) {
            [MBProgressHUD showError:@"配置文件解析失败!" toView:[UIApplication sharedApplication].delegate.window];
        }
        DDLogError(@">>>>>配置文件解析失败!!!>>>>>");
        return nil;
    }
    
    TIoTAppConfigModel *model = [TIoTAppConfigModel yy_modelWithJSON:data];
    return model;
}

// 0为公版或开源； 1为用户
+ (NSInteger)appTypeWithModel:(TIoTAppConfigModel *)model {

    if (model.TencentIotLinkAppkey == nil || model.TencentIotLinkAppSecret == nil) {
     //
        return 0;
    }else if ([model.TencentIotLinkAppkey isEqualToString:@"请输入从物联网开发平台申请的Appkey, 正式发布前务必填写"] || [model.TencentIotLinkAppSecret isEqualToString:@"请输入从物联网开发平台申请的AppSecrect, AppSecrect请保存在服务端，此处仅为演示，如有泄露概不负责"]) {
    //拉取源码走开源
        return 0;
    }else {
    //（用户版本）
        return 1;
    }
}

+ (BOOL)isOriginAppkeyAndSecret:(TIoTAppConfigModel *)model {
    if ([model.TencentIotLinkAppkey isEqualToString:@"请输入从物联网开发平台申请的Appkey, 正式发布前务必填写"] || [model.TencentIotLinkAppSecret isEqualToString:@"请输入从物联网开发平台申请的AppSecrect, AppSecrect请保存在服务端，此处仅为演示，如有泄露概不负责"]) {
        return YES;
    }else {
        return NO;
    }
}

// yes 上架 NO 开源
+ (BOOL)weixinLoginWithModel:(TIoTAppConfigModel *)model {
    if (model.TencentIotLinkAppkey == nil || model.TencentIotLinkAppSecret == nil) {
        return YES;
    }else {
        return NO;
    }
}

@end
