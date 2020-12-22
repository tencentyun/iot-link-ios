//
//  TCSocket.m
//  TCLinkModule
//
//  Created by erichmzhang(张恒铭) on 2018/9/12.
//

#import "TCSocket.h"

@interface TCSocket() <NSStreamDelegate>
{
    CFReadStreamRef _readStream;
    CFWriteStreamRef _writeStream;
}
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) NSInteger openStreamCount;
@property (nonatomic, strong) NSThread *socketThread;
@end




@implementation TCSocket

- (instancetype)init {
    self = [super init];
    _openStreamCount = 0;
    _status = TCSocketStatusClose;
    _socketThread = [[NSThread alloc] initWithTarget:self selector:@selector(_openThreadRunloop) object:nil];
    [_socketThread setName:@"TCWebSocketThread"];
    [_socketThread start];
    return self;
}


- (void)openWithIP:(NSString *)ip port:(UInt32)port {
    NSDictionary *params = @{@"ip":ip,@"port":@(port)};
    [self performSelector:@selector(openWithParams:) onThread:self.socketThread withObject:params waitUntilDone:NO];
}

- (void) openWithParams:(NSDictionary *)dictionary {
    NSString *ip = dictionary[@"ip"];
    UInt32 port = [dictionary[@"port"] unsignedIntValue];
    [self _openWithIP:ip port:port];
}

- (void)_openWithIP:(NSString *)ip port:(UInt32)port {
    NSLog(@"[%@]Connecting..... ip:%@,port:%ld",self.class,ip,(long)port);
    self.status = TCSocketStatusOpening;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)ip, (UInt32)port, &_readStream, &_writeStream);
    self.outputStream = (__bridge NSOutputStream *)_writeStream;
    self.inputStream = (__bridge NSInputStream *)_readStream;
    self.outputStream.delegate = self;
    self.inputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
}

- (void) close {
    self.status = TCSocketStatusClosing;
    [_inputStream close];
    [_outputStream close];
    [self.inputStream setDelegate:nil];
    [self.outputStream setDelegate:nil];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _inputStream = nil;
    _outputStream = nil;
    self.status = TCSocketStatusClose;
    if (self.deleagte && [self.deleagte respondsToSelector:@selector(onHandleSocketClosed:)]) {
        [self.deleagte onHandleSocketClosed:self];
    }
}

- (void) dataReceived:(NSData *)data {
    if (self.deleagte && [self.deleagte respondsToSelector:@selector(onHandleDataReceived:data:)]) {
        [self.deleagte onHandleDataReceived:self data:data];
    }
}

- (void)sendData:(NSData *)data {
    if (!data) {
        NSLog(@"no data to send");
    }
    NSLog(@"Sending data %@",data);
    NSInteger result =  [self.outputStream write:data.bytes maxLength:data.length];
    NSLog(@"send data result is %ld",(long)result);
    if (result == -1) {
        NSLog(@"stream error is %@",self.outputStream.streamError);
    }
}




- (void) onHandleStreamOpenCompleted:(NSStream *)stream {

}

- (void) onHandleSocketOpenCompleted {
    if (self.deleagte && [self.deleagte respondsToSelector:@selector(onHandleSocketOpen:)]) {
        [self.deleagte onHandleSocketOpen:self];
    }
}



- (void) onHandleStreamErrorOccured:(NSStream *)stream {
    if (self.deleagte && [self.deleagte respondsToSelector:@selector(onHandleSocketClosed:)]) {
        [self.deleagte onHandleSocketClosed:self];
    }
}


- (void) readByteFromStream:(NSInputStream *)theStream {
    uint8_t buffer[1024];
    NSInteger len;
    while (self.inputStream.hasBytesAvailable) {
        len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
        if (len > 0) {
            NSData *receivedData = [NSData dataWithBytes:buffer length:len];
            [self dataReceived:receivedData];
        }
    }
}


#pragma mark - NSStream Delegate
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    //NSLog(@"stream[%@] event %lu", theStream,streamEvent);
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
            [self onHandleStreamOpenCompleted:theStream];
            break;
        case NSStreamEventHasSpaceAvailable:
            if (theStream == self.outputStream && self.status == TCSocketStatusOpening) {
                self.status = TCSocketStatusOpen;
                [self onHandleSocketOpenCompleted];
            }
            
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"%@",[theStream streamError].localizedDescription);
            if (theStream == self.outputStream) {
                if (self.deleagte && [self.deleagte respondsToSelector:@selector(onHandleSocketClosed:)]) {
                    [self.deleagte onHandleSocketClosed:self];
                }
            }
            break;
        case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
        case NSStreamEventHasBytesAvailable:
            if (theStream == self.inputStream) {
                [self readByteFromStream:(NSInputStream *)theStream];
            }
            break;
        default:
            NSLog(@"reach default");
            break;
    }
}

- (void) openThreadRunLoop {
    [self performSelector:@selector(_openThreadRunloop) onThread:self.socketThread withObject:nil waitUntilDone:NO];
}

- (void) _openThreadRunloop {
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

- (void)dealloc {
    [self performSelector:@selector(exitThread) onThread:self.socketThread withObject:nil waitUntilDone:NO];
}

- (void) exitThread {
    if (![NSThread isMainThread]) {
        [NSThread exit];
    }
}
@end
