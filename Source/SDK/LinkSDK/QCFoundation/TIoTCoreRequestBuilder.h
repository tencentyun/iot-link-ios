//
//  QCRequestBuilder.h
//  QCApiClient
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreRequestBuilder : NSObject

- (instancetype)initWtihAction:(NSString *)action params:(NSDictionary *)params useToken:(BOOL)useToken;

@property (nonatomic, strong, readonly) NSDictionary *build;

@end

NS_ASSUME_NONNULL_END
