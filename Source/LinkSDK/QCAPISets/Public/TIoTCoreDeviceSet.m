//
//  QCDeviceManager.m
//  QCAccount
//
//  Created by Wp on 2019/12/6.
//  Copyright © 2019 Reo. All rights reserved.
//

#import "QCDeviceSet.h"
#import "NSObject+additions.h"
#import <QCFoundation/QCFoundation.h>
#import "QCSocketCover.h"
#import "WCRequestAction.h"


@implementation DeviceInfo

- (NSMutableArray *)zipData
{
    if (!_zipData) {
        _zipData = [NSMutableArray array];
    }
    return _zipData;
}

@end



@interface QCDeviceSet()

@property (nonatomic,strong) NSArray *deviceList;

@end

@implementation QCDeviceSet

+ (instancetype)shared
{
    static QCDeviceSet *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setDeviceChange:(void (^)(NSDictionary *))deviceChange
{
    _deviceChange = deviceChange;
    [QCSocketCover shared].deviceChange = deviceChange;
}


- (void)activePushWithDeviceIds:(NSArray *)deviceIds complete:(Result)result
{
    NSDictionary *params = @{
        @"action":@"YunApi",
        @"reqId":[[NSUUID UUID] UUIDString],
        @"params":@{
            @"Action": @"AppDeviceTraceHeartBeat",
            @"AccessToken":[QCUserManage shared].accessToken,
            @"RequestId":@"req_heartbeat",
            @"ActionParams": @{
                @"DeviceIds": deviceIds
            }
        }
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"heartBeatStart" object:params];
    
    [[QCSocketCover shared] registerDeviceActive:deviceIds complete:^(BOOL sucess, NSDictionary * _Nonnull data) {
        result(sucess,data);
    }];
}

- (void)getDeviceListWithFamilyId:(NSString *)familyId roomId:(NSString *)roomId offset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure
{
    if (familyId == nil) {
        failure(@"familyId参数为空",nil);
        return;
    }
    
    if (roomId == nil) {
        failure(@"roomId参数为空",nil);
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:familyId forKey:@"FamilyId"];
    [param setObject:roomId forKey:@"RoomId"];
    if (limit > 0) {
        [param setObject:@(offset) forKey:@"Offset"];
        [param setObject:@(limit) forKey:@"Limit"];
    }
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetFamilyDeviceList params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        
        NSArray *devices = responseObject[@"DeviceList"];
        NSArray *deviceIds = [devices valueForKey:@"DeviceId"];
        if (deviceIds.count > 0) {
            NSDictionary *dic = @{@"ProductId":devices[0][@"ProductId"],@"DeviceIds":deviceIds};
            
            QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetDeviceStatuses params:dic useToken:YES];
            [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
                
                NSArray *statusArr = responseObject[@"DeviceStatuses"];
                
                NSMutableArray *tmpArr = [NSMutableArray array];
                for (NSDictionary *tmpDic in devices) {
                    
                    NSString *deviceId = tmpDic[@"DeviceId"];
                    for (NSDictionary *statusDic in statusArr) {
                        if ([deviceId isEqualToString:statusDic[@"DeviceId"]]) {
                            NSDictionary *dic = @{
                                @"AliasName":tmpDic[@"AliasName"],
                                @"DeviceId":tmpDic[@"DeviceId"],
                                @"DeviceName":tmpDic[@"DeviceName"],
                                @"IconUrl":tmpDic[@"IconUrl"],
                                @"ProductId":tmpDic[@"ProductId"],
                                @"Online":statusDic[@"Online"],
                                @"CreateTime":tmpDic[@"CreateTime"],
                                @"UpdateTime":tmpDic[@"UpdateTime"],
                                @"FamilyId":tmpDic[@"FamilyId"],
                                @"RoomId":tmpDic[@"RoomId"],
                                @"UserID":tmpDic[@"UserID"],
                            };
                            [tmpArr addObject:dic];
                        }
                    }
                    
                    
                }
                
                success(tmpArr);
            } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
                failure(reason,error);
            }];
        }
        else
        {
            success(@[]);
        }
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)getProductsConfigWithProductIds:(NSArray *)productIds success:(SRHandler)success failure:(FRHandler)failure
{
    if (productIds == nil) {
        failure(@"productIds参数为空",nil);
        return;
    }
    
    NSDictionary *param = @{@"ProductIds":productIds};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetProductsConfig params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)getProductsWithProductIds:(NSArray *)productIds success:(SRHandler)success failure:(FRHandler)failure
{
    if (productIds == nil) {
        failure(@"productIds参数为空",nil);
        return;
    }
    
    NSDictionary *param = @{@"ProductIds":productIds};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetProducts params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)getDeviceDataWithProductId:(NSString *)productId deviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    NSDictionary *param = @{@"ProductId":productId,@"DeviceName":deviceName};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetDeviceData params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}


- (void)getDeviceDetailWithProductId:(NSString *)productId deviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    [self getProductsConfigWithProductIds:@[productId] success:^(id  _Nonnull responseObject) {
        NSArray *data = responseObject[@"Data"];
        if (data.count > 0) {
            NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
            
            [self getProductsWithProductIds:@[productId] success:^(id  _Nonnull responseObject) {
                
                NSArray *tmpArr = responseObject[@"Products"];
                if (tmpArr.count > 0) {
                    NSString *DataTemplate = tmpArr.firstObject[@"DataTemplate"];
                    NSDictionary *DataTemplateDic = [NSString jsonToObject:DataTemplate];
                    
                    [self getDeviceDataWithProductId:productId deviceName:deviceName success:^(id  _Nonnull responseObject) {
                        
                        NSString *tmpStr = (NSString *)responseObject[@"Data"];
                        NSDictionary *tmpDic = [NSString jsonToObject:tmpStr];
                        DeviceInfo *set = [self zipData:config baseInfo:DataTemplateDic deviceData:tmpDic];
                        success(set);
                        
                    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
                        failure(reason,error);
                    }];
                    
                }
                
            } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
                failure(reason,error);
            }];
        }
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        failure(reason,error);
    }];
    
}

- (DeviceInfo *)zipData:(NSDictionary *)uiInfo baseInfo:(NSDictionary *)baseInfo deviceData:(NSDictionary *)deviceInfo
{
    NSDictionary *standard = uiInfo[@"Panel"][@"standard"];
    if (standard && baseInfo && deviceInfo) {
        
        DeviceInfo *obj = [[DeviceInfo alloc] init];
        
        obj.theme = standard[@"theme"];
        obj.navBar = standard[@"navBar"];
        obj.timingProject = [standard[@"timingProject"] boolValue];
        
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
            
        }
        
        [obj.zipData addObjectsFromArray:propertiesForUI];
        
        return obj;
    }
    return nil;
}

- (void)controlDeviceDataWithProductId:(NSString *)productId deviceName:(NSString *)deviceName data:(NSDictionary *)data success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    if (data == nil) {
        failure(@"data参数为空",nil);
        return;
    }
    
    NSDictionary *param = @{
        @"ProductId":productId,
        @"DeviceName":deviceName,
        @"Data":[NSString objectToJson:data],
    };
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppControlDeviceData params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)modifyAliasName:(NSString *)aliasName ByProductId:(NSString *)productId andDeviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    if (aliasName == nil) {
        failure(@"aliasName参数为空",nil);
        return;
    }
    
    NSDictionary *param = @{@"ProductID":productId,@"DeviceName":deviceName,@"AliasName":aliasName};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppUpdateDeviceInFamily params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}


- (void)deleteDeviceWithFamilyId:(NSString *)familyId productId:(NSString *)productId andDeviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure
{
    if (familyId == nil) {
        failure(@"familyId参数为空",nil);
        return;
    }
    
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    NSDictionary *param = @{@"FamilyId":familyId,@"ProductID":productId,@"DeviceName":deviceName};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppDeleteDeviceInFamily params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}


- (void)bindDeviceWithSignatureInfo:(NSString *)signatureInfo inFamilyId:(NSString *)familyId roomId:(NSString *)roomId success:(SRHandler)success failure:(FRHandler)failure
{
    if (signatureInfo == nil) {
        failure(@"signatureInfo参数为空",nil);
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil);
        return;
    }
    
    NSDictionary *deviceData = [NSObject base64Decode:signatureInfo];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"ProductId":deviceData[@"productId"],@"DeviceName":deviceData[@"deviceName"],@"TimeStamp":deviceData[@"timestamp"],@"ConnId":deviceData[@"connId"],@"Signature":deviceData[@"signature"],@"DeviceTimestamp":deviceData[@"timestamp"],@"FamilyId":familyId}];
    if (roomId && roomId.length > 0) {
        [param setValue:roomId forKey:@"RoomId"];
    }
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppSigBindDeviceInFamily params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)bindDeviceWithDeviceSignature:(NSString *)deviceSignature inFamilyId:(NSString *)familyId roomId:(NSString *)roomId success:(SRHandler)success failure:(FRHandler)failure
{
    if (deviceSignature == nil) {
        failure(@"deviceSignature参数为空",nil);
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil);
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"FamilyId":familyId,@"DeviceSignature":deviceSignature}];
    if (roomId && roomId.length > 0) {
        [param setValue:roomId forKey:@"RoomId"];
    }
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppSecureAddDeviceInFamily params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)modifyRoomOfDeviceWithProductId:(NSString *)productId deviceName:(NSString *)deviceName familyId:(NSString *)familyId roomId:(NSString *)roomId success:(SRHandler)success failure:(FRHandler)failure
{
    
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil);
        return;
    }
    
    if (roomId == nil) {
        failure(@"roomId参数为空",nil);
        return;
    }
    
    
    NSDictionary *param = @{@"ProductId":productId,@"DeviceName":deviceName,@"FamilyId": familyId,@"RoomId":roomId};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppModifyFamilyDeviceRoom params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}


#pragma mark - 云端定时


/// 获取定时器列表
- (void)getTimerListWithProductId:(NSString *)productId deviceName:(NSString *)deviceName offset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure
{
    
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:productId forKey:@"ProductId"];
    [param setValue:deviceName forKey:@"DeviceName"];
    if (limit > 0) {
        [param setObject:@(offset) forKey:@"Offset"];
        [param setObject:@(limit) forKey:@"Limit"];
    }
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppGetTimerList params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)createTimerWithProductId:(NSString *)productId deviceName:(NSString *)deviceName timerName:(NSString *)timerName days:(NSString *)days timePoint:(NSDate *)timePoint repeat:(NSUInteger)repeat data:(NSDictionary *)data success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    if (timerName == nil) {
        failure(@"timerName参数为空",nil);
        return;
    }
    if (days == nil) {
        failure(@"days参数为空",nil);
        return;
    }
    if (timePoint == nil) {
        failure(@"timePoint参数为空",nil);
        return;
    }
    if (repeat != 0 && repeat != 1) {
        failure(@"repeat参数取值为0或1",nil);
        return;
    }
    if (data == nil) {
        failure(@"data参数为空",nil);
        return;
    }
    
    NSString *tp = [NSString convertTimestampToTime:@([timePoint timeIntervalSince1970]) byDateFormat:@"HH:mm"];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:productId forKey:@"ProductId"];
    [param setValue:deviceName forKey:@"DeviceName"];
    [param setValue:timerName forKey:@"TimerName"];
    [param setValue:days forKey:@"Days"];
    [param setValue:tp forKey:@"TimePoint"];
    [param setValue:@(repeat) forKey:@"Repeat"];
    [param setValue:[NSString objectToJson:data] forKey:@"Data"];
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppCreateTimer params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)modifyTimerWithTimerId:(NSString *)timerId productId:(NSString *)productId deviceName:(NSString *)deviceName timerName:(NSString *)timerName days:(NSString *)days timePoint:(NSDate *)timePoint repeat:(NSUInteger)repeat data:(NSDictionary *)data success:(SRHandler)success failure:(FRHandler)failure
{
    if (timerId == nil) {
        failure(@"timerId参数为空",nil);
        return;
    }
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    if (timerName == nil) {
        failure(@"timerName参数为空",nil);
        return;
    }
    if (days == nil) {
        failure(@"days参数为空",nil);
        return;
    }
    if (timePoint == nil) {
        failure(@"timePoint参数为空",nil);
        return;
    }
    if (repeat != 0 || repeat != 1) {
        failure(@"repeat参数取值为0或1",nil);
        return;
    }
    if (data == nil) {
        failure(@"data参数为空",nil);
        return;
    }
    
    NSString *tp = [NSString convertTimestampToTime:@([timePoint timeIntervalSince1970]) byDateFormat:@"HH:mm"];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:timerId forKey:@"TimerId"];
    [param setValue:productId forKey:@"ProductId"];
    [param setValue:deviceName forKey:@"DeviceName"];
    [param setValue:timerName forKey:@"TimerName"];
    [param setValue:days forKey:@"Days"];
    [param setValue:tp forKey:@"TimePoint"];
    [param setValue:@(repeat) forKey:@"Repeat"];
    [param setValue:[NSString objectToJson:data] forKey:@"Data"];
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppModifyTimer params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)modifyTimerStatusWithTimerId:(NSString *)timerId productId:(NSString *)productId deviceName:(NSString *)deviceName status:(BOOL)status success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    if (timerId == nil) {
        failure(@"timerId参数为空",nil);
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:productId forKey:@"ProductId"];
    [dic setValue:deviceName forKey:@"DeviceName"];
    [dic setValue:timerId forKey:@"TimerId"];
    [dic setValue:@(status) forKey:@"Status"];
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppModifyTimerStatus params:dic useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

/// 删除定时器
- (void)deleteTimerWithProductId:(NSString *)productId deviceName:(NSString *)deviceName timerId:(NSString *)timerId success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    if (timerId == nil) {
        failure(@"timerId参数为空",nil);
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:productId forKey:@"ProductId"];
    [dic setValue:deviceName forKey:@"DeviceName"];
    [dic setValue:timerId forKey:@"TimerId"];
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppDeleteTimer params:dic useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}


#pragma mark - 设备分享

- (void)getUserListForDeviceWithProductId:(NSString *)productId deviceName:(NSString *)deviceName offset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:productId forKey:@"ProductId"];
    [param setValue:deviceName forKey:@"DeviceName"];
    if (limit > 0) {
        [param setObject:@(offset) forKey:@"Offset"];
        [param setObject:@(limit) forKey:@"Limit"];
    }
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppListShareDeviceUsers params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)getDeviceListForUserWithOffset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure
{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (limit > 0) {
        [param setObject:@(offset) forKey:@"Offset"];
        [param setObject:@(limit) forKey:@"Limit"];
    }
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppListUserShareDevices params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)removeShareDeviceUserWithProductId:(NSString *)productId deviceName:(NSString *)deviceName userID:(NSString *)userID success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    if (userID == nil) {
        failure(@"userID参数为空",nil);
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:userID forKey:@"RemoveUserID"];
    [param setValue:productId forKey:@"ProductId"];
    [param setValue:deviceName forKey:@"DeviceName"];
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppRemoveShareDeviceUser params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)removeUserShareDeviceWithProductId:(NSString *)productId deviceName:(NSString *)deviceName shareDeviceToken:(NSString *)shareDeviceToken success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    if (shareDeviceToken == nil) {
        failure(@"shareDeviceToken参数为空",nil);
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:shareDeviceToken forKey:@"ShareDeviceToken"];
    [param setValue:productId forKey:@"ProductId"];
    [param setValue:deviceName forKey:@"DeviceName"];
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppRemoveUserShareDevice params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)bindUserShareDeviceWithProductId:(NSString *)productId deviceName:(NSString *)deviceName shareDeviceToken:(NSString *)shareDeviceToken success:(SRHandler)success failure:(FRHandler)failure
{
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    
    if (shareDeviceToken == nil) {
        failure(@"shareDeviceToken参数为空",nil);
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:shareDeviceToken forKey:@"ShareDeviceToken"];
    [param setValue:productId forKey:@"ProductId"];
    [param setValue:deviceName forKey:@"DeviceName"];
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppBindUserShareDevice params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
}

- (void)sendInvitationToPhoneNum:(NSString *)phoneNum withCountryCode:(NSString *)countryCode familyId:(NSString *)familyId productId:(NSString *)productId deviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure
{
    if (phoneNum == nil) {
        failure(@"phoneNum参数为空",nil);
        return;
    }
    
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil);
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil);
        return;
    }
    
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    NSDictionary *param = @{@"Type":@"phone",@"CountryCode":countryCode,@"PhoneNumber":phoneNum};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppFindUser params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        NSDictionary *data = responseObject[@"Data"];
        NSString *userId = data[@"UserID"];
        
        NSDictionary *param = @{@"FamilyId":familyId,@"ProductId":productId,@"DeviceName":deviceName,@"ToUserID":userId};
        QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppSendShareDeviceInvite params:param useToken:YES];
        [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
            success(responseObject);
        } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
            failure(reason,error);
        }];
        
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}

- (void)sendInvitationToEmail:(NSString *)email withFamilyId:(NSString *)familyId productId:(NSString *)productId deviceName:(NSString *)deviceName success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil);
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil);
        return;
    }
    
    if (productId == nil) {
        failure(@"productId参数为空",nil);
        return;
    }
    
    if (deviceName == nil) {
        failure(@"deviceName参数为空",nil);
        return;
    }
    NSDictionary *param = @{@"Type":@"email",@"Email":email};
    
    QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppFindUser params:param useToken:YES];
    [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        NSDictionary *data = responseObject[@"Data"];
        NSString *userId = data[@"UserID"];
        
        NSDictionary *param = @{@"FamilyId":familyId,@"ProductId":productId,@"DeviceName":deviceName,@"ToUserID":userId};
        QCRequestBuilder *b = [[QCRequestBuilder alloc] initWtihAction:AppSendShareDeviceInvite params:param useToken:YES];
        [QCRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
            success(responseObject);
        } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
            failure(reason,error);
        }];
        
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error) {
        failure(reason,error);
    }];
    
}


@end
