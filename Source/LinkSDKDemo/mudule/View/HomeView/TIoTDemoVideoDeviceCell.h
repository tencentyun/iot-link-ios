//
//  TIoTDemoVideoDeviceCell.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/25.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTExploreOrVideoDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIoTDemoChooseDeviceBlcok)(void);
typedef void(^TIoTDemoShowMoreActionBlock)(void);

@interface TIoTDemoVideoDeviceCell : UICollectionViewCell
@property (nonatomic, copy) TIoTDemoChooseDeviceBlcok chooseDeviceBlock; //选择设备block
@property (nonatomic, copy) TIoTDemoShowMoreActionBlock moreActionBlock; //更多 预览、回放

@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *model;
@end

NS_ASSUME_NONNULL_END
