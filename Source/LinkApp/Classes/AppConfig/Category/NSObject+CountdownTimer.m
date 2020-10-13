//
//  NSObject+CountdownTimer.m
//  LinkApp
//
//  Created by ccharlesren on 2020/10/13.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "NSObject+CountdownTimer.h"
#import "NSObject+additions.h"
#import "NSString+Extension.h"
#import <objc/runtime.h>

@interface NSObject ()
@property (nonatomic, copy) NSString *inputTextIsError;
@end

static NSString * const verificationCodeNotification = @"verificationCodeNotification";

@implementation NSObject (CountdownTimer)

- (void)setInputTextIsError:(NSString *)inputTextIsError {
    objc_setAssociatedObject(self, @selector(inputTextIsError), inputTextIsError, OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *)inputTextIsError {
    return objc_getAssociatedObject(self, @selector(inputTextIsError));
}

- (void)countdownTimerWithShowView:(UIButton *)sendCodeBtn inputText:(NSString *)inputText phoneOrEmailType:(BOOL)type {
    
    //type  yes : phone  no : email
    
    self.inputTextIsError = @"0";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responsedVerificationButton:) name:verificationCodeNotification object:nil];
    
//    WeakObj(self)
    __block NSInteger time = 59; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [sendCodeBtn setTitle:NSLocalizedString(@"register_get_code", @"获取验证码") forState:UIControlStateNormal];
                
                if ([self.inputTextIsError isEqual:@"1"]) {
                    sendCodeBtn.enabled = NO;
                    [sendCodeBtn setTitleColor:kRGBColor(204, 204, 204) forState:UIControlStateNormal];
                }else {
                    if (type == YES) {
                        if ((![NSString isNullOrNilWithObject:inputText]) && [NSString judgePhoneNumberLegal:inputText]) {
                            sendCodeBtn.enabled = YES;
                            [sendCodeBtn setTitleColor:kMainColor forState:UIControlStateNormal];
                        }else {
                            sendCodeBtn.enabled = NO;
                            [sendCodeBtn setTitleColor:kRGBColor(204, 204, 204) forState:UIControlStateNormal];
                        }
                    }else {
                        if ((![NSString isNullOrNilWithObject:inputText]) && [NSString judgeEmailLegal:inputText]) {
                            sendCodeBtn.enabled = YES;
                            [sendCodeBtn setTitleColor:kMainColor forState:UIControlStateNormal];
                        }else {
                            sendCodeBtn.enabled = NO;
                            [sendCodeBtn setTitleColor:kRGBColor(204, 204, 204) forState:UIControlStateNormal];
                        }
                    }
                }
                
            });
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [sendCodeBtn setTitle:[NSString stringWithFormat:@"%@(%.2ds)", NSLocalizedString(@"resend", @"重新发送"),seconds] forState:UIControlStateNormal];
                sendCodeBtn.enabled = NO;
                [sendCodeBtn setTitleColor:kRGBColor(204, 204, 204) forState:UIControlStateNormal];
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}

- (void)responsedVerificationButton:(NSNotification *)notification {
    
    if ([[notification object] isEqual:@(YES) ]) {
        self.inputTextIsError = @"1";
    }
}
@end
