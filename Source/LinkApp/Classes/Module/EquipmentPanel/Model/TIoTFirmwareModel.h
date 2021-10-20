//
//  TIoTFirmwareModel.h
//  LinkApp
//
//  Created by ccharlesren on 2021/10/20.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTFirmwareModel : NSObject
@property (nonatomic, copy) NSString *CurrentVersion;
@property (nonatomic, copy) NSString *DstVersion;
@end

NS_ASSUME_NONNULL_END
