#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AWAVConfig.h"
#import "AWEncoder.h"
#import "AWEncoderManager.h"

@protocol AWAVCaptureDelegate <NSObject>
-(void) capture:(uint8_t *)data len:(size_t) size;
@end

@class AWAVCapture;

@interface AWAVCapture : NSObject
//配置
@property (nonatomic, strong) AWAudioConfig *audioConfig;

//编码器类型
@property (nonatomic, unsafe_unretained) AWAudioEncoderType audioEncoderType;

@property (nonatomic, weak) id<AWAVCaptureDelegate> delegate;

//是否将数据发送出去
@property (nonatomic, unsafe_unretained) BOOL isCapturing;

//预览view
@property (nonatomic, strong) UIView *preview;

//根据videoConfig获取当前CaptureSession preset分辨率
@property (nonatomic, readonly, copy) NSString *captureSessionPreset;

//初始化
-(instancetype) initWithAudioConfig:(AWAudioConfig *)audioConfig;

//初始化
-(BOOL) startCapture;

//停止capture
-(void) stopCapture;

-(void) sendAudioSampleBuffer:(CMSampleBufferRef) sampleBuffer;
-(void) sendAudioPcmData:(NSData *)audioData;
-(void) sendFlvAudioTag:(aw_flv_audio_tag *)flvAudioTag;

@end
