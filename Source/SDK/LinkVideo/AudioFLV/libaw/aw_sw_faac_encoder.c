#include "aw_sw_faac_encoder.h"
#include <stdio.h>
#include <string.h>

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

