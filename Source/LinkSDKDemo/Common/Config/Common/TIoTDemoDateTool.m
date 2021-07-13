//
//  TIoTDemoDateTool.m
//  LinkSDKDemo
//
//

#import "TIoTDemoDateTool.h"

@implementation TIoTDemoDateTool

+ (NSString*)getLunarCalendarWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year {
    
    NSArray *lunarDaysArray = @[@"初一", @"初二", @"初三", @"初四", @"初五",
                                @"初六", @"初七", @"初八", @"初九", @"初十",
                                @"十一", @"十二", @"十三", @"十四", @"十五",
                                @"十六", @"十七", @"十八", @"十九", @"二十",
                                @"廿一", @"廿二", @"廿三", @"廿四", @"廿五",
                                @"廿六", @"廿七", @"廿八", @"廿九", @"三十",];
    
    NSString *tempstring = @"";
    
    if(month < 10) {
        if (day < 10) {
            tempstring = [NSString stringWithFormat:@"%ld0%ld0%ld",year,month,day];
        }
        else{
            tempstring = [NSString stringWithFormat:@"%ld0%ld%ld",year,month,day];
        }
    } else {
        if (day < 10) {
            tempstring = [NSString stringWithFormat:@"%ld%ld0%ld",year,month,day];
        }
        else{
            tempstring = [NSString stringWithFormat:@"%ld%ld%ld",year,month,day];
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *date = [dateFormatter dateFromString:tempstring];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    NSUInteger unit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *dateComp = [calendar components:unit fromDate:date];
    NSString *resuleString = [lunarDaysArray objectAtIndex:dateComp.day-1];
    return resuleString;
}

@end
