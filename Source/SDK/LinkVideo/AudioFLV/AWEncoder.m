#import "AWEncoder.h"

@implementation AWEncoder

-(void) open{
}

-(void)close{
}

-(void) onErrorWithCode:(AWEncoderErrorCode) code des:(NSString *) des{
    NSLog(@"[ERROR] encoder error code:%ld des:%s", (unsigned long)code, des.UTF8String);
}

@end
