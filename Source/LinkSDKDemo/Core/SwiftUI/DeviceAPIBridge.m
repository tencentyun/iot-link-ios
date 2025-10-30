//
//  DeviceAPIBridge.m
//  LinkSDKDemo
//
//  设备API桥接类实现 - 调用原有的 OC 设备相关逻辑
//

#import "DeviceAPIBridge.h"
#import "TIoTCoreDeviceSet.h"
#import "TIoTCoreUserManage.h"
#import "TIoTCoreFamilySet.h"

@implementation DeviceAPIBridge

#pragma mark - 家庭管理

+ (void)getFamilyListWithCompletion:(FamilyListCompletion)completion {
    [[TIoTCoreFamilySet shared] getFamilyListWithOffset:0 limit:0 success:^(id _Nonnull responseObject) {
        // 获取成功
        NSArray *familyList = nil;
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            familyList = dict[@"FamilyList"];
        }
        
        if (!familyList) {
            familyList = @[];
        }
        
        NSLog(@"✅ 获取家庭列表成功，共 %lu 个家庭", (unsigned long)familyList.count);
        
        if (completion) {
            completion(YES, familyList, nil);
        }
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary *dic) {
        // 获取失败
        NSString *errorMessage = reason ?: error.localizedDescription ?: @"获取家庭列表失败";
        NSLog(@"❌ 获取家庭列表失败: %@", errorMessage);
        
        if (completion) {
            completion(NO, nil, errorMessage);
        }
    }];
}

+ (void)createFamilyWithName:(NSString *)familyName
                     address:(NSString *)address
                  completion:(CreateFamilyCompletion)completion {
    
    [[TIoTCoreFamilySet shared] createFamilyWithName:familyName address:address success:^(id _Nonnull responseObject) {
        // 创建成功
        NSString *familyId = nil;
        
        NSLog(@"✅ 创建家庭成功: %@", familyId ?: @"");
        
        if (completion) {
            completion(YES, familyId, nil);
        }
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary *dic) {
        // 创建失败
        NSString *errorMessage = reason ?: error.localizedDescription ?: @"创建家庭失败";
        NSLog(@"❌ 创建家庭失败: %@", errorMessage);
        
        if (completion) {
            completion(NO, nil, errorMessage);
        }
    }];
}

#pragma mark - 房间管理

+ (void)getRoomListWithFamilyId:(NSString *)familyId
                     completion:(RoomListCompletion)completion {
    
    if (!familyId || familyId.length == 0) {
        if (completion) {
            completion(NO, nil, @"家庭ID不能为空");
        }
        return;
    }
    
    [[TIoTCoreFamilySet shared] getRoomListWithFamilyId:familyId offset:0 limit:0 success:^(id _Nonnull responseObject) {
        // 获取成功
        NSArray *roomList = nil;
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            roomList = dict[@"RoomList"];
        }
        
        if (!roomList) {
            roomList = @[];
        }
        
        NSLog(@"✅ 获取房间列表成功，共 %lu 个房间", (unsigned long)roomList.count);
        
        if (completion) {
            completion(YES, roomList, nil);
        }
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary *dic) {
        // 获取失败
        NSString *errorMessage = reason ?: error.localizedDescription ?: @"获取房间列表失败";
        NSLog(@"❌ 获取房间列表失败: %@", errorMessage);
        
        if (completion) {
            completion(NO, nil, errorMessage);
        }
    }];
}

#pragma mark - 设备绑定

+ (void)bindDeviceWithSignature:(NSString *)signature completion:(DeviceBindingCompletion)completion {
    // 参数验证
    if (!signature || signature.length == 0) {
        if (completion) {
            completion(NO, @"设备签名不能为空");
        }
        return;
    }
    
    // 获取当前用户的 familyId
    NSString *familyId = [TIoTCoreUserManage shared].familyId;
    if (!familyId || familyId.length == 0) {
        if (completion) {
            completion(NO, @"用户未登录或未加入家庭");
        }
        return;
    }
    
    // 调用原有的设备绑定方法
    [[TIoTCoreDeviceSet shared] bindDeviceWithDeviceSignature:signature
                                                    inFamilyId:familyId
                                                        roomId:@"0"
                                                       success:^(id _Nonnull responseObject) {
        // 绑定成功
        NSLog(@"✅ 设备绑定成功: %@", responseObject);
        if (completion) {
            completion(YES, @"设备添加成功！");
        }
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        // 绑定失败
        NSString *errorMessage = reason ?: error.localizedDescription ?: @"设备绑定失败，请重试";
        NSLog(@"❌ 设备绑定失败: %@", errorMessage);
        if (completion) {
            completion(NO, errorMessage);
        }
    }];
}

#pragma mark - 设备列表

+ (void)getDeviceListWithFamilyId:(NSString *)familyId
                           roomId:(NSString * _Nullable)roomId
                       completion:(DeviceListCompletion)completion {
    
    // 参数校验
    if (!familyId || familyId.length == 0) {
        if (completion) {
            completion(NO, nil, @"家庭ID不能为空");
        }
        return;
    }
    
    // 如果 roomId 为 nil，使用空字符串
    NSString *safeRoomId = roomId ?: @"";
    
    // 调用原有的设备列表 API
    [[TIoTCoreDeviceSet shared] getDeviceListWithFamilyId:familyId
                                                   roomId:safeRoomId
                                                   offset:0
                                                    limit:0
                                                  success:^(id _Nonnull responseObject) {
        // 获取成功
        NSArray *deviceList = nil;
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            deviceList = (NSArray *)responseObject;
        } else {
            deviceList = @[];
        }
        
        NSLog(@"✅ 获取设备列表成功，共 %lu 台设备", (unsigned long)deviceList.count);
        
        if (completion) {
            completion(YES, deviceList, nil);
        }
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        // 获取失败
        NSString *errorMessage = reason ?: error.localizedDescription ?: @"获取设备列表失败";
        
        NSLog(@"❌ 获取设备列表失败: %@", errorMessage);
        
        if (completion) {
            completion(NO, nil, errorMessage);
        }
    }];
}

#pragma mark - 设备解绑

+ (void)unbindDeviceWithFamilyId:(NSString *)familyId
                       productId:(NSString *)productId
                      deviceName:(NSString *)deviceName
                      completion:(UnbindDeviceCompletion)completion {
    
    // 参数校验
    if (!familyId || familyId.length == 0) {
        if (completion) {
            completion(NO, @"家庭ID不能为空");
        }
        return;
    }
    
    if (!productId || productId.length == 0) {
        if (completion) {
            completion(NO, @"产品ID不能为空");
        }
        return;
    }
    
    if (!deviceName || deviceName.length == 0) {
        if (completion) {
            completion(NO, @"设备名称不能为空");
        }
        return;
    }
    
    // 调用原有的设备解绑 API
    [[TIoTCoreDeviceSet shared] deleteDeviceWithFamilyId:familyId
                                               productId:productId
                                           andDeviceName:deviceName
                                                 success:^(id _Nonnull responseObject) {
        // 解绑成功
        NSLog(@"✅ 设备解绑成功: %@", responseObject);
        
        if (completion) {
            completion(YES, nil);
        }
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        // 解绑失败
        NSString *errorMessage = reason ?: error.localizedDescription ?: @"设备解绑失败";
        
        NSLog(@"❌ 设备解绑失败: %@", errorMessage);
        
        if (completion) {
            completion(NO, errorMessage);
        }
    }];
}

@end
