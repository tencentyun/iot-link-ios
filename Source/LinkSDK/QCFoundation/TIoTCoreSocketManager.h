//
//  QCSocketManager.h
//  QCAccount
//
//  Created by Wp on 2019/9/27.
//  Copyright © 2019 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString *socketDidOpenNotification = @"socketDidOpenNotification";


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WCReadyState) {
    WC_CONNECTING   = 0,
    WC_OPEN         = 1,
    WC_CLOSING      = 2,
    WC_CLOSED       = 3,
};


@class QCSocketManager;
@protocol QCSocketManagerDelegate <NSObject>
@optional
- (void)socket:(QCSocketManager *)manager didReceiveMessage:(id)message;
- (void)socketDidOpen:(QCSocketManager *)manager;
- (void)socket:(QCSocketManager *)manager didFailWithError:(NSError *)error;
- (void)socket:(QCSocketManager *)manager didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end




@interface QCSocketManager : NSObject

@property (nonatomic,weak) id<QCSocketManagerDelegate> delegate;
/** 连接状态 */
@property (nonatomic,assign) WCReadyState socketReadyState;

+ (instancetype)shared;
- (void)socketOpen;//开启连接
- (void)socketClose;//关闭连接
- (void)sendData:(NSDictionary *)obj;//发送数据


@end

NS_ASSUME_NONNULL_END
