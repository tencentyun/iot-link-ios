//
//  WCAddTimerVC.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreAddTimerVC : UIViewController

@property (nonatomic, copy) NSString *productId;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic,copy) NSArray *actions;


@property (nonatomic,copy) NSDictionary *timerInfo;//编辑时传

@end

NS_ASSUME_NONNULL_END
