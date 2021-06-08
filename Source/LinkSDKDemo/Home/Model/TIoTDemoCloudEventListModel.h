//
//  TIoTDemoCloudEventListModel.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTDemoCloudEventModel;

@interface TIoTDemoCloudEventListModel : NSObject
@property (nonatomic, strong) NSArray <TIoTDemoCloudEventModel *>*Events;
@end

@interface TIoTDemoCloudEventModel : NSObject
@property (nonatomic, copy) NSString *StartTime;
@property (nonatomic, copy) NSString *EndTime;
@property (nonatomic, copy) NSString *Thumbnail;
@property (nonatomic, copy) NSString *EventId;
@end

NS_ASSUME_NONNULL_END
