//
//  TIoTChooseTimeZoneVC.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

typedef void(^returnTimeZoneBlock) (NSString * _Nonnull timeZone,NSString * _Nonnull cityName);

NS_ASSUME_NONNULL_BEGIN

@interface TIoTChooseTimeZoneVC : UIViewController

@property (nonatomic, copy) returnTimeZoneBlock returnTimeZoneBlock;
@property (nonatomic, copy) NSString *defaultTimeZone;
@end

NS_ASSUME_NONNULL_END
