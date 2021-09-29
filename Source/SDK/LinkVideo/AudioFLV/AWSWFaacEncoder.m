#import "AWSWFaacEncoder.h"
#import "AWEncoderManager.h"

@implementation AWSWFaacEncoder

-(aw_flv_audio_tag *) encodePCMDataToFlvTag:(NSData *)pcmData{
    // 添加对pcm格式封装在flv的支持
    aw_flv_audio_tag *audio_tag = alloc_aw_flv_audio_tag();
    audio_tag->sound_format = aw_flv_a_codec_id_PCM_LE;
    audio_tag->common_tag.header_size = 1;
    audio_tag->sound_rate = aw_flv_a_sound_rate_44kHZ;
    audio_tag->sound_size = aw_flv_a_sound_size_16_bit;
    audio_tag->sound_type = aw_flv_a_sound_type_mono;// : aw_flv_a_sound_type_stereo;
    audio_tag->aac_packet_type = aw_flv_a_aac_package_type_aac_raw;
    
    const void *aac_data = pcmData.bytes;
    long len = pcmData.length;
    aw_data *frame_data = alloc_aw_data((uint32_t)len);
    memcpy(frame_data->data, aac_data, len);
    frame_data->size = (uint32_t)len;
    audio_tag->frame_data = frame_data;
    
    audio_tag->common_tag.timestamp = 0;
    audio_tag->common_tag.data_size = audio_tag->frame_data->size + 11 + audio_tag->common_tag.header_size;
    
    return audio_tag;
    // 添加对pcm格式封装在flv的支持
    
    
    
    self.manager.timestamp += aw_sw_faac_encoder_max_input_sample_count() * 1000 / self.audioConfig.sampleRate;
    return aw_sw_encoder_encode_faac_data((int8_t *)pcmData.bytes, pcmData.length, self.manager.timestamp);
}

-(aw_flv_audio_tag *)createAudioSpecificConfigFlvTag{
    return aw_sw_encoder_create_faac_specific_config_tag();
}

-(void) open{
    aw_faac_config faac_config = self.audioConfig.faacConfig;
    aw_sw_encoder_open_faac_encoder(&faac_config);
}

-(void)close{
    aw_sw_encoder_close_faac_encoder();
}
@end
