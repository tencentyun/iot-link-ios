//
//  WCTipView.h
//  TenextCloud
//
//  Created by Wp on 2020/3/25.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTipView : UIView

@property (nonatomic,strong) void(^feedback)(void);
@property (nonatomic,strong) void(^navback)(void);

- (void)showInView:(UIView *)superView;

@end

NS_ASSUME_NONNULL_END
