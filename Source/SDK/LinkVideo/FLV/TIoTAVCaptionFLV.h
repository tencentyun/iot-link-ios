
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, TIoTAVCaptionFLVAudioType) {
    TIoTAVCaptionFLVAudio_8,
    TIoTAVCaptionFLVAudio_16
};

@protocol TIoTAVCaptionFLVDelegate <NSObject>
-(void) capture:(uint8_t *)data len:(size_t) size;
@end


@interface TIoTAVCaptionFLV : NSObject
@property (nonatomic, weak) id<TIoTAVCaptionFLVDelegate> delegate;
@property (nonatomic, assign)UIView *videoLocalView;
-(instancetype) initWithAudioConfig:(TIoTAVCaptionFLVAudioType)audioSampleRate;

- (void)preStart;
-(BOOL) startCapture;
-(void) stopCapture;
-(void)changeCameraPositon;
- (void)setResolutionRatio:(AVCaptureSessionPreset)resolutionValue;
@end

