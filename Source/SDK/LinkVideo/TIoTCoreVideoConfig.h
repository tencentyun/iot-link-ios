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
 *  远端预览UI
 */
@property (nonatomic,strong) UIView *remoteView;

/**
 *  视频采集前后摄像头位置
 */
@property (nonatomic,assign) AVCaptureDevicePosition videoPosition;

/**
 *  需要重启采集器和编码器设置为yes
 */
@property (nonatomic,assign) BOOL refreshSession;

/**
 *  视频采集分辨率
 */
@property (nonatomic,assign)AVCaptureSessionPreset resolutionValue;

/**
 *  设置视频码率，在此基础上内部有自适应码率设置  https://cloud.tencent.com/document/product/647/79634#3825556cfc4b34e62b5348f82ed093b4
 */
@property (nonatomic,assign) int32_t bitRate;

@property (nonatomic,assign) BOOL isMute;//是否停止恢复推流
@end

NS_ASSUME_NONNULL_END
