//
//  TIoTPlayBackListModel.h
//  LinkApp
//
//  Created by ccharlesren on 2021/1/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTPlayBackModel;

@interface TIoTPlayBackListModel : NSObject
@property (nonatomic, copy) NSString *file_name;
@property (nonatomic, copy) NSString *start_time;
@property (nonatomic, copy) NSString *end_time;
@end

NS_ASSUME_NONNULL_END
