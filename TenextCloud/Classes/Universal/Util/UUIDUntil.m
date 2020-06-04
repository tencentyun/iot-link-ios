//
//  UUIDUntil.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/3/15.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "UUIDUntil.h"
#import "KeyChainUntil.h"
#import <AdSupport/AdSupport.h>
#import "sys/utsname.h"
#import "UIDevice+Until.h"

@implementation UUIDUntil
static NSString *_uuidString = @"";
static NSString *_uuidUnitlKeyChainKey = @"__TYZ_XDP_UUID_Unitl_Key_Chain_Key";

+ (void)becomeActived{
    
    if (_uuidString.length == 36) {
        return;
    }
    
    NSString *uuidString = [KeyChainUntil readKeychainValue:_uuidUnitlKeyChainKey];
    
    if (uuidString.length) {
        _uuidString = uuidString;
    }else{
        
        NSString *deviceString = [self deviceString];
        
        NSString *idfaString = [self idfaStirng];
        
        if (idfaString.length ) {
            _uuidString = [NSString stringWithFormat:@"%@%@",deviceString,[idfaString substringFromIndex:4]];
        }else{
            NSString *uuidString = [NSUUID UUID].UUIDString;
            _uuidString = [NSString stringWithFormat:@"%@%@",deviceString,[uuidString substringFromIndex:4]];
        }
        
        [KeyChainUntil saveKeychainValue:_uuidString key:_uuidUnitlKeyChainKey];
    }
    
}

+ (NSString *)uuidString{
    return _uuidString;
}

+ (NSString *)idfaStirng{
    
    ASIdentifierManager *asIM = [[ASIdentifierManager alloc] init];
 
    if (!asIM.advertisingTrackingEnabled) {
        return @"";
    }
    
    return asIM.advertisingIdentifier.UUIDString;
  
}

+ (NSString *)deviceString{
    
    
    NSString *deviceModel = [UIDevice deviceModel];
    NSString *name = [UIDevice name];
    NSString *resolution = [UIDevice resolution];
    NSString *countofCores = [UIDevice countofCores];
    
    unsigned long deviceModelLong = 0;
    if (deviceModel != nil && ![@"" isEqualToString:deviceModel]) {
        deviceModelLong = deviceModel.hash % 10;
    }
    unsigned long nameLong = 0;
    if (name != nil && ![@"" isEqualToString:name]) {
        nameLong = name.hash % 10;
    }
    unsigned long resolutionLong = 0;
    if (resolution != nil && ![@"" isEqualToString:resolution]) {
        resolutionLong = resolution.hash % 10;
    }
    unsigned long countofCoresLong = 0;
    if (countofCores != nil && ![@"" isEqualToString:countofCores]) {
        countofCoresLong = countofCores.hash % 10;
    }

    
    return [NSString stringWithFormat:@"%lu%lu%lu%lu",deviceModelLong,nameLong,resolutionLong,countofCoresLong];
}


@end
