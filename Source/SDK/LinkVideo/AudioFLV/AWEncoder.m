<<<<<<< HEAD   (204be9 修复使用DDLog库后，内存及时不释放问题)
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
=======
>>>>>>> CHANGE (516ba1 添加采集音频+视频+合成flv)
