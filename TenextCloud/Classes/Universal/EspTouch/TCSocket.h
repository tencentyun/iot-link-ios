//
//  TCSocket.h
//  TCLinkModule
//
//  Created by erichmzhang(张恒铭) on 2018/9/12.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, TCSocketStatus) {
    TCSocketStatusClose = 0,
    TCSocketStatusOpening = 1,
    TCSocketStatusOpen = 2,
    TCSocketStatusClosing = 3,
    TCSocketStatusClosed = 4,
    TCSocketStatusError = 5
};

@class TCSocket;
@protocol TCSocketDelegate <NSObject>

- (void) onHandleSocketOpen:(TCSocket *)socket;
- (void) onHandleSocketClosed:(TCSocket *)socket;
- (void) onHandleDataReceived:(TCSocket *)socket data:(NSData *)data;

@end

@interface TCSocket : NSObject

@property (nonatomic, weak) id<TCSocketDelegate> deleagte;
@property (nonatomic, assign) TCSocketStatus status;

- (void) openWithIP:(NSString *)ip port:(UInt32)port;
- (void) close;
- (void) sendData:(NSData *)data;

@end


