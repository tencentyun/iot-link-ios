//
//  TIoTAccessIDPickerView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIotPickerAccessIDBlock)(NSString *accessIDString);

@interface TIoTAccessIDPickerView : UIView

@property (nonatomic, copy) NSString *defaultAccessID;
@property (nonatomic, copy) TIotPickerAccessIDBlock accessIDStringBlock;
- (void)removeView;
@end

NS_ASSUME_NONNULL_END
