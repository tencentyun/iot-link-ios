//
//  WCDeviceData.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/23.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIoTDeviceData : NSObject

+(instancetype)shared;

@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *aliasName;

@property (nonatomic, copy) NSDictionary *productDic;
@property (nonatomic, copy) NSDictionary *dataTemplateDic;
@property (nonatomic, copy) NSDictionary *profileDic;
@property (nonatomic, copy) NSDictionary *deviceDataDic;
@property (nonatomic, strong) NSMutableArray *propertiesArr;


- (void)handleAllPropertyData:(NSDictionary *)propertyData deviceData:(NSDictionary *)deviceData;

- (void)handleReportDevice:(NSDictionary *)reportDevice;

- (void)deallocDeviceData;

@property (nonatomic,copy) NSString *theme;
@property (nonatomic,copy) NSString *bgImgId;
@property (nonatomic,copy) NSDictionary *navBar;
@property (nonatomic,strong) NSMutableArray *properties;//除去大按钮的数据
@property (nonatomic,strong) NSMutableDictionary *bigProp;//大按钮数据
@property (nonatomic,strong) NSMutableArray *allProperties;//所有数据
@property (nonatomic,assign) BOOL timingProject;

- (void)zipData:(NSDictionary *)uiInfo baseInfo:(NSDictionary *)baseInfo deviceData:(NSDictionary *)deviceInfo;

@end
