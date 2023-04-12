//
//  TIoTCoreVideoConfig.h
//  TIoTLinkVideo
//
//  Created by eagleychen on 2022/9/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN


@interface TIoTCoreVideoConfig : NSObject
/**
 *  本地预览UI
 */
@property (nonatomic,strong) UIView *localView;

/**
 *  视频采集前后摄像头位置
 */
@property (nonatomic,assign) AVCaptureDevicePosition videoPosition;

/**
 *  设置视频码率，在此基础上内部有自适应码率设置
 */
@property (nonatomic,assign) int32_t bitRate;

/**
 *  需要重启采集器和编码器设置为yes
 */
@property (nonatomic,assign) BOOL refreshSession;
/**
 *  是否通过外部采集编码自定义数据发送
 */
@property (nonatomic,assign) BOOL isExternal;
@end

NS_ASSUME_NONNULL_END
