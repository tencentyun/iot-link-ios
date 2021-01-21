#import "AWEncoder.h"

@interface AWAudioEncoder : AWEncoder

@property (nonatomic, copy) AWAudioConfig *audioConfig;
//编码
-(aw_flv_audio_tag *) encodePCMDataToFlvTag:(NSData *)pcmData;

-(aw_flv_audio_tag *) encodeAudioSampleBufToFlvTag:(CMSampleBufferRef)audioSample;

//创建 audio specific config
-(aw_flv_audio_tag *) createAudioSpecificConfigFlvTag;

//转换
-(NSData *) convertAudioSmapleBufferToPcmData:(CMSampleBufferRef) audioSample;

@end
