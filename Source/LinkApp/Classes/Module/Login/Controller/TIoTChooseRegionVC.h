//
//  TIoTChooseRegionVC.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

typedef void(^returnRegionBlock) (NSString * _Nonnull Title,NSString * _Nonnull region,NSString * _Nonnull RegionID,NSString *_Nullable CountryCode);

NS_ASSUME_NONNULL_BEGIN

@interface TIoTChooseRegionVC : UIViewController

@property (nonatomic, copy) returnRegionBlock returnRegionBlock;

@end

NS_ASSUME_NONNULL_END
