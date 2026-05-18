//
//  TIoTCoreAudioConfig.h
//  TIoTLinkVideo
//
//  Created by eagleychen on 2022/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TIoTAVCaptionFLVAudioType) {
    TIoTAVCaptionFLVAudio_8,
    TIoTAVCaptionFLVAudio_16
};

@interface TIoTCoreAudioConfig : NSObject
/**
 *  声道数
 */
@property (nonatomic,assign) int channels;

/**
 *  采样率
 */
@property (nonatomic,assign) TIoTAVCaptionFLVAudioType sampleRate;

/**
 *  是否消除回音
 */
@property (nonatomic,assign) BOOL isEchoCancel;

/**
 *  是否变声， Sets pitch change in semi-tones compared to the original pitch
 *  (-12 .. +12)，默认为0不变声
 */
@property (nonatomic,assign) int pitch;

/**
 *  需要重启录音器和编码器设置为yes
 */
@property (nonatomic,assign) BOOL refreshSession;

/**
 *  是否通过外部采集编码自定义数据发送
 */
@property (nonatomic,assign) BOOL isExternal;

/**
 *  是否开启麦克风录音增益（软件放大），用于解决iOS录制声音过小、对端播放音量偏小的问题
 *  默认 NO（不开启）
 */
@property (nonatomic,assign) BOOL enableMicGain;

/**
 *  麦克风录音增益倍数（线性放大系数），仅在 enableMicGain == YES 时生效
 *  建议范围 1.0 ~ 4.0，超过 4.0 容易削顶失真；
 *  - 1.0 表示原始音量；
 *  - 2.0 表示放大约 +6dB；
 *  - 默认值 1.0
 */
@property (nonatomic,assign) float micGain;

@end

NS_ASSUME_NONNULL_END
