//
//  TIoTDemoVideoDeviceCell.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
#import "TIoTExploreOrVideoDeviceModel.h"
/**
 首页设备列cell item
 */

NS_ASSUME_NONNULL_BEGIN

@class TIoTDemoVideoDeviceCell;

typedef void(^TIoTDemoChooseDeviceBlcok)(UIButton *itemBtn);
typedef void(^TIoTDemoShowMoreActionBlock)(void);

@interface TIoTDemoVideoDeviceCell : UICollectionViewCell
@property (nonatomic, copy) TIoTDemoChooseDeviceBlcok chooseDeviceBlock; //选择设备block
@property (nonatomic, copy) TIoTDemoShowMoreActionBlock moreActionBlock; //更多 预览、回放

@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *model; //item model

@property (nonatomic, assign) BOOL isShowChoiceDeviceIcon; //选择同屏设备icon

@property (nonatomic, strong) UIButton *chooseDeviceBtn; //选择设备按钮

@property (nonatomic, assign) BOOL isNVRDevice; //只在homeVC 列表中判断 是nvr 隐藏预览按钮
@end

NS_ASSUME_NONNULL_END
