//
//  TIoTDemoLocalDayTimeListModel.m
//  LinkApp
//

#import "TIoTDemoLocalDayTimeListModel.h"

@implementation TIoTDemoLocalDayTimeListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"video_list":[TIoTDemoLocalTimeDateModel class],
    };
}
@end

@implementation TIoTDemoLocalTimeDateModel

@end



@implementation TIoTDemoLocalDayFileListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"file_list":[TIoTDemoLocalFileModel class],
    };
}
@end

@implementation TIoTDemoLocalFileModel
@end
