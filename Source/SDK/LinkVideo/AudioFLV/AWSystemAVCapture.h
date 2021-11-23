
/*
 使用系统接口捕获视频，没有进行美颜。
 系统捕获音视频的详细过程。
 */

#import <Foundation/Foundation.h>
#import "AWAVCapture.h"

@interface AWSystemAVCapture : AWAVCapture

/*
 可选，默认根据屏幕尺寸大小
 */
- (void)setpreviewLayer:(CGRect)frame;

@end
