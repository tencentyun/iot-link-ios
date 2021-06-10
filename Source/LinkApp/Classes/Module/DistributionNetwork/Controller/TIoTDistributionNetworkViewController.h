//
//  WC 配网 WCDistributionNetworkViewController.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>
#import "TIoTWIFINetViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDistributionNetworkViewController : UIViewController

@property (nonatomic, assign) EquipmentType equipmentType;
@property (nonatomic, copy) NSString *roomId;

@end

NS_ASSUME_NONNULL_END
