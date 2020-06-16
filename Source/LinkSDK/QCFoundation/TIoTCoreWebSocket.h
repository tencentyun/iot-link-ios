//
//   Copyright 2012 Square Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import <Foundation/Foundation.h>
#import <Security/SecCertificate.h>

typedef NS_ENUM(NSInteger, QCReadyState) {
    QC_CONNECTING   = 0,
    QC_OPEN         = 1,
    QC_CLOSING      = 2,
    QC_CLOSED       = 3,
};

typedef enum QCStatusCode : NSInteger {
    // 0–999: Reserved and not used.
    QCStatusCodeNormal = 1000,
    QCStatusCodeGoingAway = 1001,
    QCStatusCodeProtocolError = 1002,
    QCStatusCodeUnhandledType = 1003,
    // 1004 reserved.
    QCStatusNoStatusReceived = 1005,
    QCStatusCodeAbnormal = 1006,
    QCStatusCodeInvalidUTF8 = 1007,
    QCStatusCodePolicyViolated = 1008,
    QCStatusCodeMessageTooBig = 1009,
    QCStatusCodeMissingExtension = 1010,
    QCStatusCodeInternalError = 1011,
    QCStatusCodeServiceRestart = 1012,
    QCStatusCodeTryAgainLater = 1013,
    // 1014: Reserved for future use by the WebSocket standard.
    QCStatusCodeTLSHandshake = 1015,
    // 1016–1999: Reserved for future use by the WebSocket standard.
    // 2000–2999: Reserved for use by WebSocket extensions.
    // 3000–3999: Available for use by libraries and frameworks. May not be used by applications. Available for registration at the IANA via first-come, first-serve.
    // 4000–4999: Available for use by applications.
} QCStatusCode;

@class QCWebSocket;

extern NSString *const QCWebSocketErrorDomain;
extern NSString *const QCHTTPResponseErrorKey;

#pragma mark - QCWebSocketDelegate

@protocol QCWebSocketDelegate;

#pragma mark - QCWebSocket

@interface QCWebSocket : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id <QCWebSocketDelegate> delegate;

@property (nonatomic, readonly) QCReadyState readyState;
@property (nonatomic, readonly, retain) NSURL *url;


@property (nonatomic, readonly) CFHTTPMessageRef receivedHTTPHeaders;

// Optional array of cookies (NSHTTPCookie objects) to apply to the connections
@property (nonatomic, readwrite) NSArray * requestCookies;

// This returns the negotiated protocol.
// It will be nil until after the handshake completes.
@property (nonatomic, readonly, copy) NSString *protocol;

// Protocols should be an array of strings that turn into Sec-WebSocket-Protocol.
- (id)initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols allowsUntrustedSSLCertificates:(BOOL)allowsUntrustedSSLCertificates;
- (id)initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols;
- (id)initWithURLRequest:(NSURLRequest *)request;

// Some helper constructors.
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols allowsUntrustedSSLCertificates:(BOOL)allowsUntrustedSSLCertificates;
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols;
- (id)initWithURL:(NSURL *)url;

// Delegate queue will be dispatch_main_queue by default.
// You cannot set both OperationQueue and dispatch_queue.
- (void)setDelegateOperationQueue:(NSOperationQueue*) queue;
- (void)setDelegateDispatchQueue:(dispatch_queue_t) queue;

// By default, it will schedule itself on +[NSRunLoop QC_networkRunLoop] using defaultModes.
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

// QCWebSockets are intended for one-time-use only.  Open should be called once and only once.
- (void)open;

- (void)close;
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason;

// Send a UTF8 String or Data.
- (void)send:(id)data;

// Send Data (can be nil) in a ping message.
- (void)sendPing:(NSData *)data;

@end

#pragma mark - QCWebSocketDelegate

@protocol QCWebSocketDelegate <NSObject>

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(QCWebSocket *)webSocket didReceiveMessage:(id)message;

@optional

- (void)webSocketDidOpen:(QCWebSocket *)webSocket;
- (void)webSocket:(QCWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(QCWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)webSocket:(QCWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;

// Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
- (BOOL)webSocketShouldConvertTextFrameToString:(QCWebSocket *)webSocket;

@end

#pragma mark - NSURLRequest (QCCertificateAdditions)

@interface NSURLRequest (QCCertificateAdditions)

@property (nonatomic, retain, readonly) NSArray *QC_SSLPinnedCertificates;

@end

#pragma mark - NSMutableURLRequest (QCCertificateAdditions)

@interface NSMutableURLRequest (QCCertificateAdditions)

@property (nonatomic, retain) NSArray *QC_SSLPinnedCertificates;

@end

#pragma mark - NSRunLoop (QCWebSocket)

@interface NSRunLoop (QCWebSocket)

+ (NSRunLoop *)QC_networkRunLoop;

@end
