//
//  TIoTDemoWebSocketManager.m
//  LinkSDKDemo
//
//

#import "TIoTDemoWebSocketManager.h"
#import "TIoTAppEnvironment.h"
//#import "TIoTAppUtilOC.h"
#import "TIoTCoreRequestObj.h"
#import "ReachabilityManager.h"
#import "TIoTCoreSocketCover.h"
#import "TIoTCoreDeviceSet.h"
#import "TIOTTRTCModel.h"
#import "TIoTTRTCSessionManager.h"
#import "TIoTTRTCUIManage.h"
#import "TIoTCoreUtil.h"
#import "NSString+Extension.h"
#import "TIoTCoreUserManage.h"
#import "HXYNotice.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define WeakSelf(type)  __weak typeof(type) weak##type = type;

static NSString *registDeviceReqID = @"5001";
static NSString *heartBeatReqID = @"5002";

@interface TIoTDemoWebSocketManager ()<QCSocketManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *reqArray;
@property (nonatomic, strong) NSMutableSet *trtcDeviceIds;
@end

@implementation TIoTDemoWebSocketManager

+(instancetype)shared{
    static TIoTDemoWebSocketManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self instanceSocketManager];
        [self registerNetworkNotifications];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)instanceSocketManager {
    self.trtcDeviceIds = [NSMutableSet set];
//    [TIoTCoreSocketManager shared].socketedRequestURL = [TIoTCoreAppEnvironment shareEnvironment].wsUrl;
//    [TIoTCoreSocketManager shared].socketedRequestURL = [NSString stringWithFormat:@"%@?uin=%@",[TIoTCoreAppEnvironment shareEnvironment].wsUrl,TIoTAPPConfig.GlobalDebugUin];
    [TIoTCoreSocketManager shared].delegate = self;
    
    //TRTC UI Delegate
    [TIoTTRTCSessionManager sharedManager].uidelegate = TIoTTRTCUIManage.sharedManager;
}

- (void)registerNetworkNotifications{
    [HXYNotice addHeartBeatListener:self reaction:@selector(initHeartBeat:)];
    [HXYNotice addActivePushListener:self reaction:@selector(registerDevicecActive:)];

    [[NetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(NetworkReachabilityStatus status) {
        switch (status) {
            case NetworkReachabilityStatusUnknown:
                DDLogVerbose(@"状态不知道");
                break;
            case NetworkReachabilityStatusNotReachable:
                DDLogWarn(@"没网络");
                // RTC App端和设备端通话中 断网监听
                [HXYNotice postCallingDisconnectNet];
                break;
            case NetworkReachabilityStatusReachableViaWiFi:
                DDLogVerbose(@"WIFI");
                [self SRWebSocketOpen];
                break;
            case NetworkReachabilityStatusReachableViaWWAN:
                DDLogVerbose(@"移动网络");
                [self SRWebSocketOpen];
                break;
            default:
                break;
        }
    }];
    
    [[NetworkReachabilityManager sharedManager] startMonitoring];
    
}

/// 订阅
- (void)registerDevicecActive:(NSNotification *)noti {
    
    NSArray *deviceIds = noti.object;
    if (deviceIds) {
        [self.trtcDeviceIds addObjectsFromArray:deviceIds];
    }
    
    if (self.trtcDeviceIds.count == 0) {
        return;
    }
    [[TIoTDemoWebSocketManager shared] sendActiveData:self.trtcDeviceIds.allObjects withRequestURL:@"ActivePush" complete:^(BOOL sucess, NSDictionary * _Nonnull data) {
        if (sucess) {

        }
    }];
}

-(void)SRWebSocketOpen{
    
    [[TIoTCoreSocketManager shared] socketOpen];
    [NSObject cancelPreviousPerformRequestsWithTarget:[TIoTTRTCUIManage sharedManager] selector:@selector(callingHungupAction) object:nil];
}

-(void)SRWebSocketClose{
    
    [[TIoTCoreSocketManager shared] socketClose];
    [self destoryHeartBeat];
}

#pragma mark - QCSocketManagerDelegate delegete
- (void)socketDidOpen:(TIoTCoreSocketManager *)manager {
    DDLogInfo(@"************************** socket 连接成功************************** ");
    [self registerDevicecActive:nil];

    [HXYNotice addSocketConnectSucessPost];
}

- (void)socket:(TIoTCoreSocketManager *)manager didFailWithError:(NSError *)error {
    DDLogError(@"************************** socket 连接失败************************** ");
}

- (void)socket:(TIoTCoreSocketManager *)manager didReceiveMessage:(id)message {
    DDLogInfo(@"************************** socket 接收消息成功************************** ");
    [self handleReceivedMessage:message];
}

- (void)socket:(TIoTCoreSocketManager *)manager didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    DDLogWarn(@"************************** socket连接断开************************** ");
//    [self SRWebSocketClose];
    [MBProgressHUD showError:@"socket连接断开"];
}


- (void)deviceReceivedData:(NSDictionary *)data{
    BOOL sucess = YES;
    if (![NSObject isNullOrNilWithObject:data[@"data"]]) {
        sucess = YES;
    }
    else{
        sucess = NO;
    }
    
    NSString *reqID = [NSString stringWithFormat:@"%@",data[@"reqId"]];
    TIoTCoreRequestObj *reqObj = self.reqArray[reqID];
    
    if (reqObj.sucess) {
        reqObj.sucess(sucess, data[@"data"]);
        [self.reqArray removeObjectForKey:reqID];
    }
}

//监听到的设备上报信息
- (void)deviceInfo:(NSDictionary *)deviceInfo{
    [HXYNotice addReportDevicePost:deviceInfo];
    
//    [[TIoTTRTCUIManage sharedManager] receiveDeviceData:deviceInfo?:@{}];
    [[TIoTTRTCUIManage sharedManager] trtcReceiveDeviceData:deviceInfo?:@{}];

}

- (void)handleReceivedMessage:(id)message{
    NSDictionary *dic = [NSString jsonToObject:message];
    DDLogInfo(@"message:%@",dic);
    NSString *reqId = [NSString stringWithFormat:@"%@",dic[@"reqId"]];
    if ([NSObject isNullOrNilWithObject:dic[@"reqId"]])
    {
        if ([dic[@"action"] isEqualToString:@"DeviceChange"]) {
            [self deviceInfo:dic[@"params"]];
            return;
        }
    }
    
    if ([heartBeatReqID isEqualToString:reqId]) {//心跳回包
        return;
    }
    
    if ([registDeviceReqID isEqualToString:reqId]) {//
        [self deviceReceivedData:dic];
        return;
    }
    
    
    
    BOOL sucess = YES;
    NSDictionary *result = nil;
    
    if (![NSObject isNullOrNilWithObject:dic[@"data"]]) {
        if (dic[@"data"][@"Response"][@"Error"]) {
            [MBProgressHUD showError:dic[@"data"][@"Response"][@"Error"][@"Message"]];
            sucess = NO;
            result = dic[@"data"][@"Response"][@"Error"];
        }
        if ([dic[@"data"][@"result"] isEqualToString:@"hello world"]) {
            return;
        }
    }
    else{
        [MBProgressHUD showError:dic[@"error_message"]];
        sucess = NO;
        result = dic;
    }
    
    
    NSString *reqIDStr = [NSString stringWithFormat:@"%@",reqId];
    TIoTCoreRequestObj *reqObj = self.reqArray[reqIDStr];
    if(reqObj.sucess){
        if (sucess) {
            if ([NSObject isNullOrNilWithObject:dic[@"data"][@"Response"][@"Data"]]) {
                
                reqObj.sucess(sucess,sucess ? dic[@"data"][@"Response"] : [NSDictionary dictionary]);
            }
            else{
                reqObj.sucess(sucess,sucess ? dic[@"data"][@"Response"][@"Data"] : [NSDictionary dictionary]);
            }
        }
        else{
            reqObj.sucess(sucess, result);
        }
        [self.reqArray removeObjectForKey:reqIDStr];
    }
    
}

//初始化心跳
- (void)initHeartBeat:(NSNotification *)noti
{
    NSArray *deviceIds = noti.object;
    
    dispatch_main_async_safe(^{
        [self destoryHeartBeat];
        
        [[TIoTCoreSocketManager shared] startHeartBeatWith:deviceIds];
    })
}


//取消心跳
- (void)destoryHeartBeat
{

    [[TIoTCoreSocketManager shared] stopHeartBeat];
}

//ping
- (void)ping:(NSTimer *)timer {
    NSArray *deviceIds = timer.userInfo;

    if ([TIoTCoreSocketManager shared].socketReadyState == WC_OPEN) {
        
        NSData *data= [NSJSONSerialization dataWithJSONObject:[self heartData:deviceIds] options:NSJSONWritingPrettyPrinted error:nil];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        [[TIoTCoreSocketManager shared] sendData:dataDic];
    }
    
}


//心跳数据
- (NSDictionary *)heartData:(NSArray *)deviceIds {
    return @{
        @"action":[TIoTCoreAppEnvironment shareEnvironment].action,
        @"reqId":[[NSUUID UUID] UUIDString],
        @"params":@{
            @"Action": @"AppDeviceTraceHeartBeat",
            @"AccessToken":[TIoTCoreUserManage shared].accessToken,
            @"RequestId":@"weichuan-client",
            @"ActionParams": @{
                @"DeviceIds": deviceIds
            }
        }
    };
}

//判断是否重新登录
- (BOOL)needLogin{
    // 注释原有逻辑
//    return [TIoTAppUtilOC checkLogin];
    return YES;
}

//设备监听
- (void)sendActiveData:(NSArray *)deviceIds withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess{
    //每次请求需要判断登录是否失效
    if ([self needLogin]) {
        return;
    }
    
    NSDictionary *dataDic = [[TIoTCoreSocketCover shared] registerDeviceParamterActive:deviceIds withAction:requestURL complete:sucess];
    
    [[TIoTCoreSocketManager shared] sendData:dataDic];
    
}

- (void)sendData:(NSDictionary *)paramDic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess{
    //每次请求需要判断登录是否失效
    if ([self needLogin]) {
        return;
    }
    
    NSDictionary *dic = @{@"Platform":[TIoTCoreAppEnvironment shareEnvironment].platform,
                          @"Agent":[TIoTCoreAppEnvironment shareEnvironment].platform,
                          @"RequestId":[[NSUUID UUID] UUIDString],
                          @"action":[TIoTCoreAppEnvironment shareEnvironment].action,
                          @"AppKey":[TIoTCoreAppEnvironment shareEnvironment].appKey,
    };
    
    NSDictionary *dataDic = [[TIoTCoreSocketCover shared] sendDataDictionaryWithParamDic:paramDic withArgumentDic:dic withRequestURL:requestURL complete:sucess];
    [[TIoTCoreSocketManager shared] sendData:dataDic];
}

-(WCReadyState)socketReadyState{

    return [TIoTCoreSocketManager shared].socketReadyState;
}

#pragma mark - getter

- (NSMutableDictionary *)reqArray
{
    if (!_reqArray) {
        _reqArray = [NSMutableDictionary dictionary];
    }
    return _reqArray;
}
@end
