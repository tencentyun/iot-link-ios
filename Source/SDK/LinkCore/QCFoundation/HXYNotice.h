//
//  HXYNotice.h
//  zhipuzi
//
//

#import <Foundation/Foundation.h>

@interface HXYNotice : NSObject

+ (void)removeListener:(id)listener;

//添加动作完成之后通知
+ (void)addActionDownListener:(id)listener reaction:(SEL)selector;
+ (void)addActionDownPost;

//注册设备监听
+ (void)addActivePushListener:(id)listener reaction:(SEL)selector;
+ (void)addActivePushPost:(NSArray *)deviceIds;

//登录通知
+ (void)addLoginInListener:(id)listener reaction:(SEL)selector;
+ (void)addLoginInPost;


//登出通知
+ (void)addLoginOutListener:(id)listener reaction:(SEL)selector;
+ (void)addLoginOutPost;


//修改用户信息
+ (void)addModifyUserInfoListener:(id)listener reaction:(SEL)selector;
+ (void)addModifyUserInfoPost;


//websocket连接成功
+ (void)addSocketConnectSucessListener:(id)listener reaction:(SEL)selector;
+ (void)addSocketConnectSucessPost;

//开启心跳通知
+ (void)addHeartBeatListener:(id)listener reaction:(SEL)selector;
+ (void)postHeartBeat:(NSArray *)deviceIds;


//更新首页设备列表
+ (void)addUpdateDeviceListListener:(id)listener reaction:(SEL)selector;
+ (void)addUpdateDeviceListPost;


//设备上报通知
+ (void)addReportDeviceListener:(id)listener reaction:(SEL)selector;
+ (void)addReportDevicePost:(NSDictionary *)dic;



//家庭列表更新
+ (void)addUpdateFamilyListListener:(id)listener reaction:(SEL)selector;
+ (void)addUpdateFamilyListPost;


//房间列表更新
+ (void)addUpdateRoomListListener:(id)listener reaction:(SEL)selector;
+ (void)addUpdateRoomListPost;


//定时列表更新
+ (void)addUpdateTimerListListener:(id)listener reaction:(SEL)selector;
+ (void)addUpdateTimerListPost;

//成员更新
+ (void)addUpdateMemberListListener:(id)listener reaction:(SEL)selector;
+ (void)postUpdateMemberList;

//切换配网方式
+ (void)changeAddDeviceTypeListener:(id)listener reaction:(SEL)selector;
+ (void)postChangeAddDeviceType:(NSInteger)deviceType;

//重新登录获取ticketToken
+ (void)addLoginInTicketTokenListener:(id)listener reaction:(SEL)selector;
+ (void)postLoginInTicketToken:(NSString *)ticketToken;

//APP进入后台
+ (void)addAPPEnterBackgroundLister:(id)listener reaction:(SEL)selector;
+ (void)postAPPEnterBackground;

//APP进入前台
+ (void)addAPPEnterForegroundLister:(id)listener reaction:(SEL)selector;
+ (void)postAPPEnterForeground;

//接收分享设备
+ (void)addReceiveShareDeviceLister:(id)listener reaction:(SEL)selector;
+ (void)postReceiveShareDevice;

//蓝牙 停止搜索监听状态
+ (void)addBluetoothScanStopLister:(id)listener reaction:(SEL)selector;
+ (void)postBluetoothScanStop;

// RTC App端和设备端通话中 断网监听
+ (void)addCallingDisconnectNetLister:(id)listener reaction:(SEL)selector;
+ (void)postCallingDisconnectNet;

//P2P连接成功通知
+ (void)addCallingConnectP2PLister:(id)listener reaction:(SEL)selector;
+ (void)postCallingConnectP2P;

// 开始下发固件升级
+ (void)addFirmwareUpdateDataLister:(id)listener reaction:(SEL)selector;
+ (void)postFirmwareUpdateData;

//p2pVideo 页面收到上报
+ (void)addP2PVideoReportDeviceLister:(id)listener reaction:(SEL)selector;
+ (void)postP2PVideoDevicePayload:(NSDictionary *)dic;

//p2pVideo 结束退出通知
+ (void)addP2PVideoExitLister:(id)listener reaction:(SEL)selector;
+ (void)postP2PVIdeoExit:(BOOL)isOvertime;

//statusManager 是否通话中或弹出通话页面
+ (void)addStatusManagerCommunicateLister:(id)listener reaction:(SEL)selector;
+ (void)postStatusManagerCommunicateType:(NSInteger)isCommunicating;
@end
