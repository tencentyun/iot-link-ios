//
//  TIoTDemoLocalDayTimeListModel.h
//  LinkApp
//

#import <Foundation/Foundation.h>

/**
 本地回放某一天时间查询ListModel
 */
NS_ASSUME_NONNULL_BEGIN

@class TIoTDemoLocalTimeDateModel;
@class TIoTDemoLocalFileModel;

@interface TIoTDemoLocalDayTimeListModel : NSObject
@property (nonatomic, strong) NSArray <TIoTDemoLocalTimeDateModel*> *video_list;
@end

/**
 每段时间
 */
@interface TIoTDemoLocalTimeDateModel : NSObject
@property (nonatomic, copy)NSString *start_time;
@property (nonatomic, copy)NSString *end_time;
@end






@interface TIoTDemoLocalDayFileListModel : NSObject
@property (nonatomic, strong) NSArray <TIoTDemoLocalFileModel*> *file_list;
@end

/**
 每段时间
 */
@interface TIoTDemoLocalFileModel : NSObject
@property (nonatomic, copy)NSString *file_type;
@property (nonatomic, copy)NSString *file_name;
@property (nonatomic, copy)NSString *file_size;
@property (nonatomic, copy)NSString *start_time;
@property (nonatomic, copy)NSString *end_time;
@property (nonatomic, copy)NSDictionary *extra_info;
@end

NS_ASSUME_NONNULL_END
