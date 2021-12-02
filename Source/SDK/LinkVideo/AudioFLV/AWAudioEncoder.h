<<<<<<< HEAD   (204be9 修复使用DDLog库后，内存及时不释放问题)
#import "AWEncoder.h"

@interface AWAudioEncoder : AWEncoder

@property (nonatomic, copy) AWAudioConfig *audioConfig;
//编码
-(aw_flv_audio_tag *) encodePCMDataToFlvTag:(NSData *)pcmData;

-(aw_flv_audio_tag *) encodeAACDataToFlvTag:(NSData *)aacData;

-(aw_flv_audio_tag *) encodeAudioSampleBufToFlvTag:(CMSampleBufferRef)audioSample;

//创建 audio specific config
-(aw_flv_audio_tag *) createAudioSpecificConfigFlvTag;

//转换
-(NSData *) convertAudioSmapleBufferToPcmData:(CMSampleBufferRef) audioSample;

@end
=======
>>>>>>> CHANGE (516ba1 添加采集音频+视频+合成flv)
