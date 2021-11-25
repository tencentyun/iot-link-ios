//
//  TIoTAVP2PPlayCaptureVC.h
//  LinkApp
//

#import <UIKit/UIKit.h>

@interface TIoTVideoDeviceCollectionView : UICollectionView

@end

NS_ASSUME_NONNULL_BEGIN

@interface TIoTAVP2PPlayCaptureVC : UIViewController
@property (nonatomic, strong) NSString *productID;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, assign) TIoTTRTCSessionCallType callType;
@property (nonatomic, strong) NSDictionary *objectModelDic; //物模型
@property (nonatomic, strong) NSMutableDictionary *reportDataDic; //控制设备报文的dic
@property (nonatomic, strong) TIOTtrtcPayloadParamModel *payloadParamModel; //被动呼叫才传
@property (nonatomic, assign) BOOL isCallIng; //是否APP主叫 YES 主叫  NO 被叫
@end

NS_ASSUME_NONNULL_END
