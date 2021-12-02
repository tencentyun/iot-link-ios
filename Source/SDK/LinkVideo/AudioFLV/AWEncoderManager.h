<<<<<<< HEAD   (204be9 修复使用DDLog库后，内存及时不释放问题)
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
=======
>>>>>>> CHANGE (516ba1 添加采集音频+视频+合成flv)
