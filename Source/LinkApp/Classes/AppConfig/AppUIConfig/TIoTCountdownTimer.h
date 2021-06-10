//
//  TIoTCountdownTimer.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCountdownTimer : NSObject

- (void)startTimerWithShowView:(UIButton *)sendCodeBtn inputText:(NSString *)inputText phoneOrEmailType:(BOOL)type;

- (void)closeTimer;

- (void)clearObserver;

@end

NS_ASSUME_NONNULL_END
