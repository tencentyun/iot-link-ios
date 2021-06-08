//
//  TIoTDemoPlaybackCustomCell.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/5.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTDemoCloudEventListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDemoPlaybackCustomCell : UITableViewCell
@property (nonatomic, strong) TIoTDemoCloudEventModel *model;
@end

NS_ASSUME_NONNULL_END
