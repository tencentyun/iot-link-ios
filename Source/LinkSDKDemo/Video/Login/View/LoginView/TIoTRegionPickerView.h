//
//  TIoTRegionPickerView.h
//  LinkSDKDemo
//

#import <UIKit/UIKit.h>

/**
 登录选择地域视图*/
NS_ASSUME_NONNULL_BEGIN

typedef void(^TIotPickerRegionBlock)(NSString *regionString, NSString *regioinID);

@interface TIoTRegionPickerView : UIView

@property (nonatomic, copy) TIotPickerRegionBlock regionStringBlock;

- (void)removeView;
@end

NS_ASSUME_NONNULL_END
