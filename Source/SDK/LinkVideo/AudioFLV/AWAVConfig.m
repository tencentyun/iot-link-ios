#import "AWAVConfig.h"

@implementation AWAudioConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bitrate = 100000;
        self.channelCount = 1;
        self.sampleSize = 16;
        self.sampleRate = 44100;
    }
    return self;
}

-(aw_faac_config)faacConfig{
    aw_faac_config faac_config;
    faac_config.bitrate = (int32_t)self.bitrate;
    faac_config.channel_count = (int32_t)self.channelCount;
    faac_config.sample_rate = (int32_t)self.sampleRate;
    faac_config.sample_size = (int32_t)self.sampleSize;
    return faac_config;
}

-(id)copyWithZone:(NSZone *)zone{
    AWAudioConfig *audioConfig = [[AWAudioConfig alloc] init];
    audioConfig.bitrate = self.bitrate;
    audioConfig.channelCount = self.channelCount;
    audioConfig.sampleRate = self.sampleRate;
    audioConfig.sampleSize = self.sampleSize;
    return audioConfig;
}

@end
