//
//  NSTimer+BlockSupport.m
//  SEEXiaodianpu
//
//

#import "NSTimer+BlockSupport.h"

@implementation NSTimer (BlockSupport)

+ (instancetype)xdp_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)(void))block repeats:(BOOL)repeats{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(ych_blockInvoke:) userInfo:[block copy] repeats:repeats];
}


+ (void)ych_blockInvoke:(NSTimer *)timer{
    void (^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}

@end
