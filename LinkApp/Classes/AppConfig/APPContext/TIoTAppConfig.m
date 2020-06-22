//
//  TIoTAppConfig.m
//  LinkApp
//
//  Created by eagleychen on 2020/6/18.
//  Copyright © 2020 Winext. All rights reserved.
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
    
    NSString *localPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"app-open-config.json"];
    
    NSData *data = [NSData dataWithContentsOfFile:localPath];

    if (!data) {
        return nil;
    }
    
    TIoTAppConfigModel *model = [TIoTAppConfigModel yy_modelWithJSON:data];
    return model;
}
@end
