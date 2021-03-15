//
//  TIoTShortcutView.h
//  LinkApp
//
//  Created by ccharlesren on 2021/3/15.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 设备快捷入口View
 */
NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTEnterDevicePanel)(void);
@interface TIoTShortcutView : UIView
@property (nonatomic, copy) TIoTEnterDevicePanel moreFunctionBlock;


/// 设置设备快捷入口视图
/// @param config 设备物模型
/// @param deviceName 设备别名或设备名称
- (void)shortcutViewData:(NSDictionary *)config withDeviceName:(NSString *)deviceName;

@end

NS_ASSUME_NONNULL_END
