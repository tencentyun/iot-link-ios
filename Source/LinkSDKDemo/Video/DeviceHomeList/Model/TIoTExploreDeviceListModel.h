//
//  TIoTExploreDeviceListModel.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>
#import "TIoTExploreOrVideoDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TIoTExploreDeviceModel;

@interface TIoTExploreDeviceListModel : NSObject
@property (nonatomic, strong) NSArray <TIoTExploreOrVideoDeviceModel *> * Devices;
@property (nonatomic, assign) NSInteger Total;
@end

@interface TIoTExploreDeviceModel: NSObject
@end


NS_ASSUME_NONNULL_END
