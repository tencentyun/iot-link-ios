//
//  TIoTSessionManager.m
//  TIoTLinkVideo
//
//  Created by eagleychen on 2022/11/2.
//

#import "TIoTSessionManager.h"
#import <AVFoundation/AVFoundation.h>

static AVAudioSessionCategory cachedCategory = nil;
static AVAudioSessionCategoryOptions cachedCategoryOptions = 0;

@interface TIoTSessionManager ()
@property(nonatomic, assign) AVAudioSessionPortOverride portOverride;
@property (nonatomic,weak)   AVAudioSession *session;
@end

@implementation TIoTSessionManager
 
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static TIoTSessionManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init {
    if (self = [super init]) {
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(handleInterruptionNotification:)
                       name:AVAudioSessionInterruptionNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(handleRouteChangeNotification:)
                       name:AVAudioSessionRouteChangeNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(handleMediaServicesWereLost:)
                       name:AVAudioSessionMediaServicesWereLostNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(handleMediaServicesWereReset:)
                       name:AVAudioSessionMediaServicesWereResetNotification
                     object:nil];
        // Posted on the main thread when the primary audio from other applications
        // starts and stops. Foreground applications may use this notification as a
        // hint to enable or disable audio that is secondary.
        [center addObserver:self
                   selector:@selector(handleSilenceSecondaryAudioHintNotification:)
                       name:AVAudioSessionSilenceSecondaryAudioHintNotification
                     object:nil];
        // Also track foreground event in order to deal with interruption ended situation.
        [center addObserver:self
                   selector:@selector(handleApplicationDidBecomeActive:)
                       name:UIApplicationDidBecomeActiveNotification
                     object:nil];
        
        NSLog(@"RTC_OBJC_TYPE(RTCAudioSession) (%p): init.", self);
    }
    return self;
}

//更改audioSession前缓存RTC当下的设置
- (void)cacheCurrentAudioSession {
    NSLog(@"cache-->%@",[self description]);
    
    @synchronized (self) {
        cachedCategory = [AVAudioSession sharedInstance].category;
        cachedCategoryOptions = [AVAudioSession sharedInstance].categoryOptions;
        
        NSLog(@"cacheCategory==>%@,cacheOptions==>%d", cachedCategory, cachedCategoryOptions);
    }
}
 

//需要录音时，AudioSession的设置代码如下：
- (void)resumeRTCAudioSession {
    self.session = [AVAudioSession sharedInstance];
    if (self.session.category != AVAudioSessionCategoryPlayAndRecord) {
        [self cacheCurrentAudioSession]; //先缓存之前的
        
        NSLog(@"resumeToCachegory===>%@, categoryOption==>%ld",cachedCategory, cachedCategoryOptions);
//        NSError *error;
        
//        [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
//        [self.session setMode:AVAudioSessionModeVideoChat error:nil];
//        [self.session setActive:YES error:&error];
        
        AVAudioSessionCategoryOptions categoryOptions = AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers;
        if (@available(iOS 10.0, *)) {
            categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
        }
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:categoryOptions error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
}
//功能结束时重置audioSession,重置到缓存的audioSession设置
- (void)resetToCachedAudioSession {
    if (!cachedCategory) {
        return;
    }
    BOOL needResetAudioSession = ![[AVAudioSession sharedInstance].category isEqualToString:cachedCategory] || [AVAudioSession sharedInstance].categoryOptions != cachedCategoryOptions;
    NSLog(@"resetToCachegory===>%@, categoryOption==>%ld, needrest==%d",cachedCategory, cachedCategoryOptions, needResetAudioSession);
    if (needResetAudioSession) {
        dispatch_async(dispatch_get_main_queue(), ^{
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[AVAudioSession sharedInstance] setCategory:cachedCategory withOptions:cachedCategoryOptions error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            @synchronized (self) {
                cachedCategory = nil;
                cachedCategoryOptions = 0;
            }
        });
    }
}
 
- (NSString *)description {
    NSString *format = @"RTC_OBJC_TYPE(RTCAudioSession): {\n"
                      "  category: %@\n"
                      "  categoryOptions: %ld\n"
                      "  mode: %@\n"
                      "  isActive: %d\n"
                      "  sampleRate: %.2f\n"
                      "  IOBufferDuration: %f\n"
                      "  outputNumberOfChannels: %ld\n"
                      "  inputNumberOfChannels: %ld\n"
                      "  outputLatency: %f\n"
                      "  inputLatency: %f\n"
                      "  outputVolume: %f\n"
                      "}";
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    AVAudioSessionCategory category = session.category;
    AVAudioSessionCategoryOptions categoryOptions = session.categoryOptions;
    AVAudioSessionMode mode = session.mode;
    BOOL isActive = YES;
    double sampleRate = session.sampleRate;
    double preferredSampleRate = session.preferredSampleRate;
    NSTimeInterval IOBufferDuration = session.IOBufferDuration;
    NSInteger outputNumberOfChannels = session.outputNumberOfChannels;
    NSInteger inputNumberOfChannels = session.inputNumberOfChannels;
    NSTimeInterval outputLatency = session.outputLatency;
    NSTimeInterval inputLatency = session.inputLatency;
    float outputVolume = session.outputVolume;
    AVAudioSessionRouteDescription *currentRoute = session.currentRoute;
    NSLog(@"currentRout===>%@",currentRoute);
    NSString *description = [NSString stringWithFormat:format,
                                                    category, (long)categoryOptions, mode,
                                                    isActive, sampleRate, IOBufferDuration,
                                                    outputNumberOfChannels, inputNumberOfChannels,
                                                    outputLatency, inputLatency, outputVolume];
  
    return description;
}


#pragma mark - Notifications

- (void)handleInterruptionNotification:(NSNotification *)notification {
    NSNumber* typeNumber =
    notification.userInfo[AVAudioSessionInterruptionTypeKey];
    AVAudioSessionInterruptionType type =
    (AVAudioSessionInterruptionType)typeNumber.unsignedIntegerValue;
    switch (type) {
        case AVAudioSessionInterruptionTypeBegan:
            NSLog(@"Audio session interruption began.");
            //      self.isActive = NO;
            //      self.isInterrupted = YES;
            //      [self notifyDidBeginInterruption];
            break;
        case AVAudioSessionInterruptionTypeEnded: {
            NSLog(@"Audio session interruption ended.");
            //      self.isInterrupted = NO;
            //      [self updateAudioSessionAfterEvent];
            NSNumber *optionsNumber = notification.userInfo[AVAudioSessionInterruptionOptionKey];
            AVAudioSessionInterruptionOptions options = optionsNumber.unsignedIntegerValue;
            BOOL shouldResume = options & AVAudioSessionInterruptionOptionShouldResume;
            //      [self notifyDidEndInterruptionWithShouldResumeSession:shouldResume];
            break;
        }
    }
}

- (void)handleRouteChangeNotification:(NSNotification *)notification {
    // Get reason for current route change.
    NSNumber* reasonNumber =
    notification.userInfo[AVAudioSessionRouteChangeReasonKey];
    AVAudioSessionRouteChangeReason reason =
    (AVAudioSessionRouteChangeReason)reasonNumber.unsignedIntegerValue;
    NSLog(@"Audio route changed:");
    switch (reason) {
        case AVAudioSessionRouteChangeReasonUnknown:
            NSLog(@"Audio route changed: ReasonUnknown");
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"Audio route changed: NewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"Audio route changed: OldDeviceUnavailable");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@"Audio route changed: CategoryChange to :%@",
                  [AVAudioSession sharedInstance].category);
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"Audio route changed: Override");
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"Audio route changed: WakeFromSleep");
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"Audio route changed: NoSuitableRouteForCategory");
            break;
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
            NSLog(@"Audio route changed: RouteConfigurationChange");
            break;
    }
    AVAudioSessionRouteDescription* previousRoute =
    notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
    // Log previous route configuration.
    NSLog(@"Previous route: %@\nCurrent route:%@",
           previousRoute, [AVAudioSession sharedInstance].currentRoute);
    
//    [self.session setActive:YES error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testAudioSession" object:nil];
}

- (void)handleMediaServicesWereLost:(NSNotification *)notification {
    NSLog(@"Media services were lost.");
//    [self updateAudioSessionAfterEvent];
//    [self notifyMediaServicesWereLost];
}

- (void)handleMediaServicesWereReset:(NSNotification *)notification {
    NSLog(@"Media services were reset.");
//    [self updateAudioSessionAfterEvent];
//    [self notifyMediaServicesWereReset];
}

- (void)handleSilenceSecondaryAudioHintNotification:(NSNotification *)notification {
    // TODO(henrika): just adding logs here for now until we know if we are ever
    // see this notification and might be affected by it or if further actions
    // are required.
    NSNumber *typeNumber =
    notification.userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey];
    AVAudioSessionSilenceSecondaryAudioHintType type =
    (AVAudioSessionSilenceSecondaryAudioHintType)typeNumber.unsignedIntegerValue;
    switch (type) {
        case AVAudioSessionSilenceSecondaryAudioHintTypeBegin:
            NSLog(@"Another application's primary audio has started.");
            break;
        case AVAudioSessionSilenceSecondaryAudioHintTypeEnd:
            NSLog(@"Another application's primary audio has stopped.");
            break;
    }
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    BOOL isInterrupted = YES; //self.isInterrupted;
    NSLog(@"Application became active after an interruption. Treating as interruption "
           "end. isInterrupted changed from %d to 0.",
           isInterrupted);
//    if (isInterrupted) {
//        self.isInterrupted = NO;
//        [self updateAudioSessionAfterEvent];
//    }
    // Always treat application becoming active as an interruption end event.
//    [self notifyDidEndInterruptionWithShouldResumeSession:YES];
}
@end
