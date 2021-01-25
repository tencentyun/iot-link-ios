#ifndef aw_sw_faac_encoder_h
#define aw_sw_faac_encoder_h

#include "aw_encode_flv.h"

#include "faac.h"
#include "faaccfg.h"
#include "aw_faac.h"

//下面2个函数所有编码器都可以用
//将aac数据转为flv_audio_tag
extern aw_flv_audio_tag *aw_encoder_create_audio_tag(int8_t *aac_data, long len, uint32_t timeStamp, aw_faac_config *faac_cfg);
//创建audio_specific_config_tag
extern aw_flv_audio_tag *aw_encoder_create_audio_specific_config_tag(aw_data *audio_specific_config_data, aw_faac_config *faac_config);

extern aw_flv_audio_tag *aw_sw_encoder_encode_faac_data(int8_t *pcm_data, long len, uint32_t timestamp);
//根据faac_config 创建包含audio specific config 的flv tag
extern aw_flv_audio_tag *aw_sw_encoder_create_faac_specific_config_tag(void);

//编码器开关
extern void aw_sw_encoder_open_faac_encoder(aw_faac_config *faac_config);
extern void aw_sw_encoder_close_faac_encoder(void);

extern uint32_t aw_sw_faac_encoder_max_input_sample_count(void);
//编码器是否合法
extern int8_t aw_sw_faac_encoder_is_valid(void);

#endif /* aw_sw_audio_encoder_h */
