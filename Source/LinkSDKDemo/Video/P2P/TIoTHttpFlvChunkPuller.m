//
//  TIoTHttpFlvChunkPuller.m
//  LinkSDKDemo
//

#import "TIoTHttpFlvChunkPuller.h"

@interface TIoTHttpFlvChunkPuller () <NSURLSessionDataDelegate>

@property (nonatomic, copy,   readwrite) NSString *tag;
@property (nonatomic, copy,   readwrite) NSString *url;
@property (nonatomic, assign, readwrite) BOOL isRunning;
@property (nonatomic, assign, readwrite) uint64_t receivedBytes;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSOperationQueue *delegateQueue;
@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation TIoTHttpFlvChunkPuller

- (instancetype)initWithTag:(NSString *)tag url:(NSString *)url {
    self = [super init];
    if (self) {
        _tag = [tag copy] ?: @"";
        _url = [url copy] ?: @"";
        _delegateQueue = [[NSOperationQueue alloc] init];
        _delegateQueue.maxConcurrentOperationCount = 1;
        _delegateQueue.name = [NSString stringWithFormat:@"com.tencent.iot.httpflv.%@", _tag];
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

#pragma mark - Public

- (void)start {
    if (self.isRunning) {
        return;
    }
    if (self.url.length == 0) {
        NSLog(@"[HttpFlvPuller][%@] start failed: empty url", self.tag);
        return;
    }

    NSURL *nsurl = [NSURL URLWithString:self.url];
    if (!nsurl) {
        NSLog(@"[HttpFlvPuller][%@] start failed: invalid url=%@", self.tag, self.url);
        return;
    }

    // 流式请求配置：请求超时用于建连，资源整体超时置 0（不限）
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 30;
    config.timeoutIntervalForResource = 0;
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    config.URLCache = nil;
    config.HTTPShouldUsePipelining = YES;
    config.HTTPMaximumConnectionsPerHost = 4;
    // 拉流常连接本地 SDK 提供的 127.0.0.1 http 服务，允许明文
    config.allowsCellularAccess = YES;

    self.session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:self.delegateQueue];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    request.HTTPMethod = @"GET";
    // 声明可接受分块传输编码
    [request setValue:@"chunked" forHTTPHeaderField:@"Transfer-Encoding"];
    [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];

    if (self.dumpFilePath.length > 0) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:self.dumpFilePath]) {
            [fm removeItemAtPath:self.dumpFilePath error:nil];
        }
        [fm createFileAtPath:self.dumpFilePath contents:nil attributes:nil];
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.dumpFilePath];
    }

    self.receivedBytes = 0;
    self.isRunning = YES;
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];

    NSLog(@"[HttpFlvPuller][%@] start url=%@", self.tag, self.url);
}

- (void)stop {
    if (!self.isRunning && self.task == nil && self.session == nil) {
        return;
    }
    self.isRunning = NO;

    [self.task cancel];
    self.task = nil;

    [self.session invalidateAndCancel];
    self.session = nil;

    if (self.fileHandle) {
        @try {
            [self.fileHandle closeFile];
        } @catch (__unused NSException *e) {}
        self.fileHandle = nil;
    }

    NSLog(@"[HttpFlvPuller][%@] stop, total received: %llu bytes", self.tag, self.receivedBytes);
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        NSLog(@"[HttpFlvPuller][%@] response status=%ld headers=%@",
              self.tag, (long)httpResp.statusCode, httpResp.allHeaderFields);

        if ([self.delegate respondsToSelector:@selector(puller:didReceiveResponse:)]) {
            [self.delegate puller:self didReceiveResponse:httpResp];
        }

        if (httpResp.statusCode != 200) {
            completionHandler(NSURLSessionResponseCancel);
            return;
        }
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    if (data.length == 0) {
        return;
    }
    self.receivedBytes += data.length;

    if (self.fileHandle) {
        @try {
            [self.fileHandle writeData:data];
        } @catch (__unused NSException *e) {}
    }

    if ([self.delegate respondsToSelector:@selector(puller:didReceiveChunk:)]) {
        [self.delegate puller:self didReceiveChunk:data];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    NSLog(@"[HttpFlvPuller][%@] complete, error=%@", self.tag, error);
    self.isRunning = NO;

    if (self.fileHandle) {
        @try {
            [self.fileHandle closeFile];
        } @catch (__unused NSException *e) {}
        self.fileHandle = nil;
    }

    if ([self.delegate respondsToSelector:@selector(puller:didFinishWithError:)]) {
        [self.delegate puller:self didFinishWithError:error];
    }
}

@end
