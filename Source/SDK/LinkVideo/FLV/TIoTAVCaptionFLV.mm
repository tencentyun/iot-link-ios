

#import "TIoTAVCaptionFLV.h"
#import "TIoTAACEncoder.h"
#import "TIoTH264Encoder.h"

#include <string>
//#include <flv-writer.h>
//#include <flv-muxer.h>
#import "flv-writer.h"
#import "flv-muxer.h"

#include <iostream>

__weak static TIoTAVCaptionFLV *tAVCaptionFLV = nil;
static flv_muxer_t* flvMuxer = nullptr;
dispatch_queue_t muxerQueue;
//NSFileHandle *_fileHandle;

@interface TIoTAVCaptionFLV ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,H264EncoderDelegate>
// 负责输如何输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession           *session;
// 队列
@property (nonatomic, strong) dispatch_queue_t           videoQueue;
@property (nonatomic, strong) dispatch_queue_t           AudioQueue;

// 负责从 AVCaptureDevice 获得输入数据
@property (nonatomic, strong) AVCaptureDeviceInput       *deviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput   *videoOutput;
@property (nonatomic, strong) AVCaptureConnection        *videoConnection;
@property (nonatomic, strong) AVCaptureConnection        *audioConnection;
// 拍摄预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) TIoTH264Encoder                *h264Encoder;
@property (nonatomic, strong) TIoTAACEncoder                 *aacEncoder;
//@property (nonatomic, strong) NSMutableData              *data;
//@property (nonatomic, copy  ) NSString                   *h264File;
//@property (nonatomic, strong) NSFileHandle               *fileHandle;
@property (nonatomic, assign) TIoTAVCaptionFLVAudioType     audioRate;
@property (nonatomic, assign) int captureVideoFPS;
@property (nonatomic, strong) AVCaptureSessionPreset resolutionRatioValue;
@end

@implementation TIoTAVCaptionFLV

-(instancetype) initWithAudioConfig:(TIoTAVCaptionFLVAudioType)audioSampleRate {
    self = [super init];
    if (self) {
        tAVCaptionFLV = self;
        _audioRate = audioSampleRate;
        [self onInit];
    }
    return self;
}

-(void) onInit{
    if (@available(iOS 10.0, *)) {
        [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"getfps=== %d", self.captureVideoFPS);
        }];
    } else {
        // Fallback on earlier versions
    }
    
    muxerQueue = dispatch_queue_create("FLV_Muxer_Queue", DISPATCH_QUEUE_SERIAL);
    
//    _data = [NSMutableData new];
    _session = [AVCaptureSession new];
    
    self.resolutionRatioValue = AVCaptureSessionPreset640x480;
}

#pragma mark - 设置音频
- (void)setupAudioCapture {
    
    if (self.aacEncoder) {
        self.aacEncoder.audioType = _audioRate;
        return;
    }
    self.aacEncoder = [TIoTAACEncoder new];
    self.aacEncoder.audioType = _audioRate;
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioDevice error:&error];
    
    if (error) {
        
        NSLog(@"Error getting audio input device:%@",error.description);
    }
    
    if ([self.session canAddInput:audioInput]) {
        
        [self.session addInput:audioInput];
    }
    
    self.AudioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    
    AVCaptureAudioDataOutput *audioOutput = [AVCaptureAudioDataOutput new];
    [audioOutput setSampleBufferDelegate:self queue:self.AudioQueue];
    
    if ([self.session canAddOutput:audioOutput]) {
        
        [self.session addOutput:audioOutput];
    }
    
    self.audioConnection = [audioOutput connectionWithMediaType:AVMediaTypeAudio];
    

}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

/**
 切换前后摄像头
 */
-(void)changeCameraPositon{
    //获取摄像头的数量（该方法会返回当前能够输入视频的全部设备，包括前后摄像头和外接设备）
    NSInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    //摄像头的数量小于等于1的时候直接返回
    if (cameraCount <= 1) {
        return;
    }
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    //获取当前相机的方向（前/后）
    AVCaptureDevicePosition position = [[self.deviceInput device] position];
    
    if (position == AVCaptureDevicePositionFront) {
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }else if (position == AVCaptureDevicePositionBack){
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
    }
    //输入流
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    if (newInput != nil) {
        [self.session beginConfiguration];
        //先移除原来的input
        [self.session removeInput:self.deviceInput];
        if ([self.session canAddInput:newInput]) {
            [self.session addInput:newInput];
            self.deviceInput = newInput;
        }else{
            //如果不能加现在的input，就加原来的input
            [self.session addInput:self.deviceInput];
        }
        
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
        // 保存Connection,用于SampleBufferDelegate中判断数据来源(video or audio?)
        _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        [_videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        
        [self.session commitConfiguration];
    }

    [self setCameraFPS:15];
}

+ (AVCaptureDevice *)getCaptureDevicePosition:(AVCaptureDevicePosition)position {
    NSArray *devices = nil;
    
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *deviceDiscoverySession =  [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
        devices = deviceDiscoverySession.devices;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
    }
    
    for (AVCaptureDevice *device in devices) {
        if (position == device.position) {
            return device;
        }
    }
    return NULL;
}

+ (BOOL)setCameraFrameRateAndResolutionWithFrameRate:(int)frameRate andResolutionHeight:(CGFloat)resolutionHeight bySession:(AVCaptureSession *)session position:(AVCaptureDevicePosition)position videoFormat:(OSType)videoFormat {
    AVCaptureDevice *captureDevice = [self getCaptureDevicePosition:position];
    
    BOOL isSuccess = NO;
    for(AVCaptureDeviceFormat *vFormat in [captureDevice formats]) {
        CMFormatDescriptionRef description = vFormat.formatDescription;
        float maxRate = ((AVFrameRateRange*) [vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
        if (maxRate >= frameRate && CMFormatDescriptionGetMediaSubType(description) == videoFormat) {
            if ([captureDevice lockForConfiguration:NULL] == YES) {
                // 对比镜头支持的分辨率和当前设置的分辨率
                CMVideoDimensions dims = CMVideoFormatDescriptionGetDimensions(description);
                if (dims.height == resolutionHeight) {
                    [session beginConfiguration];
                    if ([captureDevice lockForConfiguration:NULL]){
                        captureDevice.activeFormat = vFormat;
                        [captureDevice setActiveVideoMinFrameDuration:CMTimeMake(1, frameRate)];
                        [captureDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, frameRate)];
                        [captureDevice unlockForConfiguration];
                    }
                    [session commitConfiguration];
                    
                    return YES;
                }
            }else {
                NSLog(@"%s: lock failed!",__func__);
            }
        }
    }
    
    NSLog(@"Set camera frame is success : %d, frame rate is %lu, resolution height = %f",isSuccess,(unsigned long)frameRate,resolutionHeight);
    return NO;
}

#pragma mark - 设置视频 capture
- (void)configEncode {
    if ([self.resolutionRatioValue isEqualToString: AVCaptureSessionPreset352x288]) {
        [self.h264Encoder initEncode:288 height:352];
    }else if ([self.resolutionRatioValue isEqualToString: AVCaptureSessionPreset640x480]) {
        [self.h264Encoder initEncode:480 height:640];
    }else if ([self.resolutionRatioValue isEqualToString: AVCaptureSessionPreset1280x720]) {
        [self.h264Encoder initEncode:720 height:1280];
    }else if ([self.resolutionRatioValue isEqualToString: AVCaptureSessionPreset1920x1080]) {
        [self.h264Encoder initEncode:1080 height:1920];
    }
}

- (void)setupVideoCapture {
    if (self.h264Encoder) {
        if ([_session canSetSessionPreset:self.resolutionRatioValue]) {
            // 设置分辨率
            _session.sessionPreset = self.resolutionRatioValue;
        }
        return;
    }
    self.h264Encoder = [TIoTH264Encoder new];
    [self.h264Encoder initWithConfiguration];
    [self configEncode];

    self.h264Encoder.delegate = self;
   
    if ([_session canSetSessionPreset:self.resolutionRatioValue]) {
        // 设置分辨率
        _session.sessionPreset = self.resolutionRatioValue;
    }
    
    //设置采集的 Video 和 Audio 格式，这两个是分开设置的，也就是说，你可以只采集视频。
    //配置采集输入源(摄像头)
    
    NSError *error = nil;
    //获得一个采集设备, 例如前置/后置摄像头
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
//    videoDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
    //用设备初始化一个采集的输入对象
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    self.deviceInput = videoInput;
    if (error) {
        NSLog(@"Error getting video input device:%@",error.description);
        
    }
    if ([_session canAddInput:videoInput]) {
        [_session addInput:videoInput];
    }
    
    //配置采集输出,即我们取得视频图像的接口
    _videoQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    _videoOutput = [AVCaptureVideoDataOutput new];
    [_videoOutput setSampleBufferDelegate:self queue:_videoQueue];
    
    // 配置输出视频图像格式
    NSDictionary *captureSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    _videoOutput.videoSettings = captureSettings;
    _videoOutput.alwaysDiscardsLateVideoFrames = YES;
    
    if ([_session canAddOutput:_videoOutput]) {
        [_session addOutput:_videoOutput];
    }
    // 保存Connection,用于SampleBufferDelegate中判断数据来源(video or audio?)
    _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    [_videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    // 启动session
//    [_session startRunning];
    //将当前硬件采集视频图像显示到屏幕
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; // 设置预览时的视频缩放方式
    [[_previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait]; // 设置视频的朝向
    
    _previewLayer.frame = self.videoLocalView.bounds;
    [self.videoLocalView.layer addSublayer:_previewLayer];
}

- (void)calculatorCaptureFPS {
    static int count = 0;
    static float lastTime = 0;
    CMClockRef hostClockRef = CMClockGetHostTimeClock();
    CMTime hostTime = CMClockGetTime(hostClockRef);
    float nowTime = CMTimeGetSeconds(hostTime);
    if(nowTime - lastTime >= 1) {
        self.captureVideoFPS = count;
        lastTime = nowTime;
        count = 0;
    }else {
        count ++;
    }
}


#pragma mark - 实现 AVCaptureOutputDelegate：
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (connection == _videoConnection) {  // Video

        if (self.videoLocalView) { //开关打开，才推送视频
            [self.h264Encoder encode:sampleBuffer];
            
            [self calculatorCaptureFPS];
        }
    
    } else if (connection == _audioConnection) {  // Audio
        
        [self.aacEncoder encodeSampleBuffer:sampleBuffer completionBlock:^(NSData *encodedData, NSError *error) {
            
            if (encodedData) {
//                NSLog(@"Audio data (%lu):%@", (unsigned long)encodedData.length,encodedData.description);
                
//                [self.data appendData:encodedData];
                encodeFlvData(0, encodedData);
            }else {
//                NSLog(@"Error encoding AAC: %@", error);
            }
        }];
    }
}

#pragma mark - H264EncoderDelegate
- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps {
    
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    
//    [_fileHandle writeData:ByteHeader];
//    [_fileHandle writeData:sps];
//    [_fileHandle writeData:ByteHeader];
//    [_fileHandle writeData:pps];
    
    NSMutableData *fullSPSPPS = [NSMutableData dataWithData:ByteHeader];
    [fullSPSPPS appendData:sps];
    [fullSPSPPS appendData:ByteHeader];
    [fullSPSPPS appendData:pps];
    encodeFlvData(1, fullSPSPPS);
    
}
- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame {
    
//    NSLog(@"Video data (%lu):%@", (unsigned long)data.length,data.description);
    
//    if (_fileHandle != NULL)
//    {
        const char bytes[] = "\x00\x00\x00\x01";
        size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
        NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
        

//        [_fileHandle writeData:ByteHeader];
//        [_fileHandle writeData:data];
        
        NSMutableData *fullH264 = [NSMutableData dataWithData:ByteHeader];
        [fullH264 appendData:data];
        encodeFlvData(1, fullH264);
//    }
    
}

void flv_init_load() {
    void *w = flv_writer_create2(1, 1, flv_onwrite, nullptr);
    flvMuxer = flv_muxer_create(flv_onmuxer, w);
}

static int flv_onmuxer(void* flv, int type, const void* data, size_t bytes, uint32_t timestamp)
{
//    NSLog(@"========= flv_onmuxer type: %d, size: %zu", type,bytes);
    return flv_writer_input(flv, type, data, bytes, timestamp);
}

static int flv_onwrite(void *param, const struct flv_vec_t* vec, int n) {
    
    int total_size = 0;
    for(int i = 0; i < n; i++) {
        total_size += vec[i].len;
    }

//    NSLog(@"========= flv_onmuxer total size: %d", total_size);
    char* bytes = new char[total_size];
    for(int i = 0, offset = 0; i < n; i++) {
        memcpy(bytes + offset, vec[i].ptr, vec[i].len);
        offset += vec[i].len;
    }

//    NSData *ByteHeader = [NSData dataWithBytes:bytes length:total_size];
//    [_fileHandle writeData:ByteHeader];
    
    [tAVCaptionFLV.delegate capture:(uint8_t *)bytes len:total_size];
    
    delete[] bytes;
    return 0;
}

//type=0 audio ; type=1 video
int encodeFlvData(int type, NSData *packetData) {
    
    
    if (flvMuxer == nullptr) {
        NSLog(@"Please init flv muxer first.");
        return -1;
    }
    
    dispatch_async(muxerQueue, ^{
        
        CFTimeInterval timestamp = CACurrentMediaTime();
        uint32_t pts = timestamp*1000;
        
        const void *c_data = packetData.bytes;
        NSUInteger len = packetData.length;
        //    NSLog(@"===========================------------ %ld, pts: %u", len, pts);
        
        
        int ret = 0;
        if (type == 0) { //audio
            ret = flv_muxer_aac(flvMuxer, c_data, len, pts, pts);
        }else {
            ret = flv_muxer_avc(flvMuxer, c_data, len, pts, pts);
        }
    });
    
    return 0;
}

#pragma mark - 录制
- (void)preStart {
    [self setupAudioCapture];
    
    if (self.videoLocalView) {
        //是否启动视频采集
        [self setupVideoCapture];
    }
    [self.session commitConfiguration];
}

-(BOOL) startCapture {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
//    self.h264File = [documentsDirectory stringByAppendingPathComponent:@"lyh.h264"];
//    [fileManager removeItemAtPath:self.h264File error:nil];
//    [fileManager createFileAtPath:self.h264File contents:nil attributes:nil];
//    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.h264File];
        
    flv_init_load();

    [self startCamera];
    return YES;
}

-(void) stopCapture{
    [self stopCarmera];
}

- (void) startCamera
{
    [self setCameraFPS:15];
    [self.session startRunning];
    if (self.videoLocalView) {
        _previewLayer.frame = self.videoLocalView.bounds;
        [self.videoLocalView.layer addSublayer:_previewLayer];
    }else {
        _previewLayer.frame = CGRectZero;
    }
}

- (void) stopCarmera
{
//    [_h264Encoder End];
    [_session stopRunning];

//    [_fileHandle closeFile];
//    _fileHandle = NULL;
//
    // 获取程序Documents目录路径
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSMutableString * path = [[NSMutableString alloc]initWithString:documentsDirectory];
    [path appendString:@"/AACFile.aac"];
    
    [_data writeToFile:path atomically:YES];
    */
}

- (void)setCameraFPS:(int)fps {
    AVCaptureDevice *videoDevice = [self.deviceInput device];
    if ([videoDevice lockForConfiguration:nil]) {
        videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, fps);
        videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, fps);
        [videoDevice unlockForConfiguration];
    }
}

- (void)setResolutionRatio:(AVCaptureSessionPreset )resolutionValue{
    if ([self.resolutionRatioValue isEqualToString:resolutionValue]) {
        return;
    }
    
    if (resolutionValue == nil || resolutionValue.length == 0) {
        self.resolutionRatioValue = AVCaptureSessionPreset640x480;
    }else {
        self.resolutionRatioValue = resolutionValue;
    }
    
    //reset preset
    [self.h264Encoder End];
    [self configEncode];
}
@end
