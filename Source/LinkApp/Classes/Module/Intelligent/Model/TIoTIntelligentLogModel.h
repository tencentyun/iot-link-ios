//
//  TIoTIntelligentLogModel.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/24.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTLogMsgsModel;
@class TIoTActionResultsModel;

@interface TIoTIntelligentLogModel : NSObject
@property (nonatomic, assign) NSInteger Listover;
@property (nonatomic, strong) NSArray <TIoTLogMsgsModel *> *Msgs;
@end

@interface TIoTLogMsgsModel : NSObject
@property (nonatomic, copy) NSString *AutomationId;//成功会返回
@property (nonatomic, copy) NSString *AutomationName;//成功会返回
@property (nonatomic, copy) NSString *SceneId;//失败会返回
@property (nonatomic, copy) NSString *SceneName;//失败会返回
@property (nonatomic, copy) NSString *FamilyId;
@property (nonatomic, copy) NSString *UserId;
@property (nonatomic, copy) NSString *Result;
@property (nonatomic, assign) NSInteger ResultCode; 
@property (nonatomic, copy) NSString *CreateAt;
@property (nonatomic, copy) NSString *MsgId;
@property (nonatomic, strong) NSArray <TIoTActionResultsModel *> *ActionResults;
@end

@interface TIoTActionResultsModel : NSObject
@property (nonatomic, copy) NSString *DeviceId;
@property (nonatomic, copy) NSString *Result;
@end

NS_ASSUME_NONNULL_END
