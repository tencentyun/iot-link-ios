<<<<<<< HEAD   (204be9 修复使用DDLog库后，内存及时不释放问题)
#import "AWEncoderManager.h"
#import "AWHWAACEncoder.h"
#import "AWSWFaacEncoder.h"

@interface AWEncoderManager()
//编码器
@property (nonatomic, strong) AWAudioEncoder *audioEncoder;
@end

@implementation AWEncoderManager

-(void) openWithAudioConfig:(AWAudioConfig *) audioConfig {
    switch (self.audioEncoderType) {
        case AWAudioEncoderTypeHWAACLC:
            self.audioEncoder = [[AWHWAACEncoder alloc] init];
            break;
        case AWAudioEncoderTypeSWFAAC:
            self.audioEncoder = [[AWSWFaacEncoder alloc] init];
            break;
        default:
            NSLog(@"[E] AWEncoderManager.open please assin for audioEncoderType");
            return;
    }
    
    self.audioEncoder.audioConfig = audioConfig;
    self.audioEncoder.manager = self;
    [self.audioEncoder open];
}

-(void)close{
    [self.audioEncoder close];
    self.audioEncoder = nil;
    
    self.timestamp = 0;
    
    self.audioEncoder = nil;
}

@end
=======
>>>>>>> CHANGE (516ba1 添加采集音频+视频+合成flv)
