//
//  TIoTCloudStorageDayTimeListModel.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TIoTCloudStorageTimeDataModel;

@interface TIoTCloudStorageDayTimeListModel : NSObject
@property (nonatomic, copy) NSString *VideoURL;
@property (nonatomic, strong) NSArray <TIoTCloudStorageTimeDataModel*>*TimeList;
@end

@interface TIoTCloudStorageTimeDataModel : NSObject
@property (nonatomic, copy) NSString *StartTime;
@property (nonatomic, copy) NSString *EndTime;
@end

NS_ASSUME_NONNULL_END
