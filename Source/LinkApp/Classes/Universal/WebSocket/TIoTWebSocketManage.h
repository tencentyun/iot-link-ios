//
//  WCWebSocketManage.h
//  TenextCloud
//
//

#import <Foundation/Foundation.h>
//#import "SocketRocket.h"
#import "TIoTCoreSocketManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^didReceiveMessage) (BOOL sucess, NSDictionary *data);

@interface TIoTWebSocketManage : NSObject

/** 连接状态 */
@property (nonatomic,assign) WCReadyState socketReadyState;
//@property (nonatomic,  copy) void (^didReceiveMessage)(BOOL sucess, NSDictionary *data);

+(instancetype)shared;
- (void)SRWebSocketOpen;//开启连接
- (void)SRWebSocketClose;//关闭连接
//- (void)sendData:(NSDictionary *)paramDic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess;//发送数据


/// 监听设备状态
//- (void)registerDevicecActive;

@end

NS_ASSUME_NONNULL_END
