//
//  TIoTMapLocationModel.h
//  LinkApp
//
//  Created by ccharlesren on 2021/3/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTLocationModel;
@class TIoTAddressModel;
@class TIoTAddressComponentModel;
@class TIoTADInfoModel;
@class TIoTPoisModel;
@interface TIoTMapLocationModel : NSObject

@property (nonatomic, strong) TIoTLocationModel *location;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, strong) TIoTAddressModel *formatted_addresses;
@property (nonatomic, strong) TIoTAddressComponentModel *address_component;
@property (nonatomic, strong) TIoTADInfoModel *ad_info;
@property (nonatomic, copy) NSString *poi_count;
@property (nonatomic, strong) NSArray <TIoTPoisModel *>*pois;
@property (nonatomic, strong) NSArray <TIoTPoisModel *>*data;
@property (nonatomic, copy) NSString *count;
@end


@interface TIoTLocationModel : NSObject
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lng;
@end

@interface TIoTAddressModel : NSObject
@property (nonatomic, copy) NSString *recommend;
@property (nonatomic, copy) NSString *rough;
@end

@interface TIoTAddressComponentModel : NSObject
@property (nonatomic, copy) NSString *nation;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *street_number;
@end


@interface TIoTADInfoModel : NSObject
@property (nonatomic, copy) NSString *nation_code;
@property (nonatomic, copy) NSString *adcode;
@property (nonatomic, copy) NSString *city_code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) TIoTLocationModel *location;
@property (nonatomic, copy) NSString *nation;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@end

@interface TIoTPoisModel : NSObject
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, strong) TIoTLocationModel *location;
@property (nonatomic, strong) TIoTADInfoModel *ad_info;
@property (nonatomic, copy) NSString *_distance;
@property (nonatomic, copy) NSString *_dir_desc;
//关键字输入提示
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *adcode;
@property (nonatomic, copy) NSString *type;
@end

NS_ASSUME_NONNULL_END
