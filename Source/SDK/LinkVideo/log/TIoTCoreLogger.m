//
//  TIoTCoreLogger.m
//  TIoTLinkVideo
//

#import "TIoTCoreLogger.h"
NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreLogger ()
@property (nonatomic, strong)NSMutableString *log;
@property (nonatomic, strong)NSTimer *timer;
@end

@implementation TIoTCoreLogger

- (instancetype)init {
    self = [super init];
    if (self) {
        self.log = [[NSMutableString alloc] init];
        self.appuuid = @"appuuid";
        self.version = @"2.4.x+ios";
    }
    return self;
}

- (void)startLogging {
    _timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(reportLog) userInfo:nil repeats:YES];
}

- (void)stopLogging {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)addLog:(NSString *)message {
    @synchronized(self.log) {
        [self.log appendString:message];
    }
}

- (void)reportLog {
    if (self.log.length < 2) {
        return;
    }
    NSData *body = [self.log dataUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"https://rtlog.qvb.qcloud.com/upload/p2p.log?uuid=%@&version=%@&platform=iot-ios&type=data",self.appuuid, self.version]; //[self getAppUUID], [TIoTCoreXP2PBridge getSDKVersion]
    NSURL *urlString = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlString cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
//    [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
//            NSLog(@"log event: %@",response);
        }
    }];
    [task resume];

    @synchronized(self.log) {
        [self.log setString:@""];  // 清空日志
    }
}

@end

NS_ASSUME_NONNULL_END
