
#import "AWEncoderManager.h"
#import "AWHWAACEncoder.h"
#import "AWHWH264Encoder.h"

@interface AWEncoderManager()
//编码器
@property (nonatomic, strong) AWVideoEncoder *videoEncoder;
@property (nonatomic, strong) AWAudioEncoder *audioEncoder;
@end

@implementation AWEncoderManager

-(void) openWithAudioConfig:(AWAudioConfig *) audioConfig videoConfig:(AWVideoConfig *) videoConfig{
    if (videoConfig) {
        self.videoEncoder = [[AWHWH264Encoder alloc] init];
        self.videoEncoder.videoConfig = videoConfig;
        self.videoEncoder.manager = self;
        [self.videoEncoder open];
    }
    
    if (audioConfig) {
        self.audioEncoder = [[AWHWAACEncoder alloc] init];
        self.audioEncoder.audioConfig = audioConfig;
        self.audioEncoder.manager = self;
        [self.audioEncoder open];
    }
}

-(void)close{
    
    if (self.videoEncoder) {
        [self.videoEncoder close];
        self.videoEncoder = nil;
        self.videoEncoder = AWVideoEncoderTypeNone;
    }
    if (self.audioEncoder) {
        [self.audioEncoder close];
        self.audioEncoder = nil;
        self.audioEncoder = AWAudioEncoderTypeNone;
    }
    self.timestamp = 0;
}

@end
