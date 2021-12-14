
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, TIoTAVCaptionFLVAudioType) {
    TIoTAVCaptionFLVAudio_8,
    TIoTAVCaptionFLVAudio_16,
    TIoTAVCaptionFLVAudio_441
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
@end

