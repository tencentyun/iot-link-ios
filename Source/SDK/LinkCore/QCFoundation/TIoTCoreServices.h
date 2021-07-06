//
//  QCApiConfiguration.h
//  QCApiClient
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface TIoTCoreServices : NSObject

+ (instancetype)shared;

- (void)setAppKey:(NSString *)appkey;


/// appKey
@property (nonatomic , copy, readonly) NSString *appKey;


/// 打印开关
@property (nonatomic, assign) BOOL logEnable;

@end

NS_ASSUME_NONNULL_END
