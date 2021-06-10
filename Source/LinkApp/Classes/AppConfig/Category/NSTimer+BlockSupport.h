//
//  NSTimer+BlockSupport.h
//  SEEXiaodianpu
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (BlockSupport)

+ (instancetype)xdp_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)(void))block repeats:(BOOL)repeats;

@end

NS_ASSUME_NONNULL_END
