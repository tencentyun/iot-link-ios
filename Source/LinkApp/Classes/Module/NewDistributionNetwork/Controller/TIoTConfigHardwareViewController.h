//
//  TIoTConfigHardwareViewController.h
//  LinkApp
//
//  Created by Sun on 2020/7/28.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTConfigHardwareViewController : UIViewController

/// 配网类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, strong) NSDictionary *configurationData;

@property (nonatomic, assign) BOOL isDistributeNetFailure; //配网失败，切换配网方式时候，再新的配网流程中，用来判断返回首页还是上个页面
@end

NS_ASSUME_NONNULL_END
