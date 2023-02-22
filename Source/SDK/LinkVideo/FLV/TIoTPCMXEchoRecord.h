
#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <TPCircularBuffer/TPCircularBuffer.h>

typedef void(*RecordCallback)(uint8_t *buffer, int size, void *u);

NS_ASSUME_NONNULL_BEGIN

@interface TIoTPCMXEchoRecord : NSObject
@property (nonatomic, assign, readonly)AudioStreamBasicDescription pcmStreamDescription;

- (instancetype)initWithChannel:(int)channel isEcho:(BOOL)isEcho;
- (void)set_record_callback:(RecordCallback)c user:(void *)u;
- (void)start_record;
- (void)stop_record;


-(UInt32)getData:(void *)buf_ :(UInt32)size_;
@end

NS_ASSUME_NONNULL_END
