//
//  TIoTDemoDateTool.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/1.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDemoDateTool : NSObject
/// 获取Date转农历日期
+ (NSString*)getLunarCalendarWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;

@end

NS_ASSUME_NONNULL_END
