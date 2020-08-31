//
//  TIoTUserRegionModel.h
//  LinkApp
//
//  Created by ccharlesren on 2020/8/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTConfigModel;
@interface TIoTUserRegionModel : NSObject
@property (nonatomic, strong) NSArray <TIoTConfigModel *> *Configs;

@end

@interface TIoTConfigModel : NSObject
@property (nonatomic, copy) NSString *Key;      //中文 RegionListCN  英文 RegionListEN
@property (nonatomic, copy) NSString *Value;    //文本字符转
@end

@interface TIoTTimeZoneListModel : NSObject
@property (nonatomic, copy) NSString *TZ;       //时区
@property (nonatomic, copy) NSString *Title;    //城市
@end

@interface TIoTRegionModel: NSObject
@property (nonatomic, copy) NSString *CountryCode;  // 中国大陆 86 美国 1
@property (nonatomic, copy) NSString *Region;       // 中国 ap-guangzhou  美东 na-ashburn
@property (nonatomic, copy) NSString *RegionID;     // 中国 RegionID 1   美东 RegionID 22
@property (nonatomic, copy) NSString *Title;        // 区域名称
@property (nonatomic, copy) NSString *TitleEN;      // Chinese Mainland  U.S.A
@end

NS_ASSUME_NONNULL_END
