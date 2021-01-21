#import "AWSystemAVCapture.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AWSystemAVCapture ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

//音频设备
@property (nonatomic, strong) AVCaptureDeviceInput *audioInputDevice;
//输出数据接收
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;
//会话
@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation AWSystemAVCapture

-(void)switchCamera{
    
}

-(void)onInit{
    [self createCaptureDevice];
    [self createOutput];
    [self createCaptureSession];
}

//初始化视频设备
-(void) createCaptureDevice{
    //麦克风
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.audioInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
}


//创建会话
-(void) createCaptureSession{
    self.captureSession = [AVCaptureSession new];
    
    [self.captureSession beginConfiguration];
    
    if ([self.captureSession canAddInput:self.audioInputDevice]) {
        [self.captureSession addInput:self.audioInputDevice];
    }
    
    
    if([self.captureSession canAddOutput:self.audioDataOutput]){
        [self.captureSession addOutput:self.audioDataOutput];
    }
    
//    if (![self.captureSession canSetSessionPreset:self.captureSessionPreset]) {
//        @throw [NSException exceptionWithName:@"Not supported captureSessionPreset" reason:[NSString stringWithFormat:@"captureSessionPreset is [%@]", self.captureSessionPreset] userInfo:nil];
//    }
    
    self.captureSession.sessionPreset = self.captureSessionPreset;
    
    [self.captureSession commitConfiguration];
    
    [self.captureSession startRunning];
}

//销毁会话
-(void) destroyCaptureSession{
    if (self.captureSession) {
        [self.captureSession removeInput:self.audioInputDevice];
        [self.captureSession removeOutput:self.self.audioDataOutput];
    }
    self.captureSession = nil;
}

-(void) createOutput{
    
    dispatch_queue_t captureQueue = dispatch_queue_create("aw.capture.queue", DISPATCH_QUEUE_SERIAL);
    
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOutput setSampleBufferDelegate:self queue:captureQueue];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (self.isCapturing) {
//        if([self.audioDataOutput isEqual:captureOutput]){
            [self sendAudioSampleBuffer:sampleBuffer];
//        }
    }
}

@end
