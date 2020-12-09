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


@interface TIoTCoreSocketCover : NSObject

+ (instancetype)shared;

@property (nonatomic,strong) void (^deviceChange)(NSDictionary *changeInfo);

//发送数据
- (void)sendData:(NSDictionary *)paramDic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess;

/// 监听设备状态的所需参数
/// @param paramDic 本类发送数据 sendData 函数 actionParams字典
/// @param dic @{@"Platform":@"",
//               @"RequestId":,
//               @"action":@"",
//               @"AppKey":@”“,};
/// @param requestURL 本类发送数据 sendData 函数参数中的 requestURL
/// @param sucess 本类发送数据 sendData 函数参数中的 sucess
- (NSDictionary *)sendDataDictionaryWithParamDic:(NSDictionary *)paramDic withArgumentDic:(NSDictionary *)dic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess;


/// 监听设备状态
- (void)registerDeviceActive:(NSArray *)deviceIds complete:(didReceiveMessage)success;

/// 注册监听设备时，构建发送数据参数
/// @param deviceIds 本类registerDeviceActive:方法 ActionParams字典
/// @param actionName actionName 接口
/// @param success 本类发送数据 sendData 函数参数中的 sucess
- (NSDictionary *)registerDeviceParamterActive:(NSArray *)deviceIds withAction:(NSString *)actionName complete:(didReceiveMessage)success;

@end

NS_ASSUME_NONNULL_END
