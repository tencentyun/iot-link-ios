//
//  TIoTAddAutoIntelligentVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TIoTAutoIntelligentModel;
/**
 自动智能主页面
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTAddAutoIntelligentVC : UIViewController

@property (nonatomic, strong) NSMutableArray <TIoTAutoIntelligentModel *>*autoDeviceStatusArray; //在setting创建完后返回的

@property (nonatomic, strong) NSDictionary *paramDic; //从智能主页传入场景参数

/**
 刷新当前条件、任务section
 */
- (void)refreshAutoIntelligentList:(BOOL)isAction;

@end

NS_ASSUME_NONNULL_END
