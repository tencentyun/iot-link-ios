//
//  TIoTCoreLogger.h
//  TIoTLinkVideo

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreLogger : NSObject
@property (nonatomic, strong)NSString *appuuid;
@property (nonatomic, strong)NSString *version;

- (void)startLogging;
//- (void)stopLogging;
- (void)addLog:(NSString *)message;
//- (void)reportLog;

@end

NS_ASSUME_NONNULL_END
