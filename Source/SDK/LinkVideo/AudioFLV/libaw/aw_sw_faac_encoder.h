
#ifndef aw_sw_faac_encoder_h
#define aw_sw_faac_encoder_h

#include "aw_encode_flv.h"

typedef struct aw_faac_config {
    //采样率
    int sample_rate;
    
    //单个样本大小
    int sample_size;
    
    //比特率
    int bitrate;
    
    //声道
    int channel_count;
} aw_faac_config;


//下面2个函数所有编码器都可以用
//将aac数据转为flv_audio_tag
extern aw_flv_audio_tag *aw_encoder_create_audio_tag(int8_t *aac_data, long len, uint32_t timeStamp, aw_faac_config *faac_cfg);
//创建audio_specific_config_tag
extern aw_flv_audio_tag *aw_encoder_create_audio_specific_config_tag(aw_data *audio_specific_config_data, aw_faac_config *faac_config);


#endif /* aw_sw_audio_encoder_h */
