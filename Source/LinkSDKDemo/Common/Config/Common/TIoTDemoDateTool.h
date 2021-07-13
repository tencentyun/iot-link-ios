//
//  TIoTDemoDateTool.h
//  LinkSDKDemo
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDemoDateTool : NSObject
/// 获取Date转农历日期
+ (NSString*)getLunarCalendarWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;

@end

NS_ASSUME_NONNULL_END
