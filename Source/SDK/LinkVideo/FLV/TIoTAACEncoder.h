
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TIoTCoreAudioConfig.h"

@protocol TIoTAACEncoderDelegate <NSObject>
- (void)getEncoderAACData:(NSData *)data;
@end

@interface TIoTAACEncoder : NSObject
@property (nonatomic,weak) id<TIoTAACEncoderDelegate> delegate;
@property (nonatomic) TIoTAVCaptionFLVAudioType audioType;

- (instancetype)initWithAudioDescription:(AudioStreamBasicDescription)inAudioDes;

- (void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)encodePCMData:(NSData *)pcmdata;
@end
