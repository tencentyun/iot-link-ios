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
@property (nonatomic, strong) NSDictionary *objectModelDic; //物模型
- (void)open;
- (void)close;

@end

NS_ASSUME_NONNULL_END
