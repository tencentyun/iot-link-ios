//
//  WCRequestObj.h
//  TenextCloud
//
//

#import <Foundation/Foundation.h>
#import "TIoTCoreSocketCover.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreRequestObj : NSObject
@property (nonatomic, unsafe_unretained) NSUInteger reqId;
@property (nonatomic) didReceiveMessage sucess;
@end

NS_ASSUME_NONNULL_END
