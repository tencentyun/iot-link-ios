
#import <UIKit/UIKit.h>
#import "TIoTCoreAudioConfig.h"
#import "TIoTCoreVideoConfig.h"

@protocol TIoTAVCaptionFLVDelegate <NSObject>
-(void) capture:(uint8_t *)data len:(size_t) size;
@end


@interface TIoTAVCaptionFLV : NSObject
@property (nonatomic, weak) id<TIoTAVCaptionFLVDelegate> delegate;
@property (nonatomic, assign)UIView *videoLocalView;
@property (nonatomic, assign)BOOL isEchoCancel;
@property (nonatomic, assign)int pitch;
@property (nonatomic, assign)AVCaptureDevicePosition devicePosition;
-(instancetype) initWithAudioConfig:(TIoTAVCaptionFLVAudioType)audioSampleRate channel:(int)channel;

- (void)preStart;
- (BOOL)startCapture;
- (void)stopCapture;
- (void)refreshLocalPreviewView;
- (void)changeCameraPositon;
- (void)setResolutionRatio:(AVCaptureSessionPreset)resolutionValue;
- (void)setVideoBitRate:(int32_t)bitRate;
- (int32_t)getVideoBitRate;
@end

