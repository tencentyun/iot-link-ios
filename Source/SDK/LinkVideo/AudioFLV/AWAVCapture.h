/*
 视频捕获基类。将捕获的音/视频数据送入 encodeSampleQueue串行队列进行编码，然后送入sendSampleQueue队列发送至rtmp接口。
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "aw_all.h"
#import "AWAVConfig.h"
#import "AWEncoder.h"
#import "AWEncoderManager.h"

@class AWAVCapture;
@protocol AWAVCaptureDelegate <NSObject>
//音频
-(void)capture:(uint8_t *)data len:(size_t)size;
//音视频
-(void)avCapture:(uint8_t *)data len:(size_t)size;
@end

@interface AWAVCapture : NSObject
//配置
@property (nonatomic, strong) AWAudioConfig *audioConfig;
@property (nonatomic, strong) AWVideoConfig *videoConfig;

//编码器类型
@property (nonatomic, unsafe_unretained) AWAudioEncoderType audioEncoderType;
@property (nonatomic, unsafe_unretained) AWAudioEncoderType videoEncoderType;

@property (nonatomic, weak) id<AWAVCaptureDelegate> delegate;

//是否将数据发送出去
@property (nonatomic, unsafe_unretained) BOOL isCapturing;

//预览view
@property (nonatomic, strong) UIView *preview;

//根据videoConfig获取当前CaptureSession preset分辨率
@property (nonatomic, readonly, copy) NSString *captureSessionPreset;

//初始化
-(instancetype) initWithVideoConfig:(AWVideoConfig *)videoConfig audioConfig:(AWAudioConfig *)audioConfig;

//初始化
-(instancetype) initWithAudioConfig:(AWAudioConfig *)audioConfig;

//初始化
-(void) onInit;

//修改fps
-(void) updateFps:(NSInteger) fps;

//切换摄像头
-(void) switchCamera;

//停止capture
-(void) stopCapture;

//开始capture
-(BOOL) startCapture;

-(void) sendVideoSampleBuffer:(CMSampleBufferRef) sampleBuffer;
-(void) sendAudioSampleBuffer:(CMSampleBufferRef) sampleBuffer;

-(void) sendVideoYuvData:(NSData *)videoData;
-(void) sendAudioPcmData:(NSData *)audioData;

-(void) sendFlvVideoTag:(aw_flv_video_tag *)flvVideoTag;
-(void) sendFlvAudioTag:(aw_flv_audio_tag *)flvAudioTag;

-(void) sendAudioAACData:(NSData *)audioData;

@end
