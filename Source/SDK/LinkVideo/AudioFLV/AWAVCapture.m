
#import "AWAVCapture.h"
#import "AWEncoderManager.h"

static aw_data *s_output_buf = NULL;
__weak static AWAVCapture *sAWAVCapture = nil;
NSFileHandle *flvFileHandle;
int isVideoConfig = 0;

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
        if (self.videoConfig) {
            _encoderManager.videoEncoderType = self.videoEncoderType;
        }
    }
    return _encoderManager;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"please call initWithVideoConfig:audioConfig to init" reason:nil userInfo:nil];
}

-(instancetype) initWithVideoConfig:(AWVideoConfig *)videoConfig audioConfig:(AWAudioConfig *)audioConfig{
    self = [super init];
    if (self) {
        self.videoConfig = videoConfig;
        self.audioConfig = audioConfig;
        sAWAVCapture = self;
        if (self.videoConfig && self.audioConfig) {
            isVideoConfig = 1;
        }
        [self onInit];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

-(instancetype) initWithAudioConfig:(AWAudioConfig *)audioConfig {
    self = [super init];
    if (self) {
        self.audioConfig = audioConfig;
        sAWAVCapture = self;
        isVideoConfig = 0;
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

-(BOOL) startCapture{
    
    if (!self.videoConfig && !self.audioConfig) {
        NSLog(@"one of videoConfig and audioConfig must be NON-NULL");
        return NO;
    }
    if (self.videoConfig && self.audioConfig) {
        //初始化文件管理
        [self setLocalVideoPathString];
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //先开启encoder
        if (self.videoConfig && self.audioConfig) {
            [weakSelf.encoderManager openWithAudioConfig:weakSelf.audioConfig videoConfig:weakSelf.videoConfig];
        }
        if (!self.videoConfig && self.audioConfig) {
            [weakSelf.encoderManager openWithAudioConfig:weakSelf.audioConfig videoConfig:nil];
        }
        if (!self.videoConfig && !self.audioConfig) {
            [weakSelf.encoderManager openWithAudioConfig:nil videoConfig:nil];
        }
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
        
//        aw_streamer_close();
        if (self.videoConfig) {
            //释放buf
            if (!s_output_buf) {
                aw_log("[E] aw_streamer_open_encoder s_out_buf is already free");
                return;
            }
            free_aw_data(&s_output_buf);
            
            //关闭文件
            [flvFileHandle closeFile];
            flvFileHandle = NULL;
        }
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

- (void)setLocalVideoPathString {
    
    NSString *audioFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"VideoStream.flv"];
    [[NSFileManager defaultManager] removeItemAtPath:audioFile error:nil];
    [[NSFileManager defaultManager] createFileAtPath:audioFile contents:nil attributes:nil];
    flvFileHandle = [NSFileHandle fileHandleForWritingAtPath:audioFile];
}

//发送数据
-(void) sendVideoSampleBuffer:(CMSampleBufferRef) sampleBuffer toEncodeQueue:(NSOperationQueue *) encodeQueue toSendQueue:(NSOperationQueue *) sendQueue{
    if (_inBackground) {
        return;
    }
    CFRetain(sampleBuffer);
    __weak typeof(self) weakSelf = self;
    [encodeQueue addOperationWithBlock:^{
        if (weakSelf.isCapturing) {
            aw_flv_video_tag *video_tag = [weakSelf.encoderManager.videoEncoder encodeVideoSampleBufToFlvTag:sampleBuffer];
            [weakSelf sendFlvVideoTag:video_tag toSendQueue:sendQueue];
        }
        CFRelease(sampleBuffer);
    }];
}

-(void)sendAudioSampleBuffer:(CMSampleBufferRef) sampleBuffer toEncodeQueue:(NSOperationQueue *) encodeQueue toSendQueue:(NSOperationQueue *) sendQueue{
    CFRetain(sampleBuffer);
    __weak typeof(self) weakSelf = self;
    [encodeQueue addOperationWithBlock:^{
        if (self.isCapturing) {
            aw_flv_audio_tag *audio_tag = [self.encoderManager.audioEncoder encodeAudioSampleBufToFlvTag:sampleBuffer];
            [self sendFlvAudioTag:audio_tag toSendQueue:sendQueue];
        }
        CFRelease(sampleBuffer);
    }];
}

-(void)sendVideoYuvData:(NSData *)yuvData toEncodeQueue:(NSOperationQueue *) encodeQueue toSendQueue:(NSOperationQueue *) sendQueue{
    if (_inBackground) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [encodeQueue addOperationWithBlock:^{
        if (weakSelf.isCapturing) {
            NSData *rotatedData = [weakSelf.encoderManager.videoEncoder rotateNV12Data:yuvData];
            aw_flv_video_tag *video_tag = [weakSelf.encoderManager.videoEncoder encodeYUVDataToFlvTag:rotatedData];
            [weakSelf sendFlvVideoTag:video_tag toSendQueue:sendQueue];
        }
    }];
}

-(void)sendAudioPcmData:(NSData *)pcmData toEncodeQueue:(NSOperationQueue *) encodeQueue toSendQueue:(NSOperationQueue *) sendQueue{
    __weak typeof(self) weakSelf = self;
    [encodeQueue addOperationWithBlock:^{
        if (self.isCapturing) {
            aw_flv_audio_tag *audio_tag = [self.encoderManager.audioEncoder encodePCMDataToFlvTag:pcmData];
            [self sendFlvAudioTag:audio_tag toSendQueue:sendQueue];
        }
    }];
}

-(void)sendFlvVideoTag:(aw_flv_video_tag *)video_tag toSendQueue:(NSOperationQueue *) sendQueue{
    if (_inBackground) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (video_tag) {
        [sendQueue addOperationWithBlock:^{
            if(weakSelf.isCapturing){
                if (!weakSelf.isSpsPpsAndAudioSpecificConfigSent) {
                    [weakSelf sendSpsPpsAndAudioSpecificConfigTagToSendQueue:sendQueue];
                    free_aw_flv_video_tag((aw_flv_video_tag **)&video_tag);
                }else{
                    aw_local_streamer_send_video_data(video_tag);
                }
            }else{
                free_aw_flv_video_tag((aw_flv_video_tag **)(&video_tag));
            }
        }];
    }
}

-(void)sendFlvAudioTag:(aw_flv_audio_tag *)audio_tag toSendQueue:(NSOperationQueue *) sendQueue{
    __weak typeof(self) weakSelf = self;
    if(audio_tag){
        [sendQueue addOperationWithBlock:^{
            if(self.isCapturing){
                if (!self.isSpsPpsAndAudioSpecificConfigSent) {
                    [self sendSpsPpsAndAudioSpecificConfigTagToSendQueue:sendQueue];
                    free_aw_flv_audio_tag((aw_flv_audio_tag **)&audio_tag);
                }else{
                    aw_local_streamer_send_audio_data(audio_tag);
                }
            }else{
                free_aw_flv_audio_tag((aw_flv_audio_tag **)&audio_tag);
            }
        }];
    }
}

-(void) sendAudioAACData:(NSData *)audioData {
    if (audioData == nil) {
        NSLog(@"audiodata is nil");
        return;
    }
    [self sendAudioAACData:audioData toEncodeQueue:self.encodeSampleOpQueue toSendQueue:self.sendSampleOpQueue];
}

-(void) sendAudioAACData:(NSData *)aacData toEncodeQueue:(NSOperationQueue *) encodeQueue toSendQueue:(NSOperationQueue *) sendQueue{
    __weak typeof(self) weakSelf = self;
    [encodeQueue addOperationWithBlock:^{
        if (self.isCapturing) {
            aw_flv_audio_tag *audio_tag = [self.encoderManager.audioEncoder encodeAACDataToFlvTag:aacData];
            [self sendFlvAudioTag:audio_tag toSendQueue:sendQueue];
        }
    }];
}

-(void)sendSpsPpsAndAudioSpecificConfigTagToSendQueue:(NSOperationQueue *) sendQueue{
    if (self.isSpsPpsAndAudioSpecificConfigSent) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [sendQueue addOperationWithBlock:^{
        if (!self.isCapturing || self.isSpsPpsAndAudioSpecificConfigSent) {
            return;
        }
        
        //写 header
        aw_write_flv_header(&s_output_buf);
        NSData *headerFLV = [NSData dataWithBytes:s_output_buf->data length:s_output_buf->size];
        [flvFileHandle writeData:headerFLV];
        [sAWAVCapture.delegate capture:s_output_buf->data len:s_output_buf->size];
        reset_aw_data(&s_output_buf);
        
        if (self.audioConfig && self.videoConfig) {
            //script tag
            aw_flv_script_tag *scriptTag = alloc_aw_flv_script_tag();
            scriptTag->width = self.videoConfig.width;
            scriptTag->height = self.videoConfig.height;
            scriptTag->a_sample_rate = self.audioConfig.sampleRate;
            scriptTag->a_sample_size = self.audioConfig.sampleSize;
            scriptTag->stereo = self.audioConfig.channelCount;
            scriptTag->file_size = 255;
            
            scriptTag->video_data_rate = self.videoConfig.bitrate;
            scriptTag->frame_rate = self.videoConfig.fps;
            
            aw_write_flv_tag(&s_output_buf, &scriptTag->common_tag);
            
            NSData *scriptDataTag = [NSData dataWithBytes:s_output_buf->data length:s_output_buf->size];
            [flvFileHandle writeData:scriptDataTag];
            [sAWAVCapture.delegate capture:s_output_buf->data len:s_output_buf->size];
            free_aw_flv_script_tag(&scriptTag);
            reset_aw_data(&s_output_buf);
        }
        
        aw_flv_video_tag *spsPpsTag = NULL;
        aw_flv_audio_tag *audioSpecificConfigTag = NULL;
        if (self.videoConfig) {
            //video sps pps tag
            spsPpsTag = [self.encoderManager.videoEncoder createSpsPpsFlvTag];
            if (spsPpsTag) {
                aw_local_streamer_send_video_sps_pps_tag(spsPpsTag);
            }
        }
        if (self.audioConfig) {
            //audio specific config tag
            audioSpecificConfigTag = [self.encoderManager.audioEncoder createAudioSpecificConfigFlvTag];
            if (audioSpecificConfigTag) {
                aw_local_streamer_send_audio_specific_config_tag(audioSpecificConfigTag);
            }
        }
        
        self.isSpsPpsAndAudioSpecificConfigSent = spsPpsTag || audioSpecificConfigTag;
        
        aw_log("[D] is sps pps and audio sepcific config sent=%d", self.isSpsPpsAndAudioSpecificConfigSent);
    }];
}

//传输buf数据
-(void)sendVideoSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    [self sendVideoSampleBuffer:sampleBuffer toEncodeQueue:self.encodeSampleOpQueue toSendQueue:self.sendSampleOpQueue];
}

-(void)sendAudioSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    [self sendAudioSampleBuffer:sampleBuffer toEncodeQueue:self.encodeSampleOpQueue toSendQueue:self.sendSampleOpQueue];
}

-(void) sendVideoYuvData:(NSData *)videoData{
    [self sendVideoYuvData:(NSData *)videoData toEncodeQueue:self.encodeSampleOpQueue toSendQueue:self.sendSampleOpQueue];
}
-(void)sendAudioPcmData:(NSData *)audioData{
    [self sendAudioPcmData:audioData toEncodeQueue:self.encodeSampleOpQueue toSendQueue:self.sendSampleOpQueue];
}

-(void)sendFlvVideoTag:(aw_flv_video_tag *)flvVideoTag{
    [self sendFlvVideoTag:flvVideoTag toSendQueue:self.sendSampleOpQueue];
}

-(void)sendFlvAudioTag:(aw_flv_audio_tag *)flvAudioTag{
    [self sendFlvAudioTag:flvAudioTag toSendQueue:self.sendSampleOpQueue];
}

-(NSString *)captureSessionPreset{
    NSString *captureSessionPreset = nil;
    if(self.videoConfig.width == 480 && self.videoConfig.height == 640){
        captureSessionPreset = AVCaptureSessionPreset640x480;
    }else if(self.videoConfig.width == 540 && self.videoConfig.height == 960){
        captureSessionPreset = AVCaptureSessionPresetiFrame960x540;
    }else if(self.videoConfig.width == 720 && self.videoConfig.height == 1280){
        captureSessionPreset = AVCaptureSessionPreset1280x720;
    }
    return captureSessionPreset;
}

extern void aw_local_streamer_send_audio_specific_config_tag(aw_flv_audio_tag *asc_tag){
    //本地
    //发送 audio specific config
    aw_local_streamer_send_flv_tag_to_rtmp(&asc_tag->common_tag);
}

extern void aw_local_streamer_send_video_sps_pps_tag(aw_flv_video_tag *sps_pps_tag){
    //本地
    //发送 video sps pps
    aw_local_streamer_send_flv_tag_to_rtmp(&sps_pps_tag->common_tag);
}

extern void aw_local_streamer_send_audio_data(aw_flv_audio_tag *audio_tag){
    //本地
    aw_local_streamer_send_flv_tag_to_rtmp(&audio_tag->common_tag);
}

extern void aw_local_streamer_send_video_data(aw_flv_video_tag *video_tag){
    //本地
    aw_local_streamer_send_flv_tag_to_rtmp(&video_tag->common_tag);
}

static void aw_local_streamer_send_flv_tag_to_rtmp(aw_flv_common_tag *common_tag){
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
    
    //写入文件
    NSData *rawFLV = [NSData dataWithBytes:s_output_buf->data length:s_output_buf->size];
    [flvFileHandle writeData:rawFLV];
    if (s_output_buf->size != 0) {
        [sAWAVCapture.delegate capture:s_output_buf->data len:s_output_buf->size];
    }
    reset_aw_data(&s_output_buf);
    
}

@end
