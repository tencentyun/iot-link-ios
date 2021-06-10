//
//  WCPanelVC.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>



@interface TIoTCollectionView : UICollectionView

@end

NS_ASSUME_NONNULL_BEGIN

@interface TIoTPanelVC : UIViewController

@property (nonatomic, copy) NSString *productId;
@property (nonatomic, copy) NSString *deviceName;

@property (nonatomic, strong) NSMutableDictionary *deviceDic;

@property (nonatomic) BOOL isOwner;//是否所有者
@property (nonatomic, copy) NSDictionary *configData;

@end

NS_ASSUME_NONNULL_END
