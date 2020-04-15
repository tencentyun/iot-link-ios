//
//  XDPRefreshFooter.h
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/18.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "MJRefreshAutoFooter.h"
#define kXDPRefreshFooterFailure @"加载失败，点击重新加载"
NS_ASSUME_NONNULL_BEGIN

@interface WCRefreshFooter : MJRefreshAutoFooter

- (void)showFailStatus;

- (void)setTitle:(NSString *)title forState:(MJRefreshState)state;

- (NSString *)titleForState:(MJRefreshState)state;

@end

NS_ASSUME_NONNULL_END
