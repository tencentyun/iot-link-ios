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
@property (nonatomic, copy) NSString *VideoURL;
@property (nonatomic, assign) BOOL Listover;
@property (nonatomic, copy) NSString *Context;
@end

@interface TIoTDemoCloudEventModel : NSObject
@property (nonatomic, copy) NSString *StartTime;
@property (nonatomic, copy) NSString *EndTime;
@property (nonatomic, copy) NSString *Thumbnail;
@property (nonatomic, copy) NSString *EventId;

@property (nonatomic, copy) NSString *ThumbnailURL; //Thumbnail 请求单独接口后获取的完整URL缩略图
@end

NS_ASSUME_NONNULL_END
