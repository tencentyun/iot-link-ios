//
//  WCBingPasswordViewController.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RegisterType) {
    PhoneRegister,
    EmailRegister,
    PhoneResetPwd,
    EmailResetPwd,
    LoginedResetPwd
};

NS_ASSUME_NONNULL_BEGIN

@interface TIoTBingPasswordViewController : UIViewController

@property (nonatomic, assign) RegisterType registerType;
@property (nonatomic, copy) NSDictionary *sendDataDic;

@end

NS_ASSUME_NONNULL_END
