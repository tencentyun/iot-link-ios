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

NS_ASSUME_NONNULL_END
