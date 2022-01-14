//
//  TIoTLoginCustomView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTLoginCustomView : UIView
//AccessID
@property (nonatomic, strong) UITextField *accessID;
//AccessToken
@property (nonatomic, strong) UITextField *accessToken;
//ProductID
@property (nonatomic, strong) UITextField *productID;
//regionName
@property (nonatomic, strong) UILabel *regionContent;

@property (nonatomic, strong) NSString *secretIDString;
@property (nonatomic, strong) NSString *secretKeyString;
@property (nonatomic, strong) NSString *productIDString;
@property (nonatomic, strong) NSString *regionConettString;
@property (nonatomic, readonly, strong) NSString *regionIDString;
@end

NS_ASSUME_NONNULL_END
