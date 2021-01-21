#import <Foundation/Foundation.h>
#import "AWAudioEncoder.h"

typedef enum : NSUInteger {
    AWAudioEncoderTypeNone,
    AWAudioEncoderTypeHWAACLC,
    AWAudioEncoderTypeSWFAAC,
} AWAudioEncoderType;

@class AWAudioEncoder;
@class AWAudioConfig;
@interface AWEncoderManager : NSObject
//编码器类型
@property (nonatomic, unsafe_unretained) AWAudioEncoderType audioEncoderType;

//编码器
@property (nonatomic, readonly, strong) AWAudioEncoder *audioEncoder;

//时间戳
@property (nonatomic, unsafe_unretained) uint32_t timestamp;

//开启关闭
-(void) openWithAudioConfig:(AWAudioConfig *) audioConfig;
-(void) close;

@end
