//
//  WCSendPhoneCodeViewController.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>
#import "TIoTBingPasswordViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTSendPhoneCodeViewController : UIViewController

@property (nonatomic, assign) RegisterType registerType;
@property (nonatomic, copy) NSDictionary *sendCodeDic;

@end

NS_ASSUME_NONNULL_END
