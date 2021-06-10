//
//  WCSmartConfigDisNetViewController.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EquipmentType) {
    SmartConfig,
    Softap,
};

NS_ASSUME_NONNULL_BEGIN

@interface TIoTWIFINetViewController : UIViewController

@property (nonatomic, assign) EquipmentType equipmentType;
@property (nonatomic, copy) NSString *currentDistributionToken;
@property (nonatomic, copy) NSString *roomId;
@end

NS_ASSUME_NONNULL_END
