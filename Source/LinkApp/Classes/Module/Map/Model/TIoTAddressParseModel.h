//
//  TIoTAddressParseModel.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>
#import "TIoTMapLocationModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TIoTLocationModel;
@class TIoTADInfoModel;
@class TIoTAddressComponentModel;
@interface TIoTAddressParseModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) TIoTLocationModel *location;
@property (nonatomic, strong) TIoTADInfoModel *ad_info;
@property (nonatomic, strong) TIoTAddressComponentModel *address_components;
@property (nonatomic, copy) NSString *similarity;
@property (nonatomic, copy) NSString *deviation;
@property (nonatomic, copy) NSString *reliability;
@property (nonatomic, copy) NSString *level;
@end

NS_ASSUME_NONNULL_END
