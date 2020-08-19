//
//  XDPAppEnvironment.h
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/4/2.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIoTCoreAppEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTAppEnvironment : NSObject

+ (instancetype)shareEnvironment;

- (void)selectEnvironmentType;

- (void)loginOut;

@end

NS_ASSUME_NONNULL_END
