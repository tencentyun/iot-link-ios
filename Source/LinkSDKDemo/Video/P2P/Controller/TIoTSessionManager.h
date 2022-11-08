//
//  TIoTCoreASessionManager.h
//  TIoTLinkVideo
//
//  Created by eagleychen on 2022/11/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTSessionManager : NSObject
+ (instancetype)sharedInstance;
//需要录音时，AudioSession的设置代码如下
- (void)resumeRTCAudioSession;

//功能结束时重置audioSession,重置到缓存的audioSession设置
- (void)resetToCachedAudioSession;

- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
