//
//  TIoTUserRegionModel.h
//  LinkApp
//
//  Created by ccharlesren on 2020/8/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTConfigModel;
@interface TIoTUserRegionModel : NSObject
@property (nonatomic, strong) NSArray <TIoTConfigModel *> *Configs;

@end

@class TIoTReginListModel;
@interface TIoTConfigModel : NSObject
@property (nonatomic, copy) NSString *Key;
@property (nonatomic, copy) NSString *Value;
@end

@interface TIoTReginListModel : NSObject
@property (nonatomic, copy) NSString *TZ;
@property (nonatomic, copy) NSString *Title;

@end

NS_ASSUME_NONNULL_END
