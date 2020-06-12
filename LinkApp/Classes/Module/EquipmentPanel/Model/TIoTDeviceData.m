//
//  WCDeviceData.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/23.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTDeviceData.h"

@implementation TIoTDeviceData

+(instancetype)shared{
    static TIoTDeviceData *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (void)deallocDeviceData{
    self.deviceId = nil;
    self.productDic = nil;
    self.dataTemplateDic = nil;
    self.profileDic = nil;
    self.deviceDataDic = nil;
    self.propertiesArr = nil;
}

- (void)handleAllPropertyData:(NSDictionary *)propertyData deviceData:(NSDictionary *)deviceData{
    self.productDic = propertyData;
    self.dataTemplateDic = [NSString jsonToObject:propertyData[@"DataTemplate"]];
    self.profileDic = self.dataTemplateDic[@"profile"];
    
    NSArray *tmpArr = self.dataTemplateDic[@"properties"];
    self.propertiesArr = tmpArr.mutableCopy;
    
    self.deviceDataDic = deviceData;
    
    [self addDeviceDataToAllProperties];
}

//把设备当前数据，组装到 全部属性中去
- (void)addDeviceDataToAllProperties{
    NSArray *deviceKeys = [self.deviceDataDic allKeys];
    for (NSString *deviceKey in deviceKeys) {
        for (NSMutableDictionary *property in self.propertiesArr) {
            if ([deviceKey isEqualToString:property[@"id"]]) {
                [property setObject:self.deviceDataDic[deviceKey] forKey:@"status"];
                break;
            }
        }
    }
    
    WCLog(@"deviceData:%@",self.propertiesArr);
}

- (void)handleReportDevice:(NSDictionary *)reportDevice{
    if ([self.deviceId isEqualToString:reportDevice[@"DeviceId"]]) {
        
        NSDictionary *payloadDic = [NSString base64Decode:reportDevice[@"Payload"]];
        WCLog(@"payloadDic:%@",payloadDic);
        
        NSDictionary *reportDic = payloadDic[@"state"][@"reported"];
        if (reportDic == nil) {
            reportDic = payloadDic[@"payload"][@"state"];
        }
        if (reportDic == nil) {
            reportDic = payloadDic[@"params"];
        }
        
        
        NSArray *keys = [reportDic allKeys];
        for (NSString *key in keys) {
            if ([key isEqualToString:self.bigProp[@"id"]]) {
                NSMutableDictionary *dic = self.bigProp[@"status"];
                [dic setObject:reportDic[key] forKey:@"Value"];
            }
            else
            {
                for (NSMutableDictionary *propertie in self.properties) {
                    if ([key isEqualToString:propertie[@"id"]]) {
                        NSMutableDictionary *dic = propertie[@"status"];
                        [dic setObject:reportDic[key] forKey:@"Value"];
                        break;
                    }
                }
            }
        }
    }
    
    WCLog(@"reportData:%@",self.properties);
}

- (void)zipData:(NSDictionary *)uiInfo baseInfo:(NSDictionary *)baseInfo deviceData:(NSDictionary *)deviceInfo
{
    NSDictionary *standard = uiInfo[@"Panel"][@"standard"];
        if (standard && baseInfo && deviceInfo) {
            
            self.theme = standard[@"theme"];
            self.bgImgId = standard[@"bgImgId"];
            self.navBar = standard[@"navBar"];
            self.timingProject = [standard[@"timingProject"] boolValue];
            
            NSMutableArray *propertiesForUI = [standard[@"properties"] mutableCopy];
            NSArray *propertiesForInfo = baseInfo[@"properties"];
            
            for (int i = 0; i < propertiesForUI.count; i ++) {
                NSMutableDictionary *proper = propertiesForUI[i];
                for (NSString *key in [deviceInfo allKeys]) {
                    if ([key isEqualToString:proper[@"id"]]) {
                        [proper setValue:deviceInfo[key] forKey:@"status"];
                    }
                }
                
                for (NSDictionary *infodic in propertiesForInfo) {
                    
                    if ([infodic[@"id"] isEqualToString:proper[@"id"]]) {
                        [proper setValue:infodic[@"name"] forKey:@"name"];
                        [proper setValue:infodic[@"desc"] forKey:@"desc"];
                        [proper setValue:infodic[@"define"] forKey:@"define"];
                        break;
                    }
                }
                
                NSString *type = proper[@"ui"][@"type"];
                if ([type isEqualToString:@"btn-big"]) {
                    //大按钮
                    self.bigProp = proper;
                }
                
            }
            
            [self.allProperties addObjectsFromArray:propertiesForUI];
            
            if (self.bigProp) {
                [propertiesForUI removeObject:self.bigProp];
            }
            
            [self.properties addObjectsFromArray:propertiesForUI];
        }
}


#pragma mark setter or getter
- (NSMutableArray *)properties{
    if (_properties == nil) {
        _properties = [NSMutableArray array];
    }
    return _properties;
}

- (NSMutableArray *)allProperties{
    if (_allProperties == nil) {
        _allProperties = [NSMutableArray array];
    }
    return _allProperties;
}

@end
