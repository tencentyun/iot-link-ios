

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol AWAACSendDelegate <NSObject>
- (void)sendData:(NSMutableData *)data;
@end

@interface AWAACEncoder : NSObject
@property (nonatomic,assign) NSInteger sample_rate;
@property (nonatomic,strong) id<AWAACSendDelegate>delegate;
-(void)encodeSmapleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
