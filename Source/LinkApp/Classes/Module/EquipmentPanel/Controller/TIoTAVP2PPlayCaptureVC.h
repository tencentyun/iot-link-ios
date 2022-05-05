//
//  TIoTAVP2PPlayCaptureVC.h
//  LinkApp
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TIoTVideoDeviceCollectionView : UICollectionView

@end

@protocol TIoTAVP2PPlayCaptureVCDelegate <NSObject>

///在TopView上  点击拒绝或挂断按钮 退出，放回上页面
- (void)avP2PPlayRefuseOrHungupClick;
///在TopView上  点击同意 隐藏topview后，开启start
- (void)avP2PPlayAcceptClick;

@end

NS_ASSUME_NONNULL_BEGIN
//typedef void(^TIoTAVP2PStartServer)(BOOL isRefresh);

@interface TIoTAVP2PPlayCaptureVC : UIViewController
@property (nonatomic, weak) id<TIoTAVP2PPlayCaptureVCDelegate>delegate;
@property (nonatomic, strong) NSString *productID;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, assign) TIoTTRTCSessionCallType callType;
//@property (nonatomic, strong) NSDictionary *objectModelDic; //物模型
@property (nonatomic, strong) NSMutableDictionary *reportDataDic; //控制设备报文的dic
@property (nonatomic, strong) TIOTtrtcPayloadParamModel *payloadParamModel; //被动呼叫才传
@property (nonatomic, assign) BOOL isCallIng; //是否APP主叫 YES 主叫  NO 被叫
//@property (nonatomic, copy) TIoTAVP2PStartServer isRefreshBlock;

@property (nonatomic, strong) AVCaptureSessionPreset resolutionRatio; //p2pvideo 分辨率
@property (nonatomic, assign) NSInteger samplingRate;    //p2pvideo 采样率

- (void)hideTopView;

- (void)hungUp;
- (void)beHungUp;
- (void)noAnswered;
- (void)otherAnswered;
- (void)hangupTapped;    //挂断
@end

NS_ASSUME_NONNULL_END
