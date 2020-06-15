//
//  QCSocketManager.h
//  QCAccount
//
//  Created by Wp on 2019/9/27.
//  Copyright © 2019 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


typedef void(^didReceiveMessage) (BOOL sucess, NSDictionary *data);


@interface QCSocketCover : NSObject

+ (instancetype)shared;

@property (nonatomic,strong) void (^deviceChange)(NSDictionary *changeInfo);

- (void)sendData:(NSDictionary *)paramDic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess;//发送数据

/// 监听设备状态
- (void)registerDeviceActive:(NSArray *)deviceIds complete:(didReceiveMessage)success;


@end

NS_ASSUME_NONNULL_END
