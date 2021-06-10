//
//  XDPAppEnvironment.h
//  SEEXiaodianpu
//
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
