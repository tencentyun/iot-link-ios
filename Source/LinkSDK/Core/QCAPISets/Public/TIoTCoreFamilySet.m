//
//  QCFamilyManager.m
//  QCAccount
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "TIoTCoreFamilySet.h"
#import "TIoTCoreRequestAction.h"
#import "TIoTCoreFoundation.h"
//#import <QCFoundation/TIoTCoreFoundation.h>

@implementation TIoTCoreFamilySet

+ (instancetype)shared
{
    static TIoTCoreFamilySet *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


- (void)getFamilyListWithOffset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure
{
    NSDictionary *param = @{};
    if (limit > 0) {
        param = @{@"Offset":@(offset),@"Limit":@(limit)};
    }
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppGetFamilyList params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary * dic) {
        failure(reason,error,dic);
    }];
}

- (void)createFamilyWithName:(NSString *)name address:(NSString *)address success:(SRHandler)success failure:(FRHandler)failure
{
    if (name == nil) {
        failure(@"name参数为空",nil,@{});
        return;
    }
    
    if (address == nil) {
        failure(@"address参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"Name":name,@"Address":address};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppCreateFamily params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}


- (void)getFamilyInfoWithFamilyId:(NSString *)familyId success:(SRHandler)success failure:(FRHandler)failure
{
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"FamilyId":familyId};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppDescribeFamily params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)modifyFamilyWithFamilyId:(NSString *)familyId name:(NSString *)name success:(SRHandler)success failure:(FRHandler)failure
{
    if (name == nil) {
        failure(@"name参数为空",nil,@{});
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"FamilyId":familyId,@"Name":name};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppModifyFamily params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)deleteFamilyWithFamilyId:(NSString *)familyId name:(NSString *)name success:(SRHandler)success failure:(FRHandler)failure
{
    if (name == nil) {
        failure(@"name参数为空",nil,@{});
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"FamilyId":familyId,@"Name":name};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppDeleteFamily params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)leaveFamilyWithFamilyId:(NSString *)familyId success:(SRHandler)success failure:(FRHandler)failure
{
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"FamilyId":familyId};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppExitFamily params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)deleteFamilyMemberWithFamilyId:(NSString *)familyId memberId:(NSString *)memberId success:(SRHandler)success failure:(FRHandler)failure
{
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    if (memberId == nil) {
        failure(@"memberId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"MemberID":memberId,@"FamilyId":familyId};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppDeleteFamilyMember params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)getMemberListWithFamilyId:(NSString *)familyId offset:(NSUInteger)offset limit:(NSUInteger)limit success:(SRHandler)success failure:(FRHandler)failure
{
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:familyId forKey:@"FamilyId"];
    if (limit > 0) {
        [param setObject:@(offset) forKey:@"Offset"];
        [param setObject:@(limit) forKey:@"Limit"];
    }
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppGetFamilyMemberList params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}

- (void)getRoomListWithFamilyId:(NSString *)familyId offset:(NSUInteger)offset limit:(NSUInteger)limit  success:(SRHandler)success failure:(FRHandler)failure
{
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:familyId forKey:@"FamilyId"];
    if (limit > 0) {
        [param setObject:@(offset) forKey:@"Offset"];
        [param setObject:@(limit) forKey:@"Limit"];
    }
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppGetRoomList params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}

- (void)createRoomWithFamilyId:(NSString *)familyId name:(NSString *)name success:(SRHandler)success failure:(FRHandler)failure
{
    if (name == nil) {
        failure(@"name参数为空",nil,@{});
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"FamilyId":familyId,@"Name":name};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppCreateRoom params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}

- (void)deleteRoomWithFamilyId:(NSString *)familyId roomId:(NSString *)roomId success:(SRHandler)success failure:(FRHandler)failure
{
    if (roomId == nil) {
        failure(@"roomId参数为空",nil,@{});
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"FamilyId":familyId,@"RoomId":roomId};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppDeleteRoom params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}

- (void)modifyRoomWithFamilyId:(NSString *)familyId roomId:(NSString *)roomId name:(NSString *)name success:(SRHandler)success failure:(FRHandler)failure
{
    if (roomId == nil) {
        failure(@"roomId参数为空",nil,@{});
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    if (name == nil) {
        failure(@"name参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"FamilyId":familyId,@"RoomId":roomId,@"Name":name};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppModifyRoom params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}

- (void)sendInvitationToPhoneNum:(NSString *)phoneNum withCountryCode:(NSString *)countryCode familyId:(NSString *)familyId success:(SRHandler)success failure:(FRHandler)failure
{
    if (phoneNum == nil) {
        failure(@"phoneNum参数为空",nil,@{});
        return;
    }
    
    if (countryCode == nil) {
        failure(@"countryCode参数为空",nil,@{});
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"Type":@"phone",@"CountryCode":countryCode,@"PhoneNumber":phoneNum};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppFindUser params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        NSDictionary *data = responseObject[@"Data"];
        NSString *userId = data[@"UserID"];
        
        NSDictionary *param = @{@"FamilyId":familyId,@"ToUserID":userId};
        TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppSendShareFamilyInvite params:param useToken:YES];
        [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
            success(responseObject);
        } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
            failure(reason,error,dic);
        }];
        
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary * dic) {
        failure(reason,error,dic);
    }];
    
}

- (void)sendInvitationToEmail:(NSString *)email withFamilyId:(NSString *)familyId success:(SRHandler)success failure:(FRHandler)failure
{
    if (email == nil) {
        failure(@"email参数为空",nil,@{});
        return;
    }
    
    if (familyId == nil) {
        failure(@"familyId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"Type":@"email",@"Email":email};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppFindUser params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        NSDictionary *data = responseObject[@"Data"];
        NSString *userId = data[@"UserID"];
        
        NSDictionary *param = @{@"FamilyId":familyId,@"ToUserID":userId};
        TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppSendShareFamilyInvite params:param useToken:YES];
        [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
            success(responseObject);
        } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
            failure(reason,error,dic);
        }];
        
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
    
}

- (void)joinFamilyWithShareToken:(NSString *)shareToken success:(SRHandler)success failure:(FRHandler)failure
{
    if (shareToken == nil) {
        failure(@"shareToken参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"ShareToken":shareToken};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppJoinFamily params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

@end
