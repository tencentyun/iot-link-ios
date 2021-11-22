
#import "AWHWAACEncoder.h"
#import <VideoToolbox/VideoToolbox.h>
#import "AWEncoderManager.h"

@interface AWHWAACEncoder()
//audio params
@property (nonatomic, strong) NSData *curFramePcmData;

@property (nonatomic, unsafe_unretained) AudioConverterRef aConverter;
@property (nonatomic, unsafe_unretained) uint32_t aMaxOutputFrameSize;

@property (nonatomic, unsafe_unretained) aw_faac_config faacConfig;
@end

@implementation AWHWAACEncoder

static OSStatus aacEncodeInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData){
    AWHWAACEncoder *hwAacEncoder = (__bridge AWHWAACEncoder *)inUserData;
    if (hwAacEncoder.curFramePcmData) {
        ioData->mBuffers[0].mData = (void *)hwAacEncoder.curFramePcmData.bytes;
        ioData->mBuffers[0].mDataByteSize = (uint32_t)hwAacEncoder.curFramePcmData.length;
        ioData->mNumberBuffers = 1;
        ioData->mBuffers[0].mNumberChannels = (uint32_t)hwAacEncoder.audioConfig.channelCount;
        
        return noErr;
    }
    
    return -1;
}

-(aw_flv_audio_tag *)encodePCMDataToFlvTag:(NSData *)pcmData{
    self.curFramePcmData = pcmData;
    
    AudioBufferList outAudioBufferList = {0};
    outAudioBufferList.mNumberBuffers = 1;
    outAudioBufferList.mBuffers[0].mNumberChannels = (uint32_t)self.audioConfig.channelCount;
    outAudioBufferList.mBuffers[0].mDataByteSize = self.aMaxOutputFrameSize;
    outAudioBufferList.mBuffers[0].mData = malloc(self.aMaxOutputFrameSize);
    
    uint32_t outputDataPacketSize = 1;
    
    OSStatus status = AudioConverterFillComplexBuffer(_aConverter, aacEncodeInputDataProc, (__bridge void * _Nullable)(self), &outputDataPacketSize, &outAudioBufferList, NULL);
    if (status == noErr) {
        NSData *rawAAC = [NSData dataWithBytesNoCopy: outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
        self.manager.timestamp += 1024 * 1000 / self.audioConfig.sampleRate;
        
//        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
//            NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
//            NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
        
        return aw_encoder_create_audio_tag((int8_t *)rawAAC.bytes, rawAAC.length, (uint32_t)self.manager.timestamp, &_faacConfig);
    }else{
        [self onErrorWithCode:AWEncoderErrorCodeAudioEncoderFailed des:@"aac 编码错误"];
    }
    
    return NULL;
}

-(aw_flv_audio_tag *)encodeAACDataToFlvTag:(NSData *)aacData {
    
    self.manager.timestamp += 1024 * 1000 / self.audioConfig.sampleRate;
    int adts_header_size = 7;
    
    //除去ADTS头的7字节
//    if (aacData.length <= adts_header_size) {
//        return NULL;
//    }
    
    //除去ADTS头的7字节
//    aw_flv_audio_tag *audio_tag = aw_encoder_create_audio_tag((int8_t *)s_faac_ctx->encoded_aac_data->data + adts_header_size, s_faac_ctx->encoded_aac_data->size - adts_header_size, timestamp, &s_faac_ctx->config);
    return aw_encoder_create_audio_tag((int8_t *)aacData.bytes + adts_header_size, aacData.length - adts_header_size, (uint32_t)self.manager.timestamp, &_faacConfig);
//    return aw_encoder_create_audio_tag((int8_t *)aacData.bytes, aacData.length, (uint32_t)self.manager.timestamp, &_faacConfig);
}

-(aw_flv_audio_tag *)createAudioSpecificConfigFlvTag{
    uint8_t profile = kMPEG4Object_AAC_LC;
    uint8_t sampleRate = 4;
    if (self.audioConfig.sampleRate == 44100) {
        sampleRate = 4;
    }else if (self.audioConfig.sampleRate == 16000) {
        sampleRate = 8;
    }else if (self.audioConfig.sampleRate == 8000) {
        sampleRate = 11;
    }
/* 其中，samplingFreguencyIndex 对应关系如下：
    0 - 96000
    1 - 88200
    2 - 64000
    3 - 48000
    4 - 44100
    5 - 32000
    6 - 24000
    7 - 22050
    8 - 16000
    9 - 12000
    10 - 11025
    11 - 8000
    12 - 7350
    13 - Reserved
    14 - Reserved
    15 - frequency is written explictly
*/
    uint8_t chanCfg = 1;
    uint8_t config1 = (profile << 3) | ((sampleRate & 0xe) >> 1);
    uint8_t config2 = ((sampleRate & 0x1) << 7) | (chanCfg << 3);
    
    aw_data *config_data = NULL;
    data_writer.write_uint8(&config_data, config1);
    data_writer.write_uint8(&config_data, config2);
    
    aw_flv_audio_tag *audio_specific_config_tag = aw_encoder_create_audio_specific_config_tag(config_data, &_faacConfig);
    
    free_aw_data(&config_data);
    
    return audio_specific_config_tag;
}

-(void)open{
    _faacConfig = self.audioConfig.faacConfig;
    
//    //创建audio encode converter
//    AudioStreamBasicDescription inputAudioDes = {
//        .mFormatID = kAudioFormatLinearPCM,
//        .mSampleRate = self.audioConfig.sampleRate,
//        .mBitsPerChannel = (uint32_t)self.audioConfig.sampleSize,
//        .mFramesPerPacket = 1,
//        .mBytesPerFrame = 2,
//        .mBytesPerPacket = 2,
//        .mChannelsPerFrame = (uint32_t)self.audioConfig.channelCount,
//        .mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsNonInterleaved,
//        .mReserved = 0
//    };
//
//    AudioStreamBasicDescription outputAudioDes = {
//        .mChannelsPerFrame = (uint32_t)self.audioConfig.channelCount,
//        .mFormatID = kAudioFormatMPEG4AAC,
//        0
//    };
//
//    uint32_t outDesSize = sizeof(outputAudioDes);
//    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &outDesSize, &outputAudioDes);
//    OSStatus status = AudioConverterNew(&inputAudioDes, &outputAudioDes, &_aConverter);
//    if (status != noErr) {
//        [self onErrorWithCode:AWEncoderErrorCodeCreateAudioConverterFailed des:@"硬编码AAC创建失败"];
//    }
//
//    //设置码率
//    uint32_t aBitrate = (uint32_t)self.audioConfig.bitrate;
//    uint32_t aBitrateSize = sizeof(aBitrate);
//    status = AudioConverterSetProperty(_aConverter, kAudioConverterEncodeBitRate, aBitrateSize, &aBitrate);
//
//    //查询最大输出
//    uint32_t aMaxOutput = 0;
//    uint32_t aMaxOutputSize = sizeof(aMaxOutput);
//    AudioConverterGetProperty(_aConverter, kAudioConverterPropertyMaximumOutputPacketSize, &aMaxOutputSize, &aMaxOutput);
//    self.aMaxOutputFrameSize = aMaxOutput;
//    if (aMaxOutput == 0) {
//        [self onErrorWithCode:AWEncoderErrorCodeAudioConverterGetMaxFrameSizeFailed des:@"AAC 获取最大frame size失败"];
//    }
}

-(void)close{
//    AudioConverterDispose(_aConverter);
//    _aConverter = nil;
//    self.curFramePcmData = nil;
//    self.aMaxOutputFrameSize = 0;
}

//下面2个函数所有编码器都可以用
//将aac数据转为flv_audio_tag
extern aw_flv_audio_tag *aw_encoder_create_audio_tag(int8_t *aac_data, long len, uint32_t timeStamp, aw_faac_config *faac_cfg){
    aw_flv_audio_tag *audio_tag = aw_sw_encoder_create_flv_audio_tag(faac_cfg);
    audio_tag->aac_packet_type = aw_flv_a_aac_package_type_aac_raw;
    
    audio_tag->common_tag.timestamp = timeStamp;
    aw_data *frame_data = alloc_aw_data((uint32_t)len);
    memcpy(frame_data->data, aac_data, len);
    frame_data->size = (uint32_t)len;
    audio_tag->frame_data = frame_data;
    audio_tag->common_tag.data_size = audio_tag->frame_data->size + 11 + audio_tag->common_tag.header_size;
    return audio_tag;
}

//创建audio_specific_config_tag
extern aw_flv_audio_tag *aw_encoder_create_audio_specific_config_tag(aw_data *audio_specific_config_data, aw_faac_config *faac_config){
    //创建 audio specfic config record
    aw_flv_audio_tag *audio_tag = aw_sw_encoder_create_flv_audio_tag(faac_config);

    audio_tag->config_record_data = copy_aw_data(audio_specific_config_data);
    audio_tag->common_tag.timestamp = 0;
    audio_tag->common_tag.data_size = audio_specific_config_data->size + 11 + audio_tag->common_tag.header_size;

    return audio_tag;
}

//创建基本的audio tag，除类型，数据和时间戳
static aw_flv_audio_tag *aw_sw_encoder_create_flv_audio_tag(aw_faac_config *faac_cfg){
    aw_flv_audio_tag *audio_tag = alloc_aw_flv_audio_tag();
    audio_tag->sound_format = aw_flv_a_codec_id_AAC;
    audio_tag->common_tag.header_size = 2;
    
    if (faac_cfg->sample_rate == 22050) {
        audio_tag->sound_rate = aw_flv_a_sound_rate_22kHZ;
    }else if (faac_cfg->sample_rate == 11025) {
        audio_tag->sound_rate = aw_flv_a_sound_rate_11kHZ;
    }else if (faac_cfg->sample_rate == 5500) {
        audio_tag->sound_rate = aw_flv_a_sound_rate_5_5kHZ;
    }else{
        audio_tag->sound_rate = aw_flv_a_sound_rate_44kHZ;
    }
    
    if (faac_cfg->sample_size == 8) {
        audio_tag->sound_size = aw_flv_a_sound_size_8_bit;
    }else{
        audio_tag->sound_size = aw_flv_a_sound_size_16_bit;
    }
    
    audio_tag->sound_type = faac_cfg->channel_count == 1 ? aw_flv_a_sound_type_mono : aw_flv_a_sound_type_stereo;
    return audio_tag;
}

@end
