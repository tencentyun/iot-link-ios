//
//  WCAddTimerVC.h
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCAddTimerVC : UIViewController

@property (nonatomic, copy) NSString *productId;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic,copy) NSArray *actions;


@property (nonatomic,copy) NSDictionary *timerInfo;//编辑时传

@end

NS_ASSUME_NONNULL_END
