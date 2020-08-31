//
//  TIoTNewVersionTipView.h
//  LinkApp
//
//  Created by Sun on 2020/8/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTNewVersionTipView : UIView


/// 初始化TIoTNewVersionTipView
/// @param versionInfo 数据源
- (instancetype)initWithVersionInfo:(NSDictionary *)versionInfo;

@end

NS_ASSUME_NONNULL_END
