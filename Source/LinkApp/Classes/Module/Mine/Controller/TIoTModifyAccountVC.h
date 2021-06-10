//
//  TIoTModifyAccountVC.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AccountModifyType) {
    AccountModifyType_Phone,
    AccountModifyType_Email
};

NS_ASSUME_NONNULL_BEGIN

@interface TIoTModifyAccountVC : UIViewController

/**
 初始化对象时候必须赋值
 */
@property (nonatomic, assign) AccountModifyType accountType;

@end

NS_ASSUME_NONNULL_END
