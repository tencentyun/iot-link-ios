//
//  TIoTDemoCalendarCustomView.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDemoCalendarCustomView : UIView
@property (nonatomic, strong, readonly) NSString *dayDateString;


/// 日历数组 item:@"2021-1-1"
@property (nonatomic, strong) NSArray <NSString *>*calendarDateArray;
@end

NS_ASSUME_NONNULL_END
