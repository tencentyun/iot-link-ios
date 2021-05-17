//
//  TIoTCloudStorageDateModel.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/17.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTCloudStorageDateListModel;
@interface TIoTCloudStorageDateModel : NSObject
@property (nonatomic, strong) NSArray <TIoTCloudStorageDateListModel *>*Data;
@end

@interface TIoTCloudStorageDateListModel : NSObject

@end

NS_ASSUME_NONNULL_END
