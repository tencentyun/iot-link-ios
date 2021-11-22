
#import "AWEncoder.h"

@implementation AWEncoder

-(void) open{
}

-(void)close{
}

-(void) onErrorWithCode:(AWEncoderErrorCode) code des:(NSString *) des{
    aw_log("[ERROR] encoder error code:%ld des:%s", (unsigned long)code, des.UTF8String);
}

@end
