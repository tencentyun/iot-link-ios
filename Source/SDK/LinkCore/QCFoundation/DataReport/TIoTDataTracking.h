//
//  QCRequestClient.h
//  QCApiClient
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDataTracking : NSObject

+ (void)logEvent:(NSString *)eventName params:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
