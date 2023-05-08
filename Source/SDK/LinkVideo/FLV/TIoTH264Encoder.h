
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

@protocol H264EncoderDelegate <NSObject>

- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps;
- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame;

@end
@interface TIoTH264Encoder : NSObject

- (void) initWithConfiguration;
- (void) initEncode:(int)width  height:(int)height;
- (void) encode:(CMSampleBufferRef )sampleBuffer;
- (void) setEncoderBitrateBps:(uint32_t)bitRate;
- (void) End;


@property (weak, nonatomic) NSString *error;
@property (weak, nonatomic) id<H264EncoderDelegate> delegate;
@property (assign, nonatomic) uint32_t encoderBitrateBps; //当前码率

@end
