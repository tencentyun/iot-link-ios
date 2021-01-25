#import "AWAVCapture.h"
#import "AWEncoderManager.h"
#include "aw_data.h"

static aw_data *s_output_buf = NULL;
__weak static AWAVCapture *sAWAVCapture = nil;

@interface AWAVCapture()
//编码队列，发送队列
@property (nonatomic, strong) NSOperationQueue *encodeSampleOpQueue;
@property (nonatomic, strong) NSOperationQueue *sendSampleOpQueue;

//是否已发送了sps/pps
@property (nonatomic, unsafe_unretained) BOOL isSpsPpsAndAudioSpecificConfigSent;

//编码管理
@property (nonatomic, strong) AWEncoderManager *encoderManager;

//进入后台后，不推视频流
@property (nonatomic, unsafe_unretained) BOOL inBackground;
@end

@implementation AWAVCapture

-(NSOperationQueue *)encodeSampleOpQueue{
    if (!_encodeSampleOpQueue) {
        _encodeSampleOpQueue = [[NSOperationQueue alloc] init];
        _encodeSampleOpQueue.maxConcurrentOperationCount = 1;
    }
    return _encodeSampleOpQueue;
}

-(NSOperationQueue *)sendSampleOpQueue{
    if (!_sendSampleOpQueue) {
        _sendSampleOpQueue = [[NSOperationQueue alloc] init];
        _sendSampleOpQueue.maxConcurrentOperationCount = 1;
    }
    return _sendSampleOpQueue;
}

-(AWEncoderManager *)encoderManager{
    if (!_encoderManager) {
        _encoderManager = [[AWEncoderManager alloc] init];
        //设置编码器类型
        _encoderManager.audioEncoderType = self.audioEncoderType;
    }
    return _encoderManager;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"please call initWithVideoConfig:audioConfig to init" reason:nil userInfo:nil];
}

-(instancetype) initWithAudioConfig:(AWAudioConfig *)audioConfig {
    self = [super init];
    if (self) {
        self.audioConfig = audioConfig;
        sAWAVCapture = self;
        [self onInit];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

-(void) onInit{}

-(void) willEnterForeground{
    self.inBackground = NO;
}

-(void) didEnterBackground{
    self.inBackground = YES;
}

//修改fps
-(void) updateFps:(NSInteger) fps{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *vDevice in videoDevices) {
        float maxRate = [(AVFrameRateRange *)[vDevice.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0] maxFrameRate];
        if (maxRate >= fps) {
            if ([vDevice lockForConfiguration:NULL]) {
                vDevice.activeVideoMinFrameDuration = CMTimeMake(10, (int)(fps * 10));
                vDevice.activeVideoMaxFrameDuration = vDevice.activeVideoMinFrameDuration;
                [vDevice unlockForConfiguration];
            }
        }
    }
}

-(BOOL) startCapture {    
    if (!self.audioConfig) {
        NSLog(@"one of videoConfig and audioConfig must be NON-NULL");
        return NO;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //先开启encoder
        [weakSelf.encoderManager openWithAudioConfig:weakSelf.audioConfig];
        weakSelf.isCapturing = YES;
    });
    return YES;
}

-(void) stopCapture{
    self.isCapturing = NO;
    self.isSpsPpsAndAudioSpecificConfigSent = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //关闭编码器
        [self.encodeSampleOpQueue cancelAllOperations];
        [self.encodeSampleOpQueue waitUntilAllOperationsAreFinished];
        
        [self.encoderManager close];
        
        //关闭流
        [self.sendSampleOpQueue cancelAllOperations];
        [self.sendSampleOpQueue waitUntilAllOperationsAreFinished];
    });
}

-(void) switchCamera{}

-(void) onStopCapture{}

-(void) onStartCapture{}

-(void)setisCapturing:(BOOL)isCapturing{
    if (_isCapturing == isCapturing) {
        return;
    }
    
    if (!isCapturing) {
        [self onStopCapture];
    }else{
        [self onStartCapture];
    }
    
    _isCapturing = isCapturing;
}

-(UIView *)preview{
    if (!_preview) {
        _preview = [UIView new];
        _preview.bounds = [UIScreen mainScreen].bounds;
    }
    return _preview;
}

//发送数据
-(void) sendAudioSampleBuffer:(CMSampleBufferRef) sampleBuffer toEncodeQueue:(NSOperationQueue *) encodeQueue toSendQueue:(NSOperationQueue *) sendQueue{
    CFRetain(sampleBuffer);
    __weak typeof(self) weakSelf = self;
    [encodeQueue addOperationWithBlock:^{
        if (weakSelf.isCapturing) {
            aw_flv_audio_tag *audio_tag = [weakSelf.encoderManager.audioEncoder encodeAudioSampleBufToFlvTag:sampleBuffer];
            [weakSelf sendFlvAudioTag:audio_tag toSendQueue:sendQueue];
        }
        CFRelease(sampleBuffer);
    }];
}


-(void) sendAudioPcmData:(NSData *)pcmData toEncodeQueue:(NSOperationQueue *) encodeQueue toSendQueue:(NSOperationQueue *) sendQueue{
    __weak typeof(self) weakSelf = self;
    [encodeQueue addOperationWithBlock:^{
        if (weakSelf.isCapturing) {
            aw_flv_audio_tag *audio_tag = [weakSelf.encoderManager.audioEncoder encodePCMDataToFlvTag:pcmData];
            [weakSelf sendFlvAudioTag:audio_tag toSendQueue:sendQueue];
        }
    }];
}


-(void) sendFlvAudioTag:(aw_flv_audio_tag *)audio_tag toSendQueue:(NSOperationQueue *) sendQueue{
    __weak typeof(self) weakSelf = self;
    if(audio_tag){
        [sendQueue addOperationWithBlock:^{
            if(weakSelf.isCapturing){
                if (!weakSelf.isSpsPpsAndAudioSpecificConfigSent) {
                    [weakSelf sendSpsPpsAndAudioSpecificConfigTagToSendQueue:sendQueue];
                    free_aw_flv_audio_tag((aw_flv_audio_tag **)&audio_tag);
                }else{
                    aw_streamer_send_audio_data(audio_tag);
                }
            }else{
                free_aw_flv_audio_tag((aw_flv_audio_tag **)&audio_tag);
            }
        }];
    }
}

-(void) sendSpsPpsAndAudioSpecificConfigTagToSendQueue:(NSOperationQueue *) sendQueue{
    if (self.isSpsPpsAndAudioSpecificConfigSent) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [sendQueue addOperationWithBlock:^{
        if (!weakSelf.isCapturing || weakSelf.isSpsPpsAndAudioSpecificConfigSent) {
            return;
        }
        //flv header  hhhhhhhhhhhhhhhhhhhh
        aw_write_audio_header();
        
        
        //audio specific config tag
        aw_flv_audio_tag *audioSpecificConfigTag = [weakSelf.encoderManager.audioEncoder createAudioSpecificConfigFlvTag];
        if (audioSpecificConfigTag) {
            aw_streamer_send_audio_specific_config_tag(audioSpecificConfigTag);
        }
        weakSelf.isSpsPpsAndAudioSpecificConfigSent = audioSpecificConfigTag;
        
        NSLog(@"[D] is sps pps and audio sepcific config sent=%d", weakSelf.isSpsPpsAndAudioSpecificConfigSent);
    }];
}

//使用rtmp协议发送数据
-(void) sendAudioSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    [self sendAudioSampleBuffer:sampleBuffer toEncodeQueue:self.encodeSampleOpQueue toSendQueue:self.sendSampleOpQueue];
}

-(void) sendAudioPcmData:(NSData *)audioData{
    [self sendAudioPcmData:audioData toEncodeQueue:self.encodeSampleOpQueue toSendQueue:self.sendSampleOpQueue];
}

-(void) sendFlvAudioTag:(aw_flv_audio_tag *)flvAudioTag{
    [self sendFlvAudioTag:flvAudioTag toSendQueue:self.sendSampleOpQueue];
}

-(NSString *)captureSessionPreset{
    NSString *captureSessionPreset = nil;
//    if(self.videoConfig.width == 480 && self.videoConfig.height == 640){
        captureSessionPreset = AVCaptureSessionPreset640x480;
//    }else if(self.videoConfig.width == 540 && self.videoConfig.height == 960){
        captureSessionPreset = AVCaptureSessionPresetiFrame960x540;
//    }else if(self.videoConfig.width == 720 && self.videoConfig.height == 1280){
        captureSessionPreset = AVCaptureSessionPreset1280x720;
//    }
    return captureSessionPreset;
}

//TODO传输flv header
extern void aw_write_audio_header(){
    
    aw_data *ttt_output_buf = NULL;
    aw_write_flv_header(&ttt_output_buf);
    
    //send flv header
    [sAWAVCapture.delegate capture:ttt_output_buf->data len:ttt_output_buf->size];
//   ttt_output_buf
    
    reset_aw_data(&ttt_output_buf);
}


extern void aw_streamer_send_audio_specific_config_tag(aw_flv_audio_tag *asc_tag){
    
    //发送 audio specific config
    aw_streamer_send_flv_tag_to_rtmp(&asc_tag->common_tag);
}

extern void aw_streamer_send_audio_data(aw_flv_audio_tag *audio_tag){
    
//   free_aw_flv_audio_tag(&audio_tag);
    aw_streamer_send_flv_tag_to_rtmp(&audio_tag->common_tag);
}

static void aw_streamer_send_flv_tag_to_rtmp(aw_flv_common_tag *common_tag){
    if (common_tag) {
        aw_write_flv_tag(&s_output_buf, common_tag);
        switch (common_tag->tag_type) {
            case aw_flv_tag_type_audio: {
                free_aw_flv_audio_tag(&common_tag->audio_tag);
                break;
            }
            case aw_flv_tag_type_video: {
                free_aw_flv_video_tag(&common_tag->video_tag);
                break;
            }
            case aw_flv_tag_type_script: {
                free_aw_flv_script_tag(&common_tag->script_tag);
                break;
            }
        }
    }

//TODO send FLVBody
    [sAWAVCapture.delegate capture:s_output_buf->data len:s_output_buf->size];
    
    reset_aw_data(&s_output_buf);
}

@end
