//
//  TIoTPlayBackListModel.h
//  LinkApp
//
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
