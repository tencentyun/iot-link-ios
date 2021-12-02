<<<<<<< HEAD   (204be9 修复使用DDLog库后，内存及时不释放问题)
#import <AVFoundation/AVFoundation.h>
#import "AWAVConfig.h"

#include "aw_encode_flv.h"
#include "aw_alloc.h"
#include "aw_sw_faac_encoder.h"

typedef enum : NSUInteger {
    AWEncoderErrorCodeVTSessionCreateFailed,
    AWEncoderErrorCodeVTSessionPrepareFailed,
    AWEncoderErrorCodeLockSampleBaseAddressFailed,
    AWEncoderErrorCodeEncodeVideoFrameFailed,
    AWEncoderErrorCodeEncodeCreateBlockBufFailed,
    AWEncoderErrorCodeEncodeCreateSampleBufFailed,
    AWEncoderErrorCodeEncodeGetSpsPpsFailed,
    AWEncoderErrorCodeEncodeGetH264DataFailed,
    
    AWEncoderErrorCodeCreateAudioConverterFailed,
    AWEncoderErrorCodeAudioConverterGetMaxFrameSizeFailed,
    AWEncoderErrorCodeAudioEncoderFailed,
} AWEncoderErrorCode;

@class AWEncoderManager;
@interface AWEncoder : NSObject
@property (nonatomic, weak) AWEncoderManager *manager;
//开始
-(void) open;
//结束
-(void) close;
//错误
-(void) onErrorWithCode:(AWEncoderErrorCode) code des:(NSString *) des;

@end
=======
>>>>>>> CHANGE (516ba1 添加采集音频+视频+合成flv)
