//
//  TIoTDemoDeviceHeaderView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
/**
 首页设备列表header view
 */

@class TIoTDemoDeviceHeaderView;

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIotDemoDeviceEditBlock)(TIoTDemoDeviceHeaderView *headerView,BOOL isEditPartten);
typedef void(^TIoTDemoCanceEditlBlock)(void);

@interface TIoTDemoDeviceHeaderView : UICollectionReusableView
@property (nonatomic, copy) TIotDemoDeviceEditBlock editBlock;
@property (nonatomic, copy) TIoTDemoCanceEditlBlock cancelEditBlock;

- (void)enterEditPattern;
- (void)exitEditPattern;
@end

NS_ASSUME_NONNULL_END
