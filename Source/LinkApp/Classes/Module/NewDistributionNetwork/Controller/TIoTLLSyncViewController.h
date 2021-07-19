//
//  TIoTLLSyncViewController.h
//  LinkApp
//
//  Created by eagleychen on 2021/7/19.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTLLSyncViewController : UIViewController

@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, strong) NSDictionary *configurationData;

@property (nonatomic, assign) BOOL isDistributeNetFailure; //配网失败，切换配网方式时候，再新的配网流程中，用来判断返回首页还是上个页面

@end

NS_ASSUME_NONNULL_END
