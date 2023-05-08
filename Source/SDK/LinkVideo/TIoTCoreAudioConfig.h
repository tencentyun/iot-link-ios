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

@property (nonatomic,assign) BOOL isMute;//是否静音

@end

NS_ASSUME_NONNULL_END
