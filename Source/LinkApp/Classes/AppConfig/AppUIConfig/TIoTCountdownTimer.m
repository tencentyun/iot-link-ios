//
//  TIoTCountdownTimer.m
//  LinkApp
//
//  Created by ccharlesren on 2020/10/14.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTCountdownTimer.h"
#import "NSObject+additions.h"
#import "NSString+Extension.h"

static NSString * const verificationCodeNotification = @"verificationCodeNotification";

@interface TIoTCountdownTimer ()
@property (nonatomic, copy) NSString *inputTextIsError;
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation TIoTCountdownTimer


- (void)startTimerWithShowView:(UIButton *)sendCodeBtn inputText:(NSString *)inputText phoneOrEmailType:(BOOL)type {

    [self countdownTimerWithShowView:sendCodeBtn inputText:inputText phoneOrEmailType:type];
}

- (void)closeTimer {

    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)clearObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)countdownTimerWithShowView:(UIButton *)sendCodeBtn inputText:(NSString *)inputText phoneOrEmailType:(BOOL)type {
    
    //type  yes : phone  no : email
    
    self.inputTextIsError = @"0";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responsedVerificationButton:) name:verificationCodeNotification object:nil];
    
    __block NSInteger time = 59; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    WeakObj(self)
    dispatch_source_set_event_handler(selfWeak.timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            [selfWeak clearObserver];
            
            if (selfWeak.timer) {
                dispatch_source_cancel(selfWeak.timer);
                selfWeak.timer = nil;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [sendCodeBtn setTitle:NSLocalizedString(@"register_get_code", @"获取验证码") forState:UIControlStateNormal];
                
                if ([selfWeak.inputTextIsError isEqual:@"1"]) {
                    sendCodeBtn.enabled = NO;
                    [sendCodeBtn setTitleColor:kRGBColor(204, 204, 204) forState:UIControlStateNormal];
                }else {
                    if (type == YES) {
                        if ((![NSString isNullOrNilWithObject:inputText]) && [NSString judgePhoneNumberLegal:inputText withRegionID:[TIoTCoreUserManage shared].userRegionId]) {
                            sendCodeBtn.enabled = YES;
                            [sendCodeBtn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
                        }else {
                            sendCodeBtn.enabled = NO;
                            [sendCodeBtn setTitleColor:kRGBColor(204, 204, 204) forState:UIControlStateNormal];
                        }
                    }else {
                        if ((![NSString isNullOrNilWithObject:inputText]) && [NSString judgeEmailLegal:inputText]) {
                            sendCodeBtn.enabled = YES;
                            [sendCodeBtn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
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
