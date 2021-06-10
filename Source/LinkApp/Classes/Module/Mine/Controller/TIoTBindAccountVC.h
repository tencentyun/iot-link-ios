//
//  TIoTBindAccountVC.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

typedef void(^RefreshLoadBlock)(BOOL bindSuccess, BOOL isRefreshUserData);

typedef NS_ENUM(NSInteger, AccountType) {
    AccountType_Phone,
    AccountType_Email
};

NS_ASSUME_NONNULL_BEGIN

@interface TIoTBindAccountVC : UIViewController

/**
 初始化对象时候必须赋值
 */
@property (nonatomic, assign) AccountType accountType;

@property (nonatomic, copy) RefreshLoadBlock resfreshResponseBlock;

@end

NS_ASSUME_NONNULL_END
