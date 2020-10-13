//
//  NSObject+CountdownTimer.h
//  LinkApp
//
//  Created by ccharlesren on 2020/10/13.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CountdownTimer)

- (void)countdownTimerWithShowView:(UIButton *)sendCodeBtn inputText:(NSString *)inputText phoneOrEmailType:(BOOL)type;

@end

NS_ASSUME_NONNULL_END
