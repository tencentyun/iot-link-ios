//
//  TIoTSearchLocationVC.h
//  LinkApp
//
//  Created by ccharlesren on 2021/3/6.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TIoTPoisModel;

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIoTSearchLocatonBlcok)(TIoTPoisModel *posiModel);

@interface TIoTSearchLocationVC : UIViewController
@property (nonatomic, strong) TIoTSearchLocatonBlcok chooseLocBlcok;
@end

NS_ASSUME_NONNULL_END
