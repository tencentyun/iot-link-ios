
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

@protocol H264EncoderDelegate <NSObject>

- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps;
- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame;

@end
@interface TIoTH264Encoder : NSObject

- (void) initWithConfiguration;
- (void) start:(int)width  height:(int)height;
- (void) initEncode:(int)width  height:(int)height;
- (void) encode:(CMSampleBufferRef )sampleBuffer;
- (void) End;


@property (weak, nonatomic) NSString *error;
@property (weak, nonatomic) id<H264EncoderDelegate> delegate;

@end
