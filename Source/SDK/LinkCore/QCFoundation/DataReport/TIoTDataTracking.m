//
//  QCRequestClient.m
//  QCApiClient
//
//

#import "TIoTDataTracking.h"
#import "TIoTCoreRequestObject.h"
#import "TIoTCoreUserManage.h"

static NSString *LINKAPPVERSION = nil;

@implementation TIoTDataTracking

//data开始部分为两种配网方式的stepcodeor errorcode，便于做成功率统计，看以下的code部分，可以根据START|SUCC|FAIL字眼的code统计成功率

+ (void)logEvent:(NSString *)eventName params:(NSDictionary *)params {
    
    LINKAPPVERSION = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *userId = [TIoTCoreUserManage shared].userId;
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSTimeInterval currentTimestamp = [NSDate timeIntervalSinceReferenceDate];
    
    if (eventName.length > 0) {
        
        NSArray *postBody = @[@{
            @"appVersion": LINKAPPVERSION,
            @"event": eventName,        // 日志的事件 event,可根据这个event来做日志的模块搜索
            @"app": @"iot-link-ios",
            @"lid": uuid,               // 当前会话id
            @"born": [NSNumber numberWithDouble:currentTimestamp],    // 生成当前会话的时间
            @"path": @"/pages/net-configuration",  // 发生时间的页面
            @"level": @0,                          // 0 - INFO, 1 - WARN, 2 - ERROR
            @"uin": userId?:@"nil",                //连连的userid
//            @"reqId": @"",                       //接口的requestid可以拿来查找接入层和后台的日志
//            @"message": @"",                     //对于日志的简要说明
            @"data":params                         //具体的跳转参数
        }];
        
        [self postRequestWithEventParams:postBody];
    }
}



+ (void)postRequestWithEventParams:(NSArray *)params {
    
    NSURL *urlString = [NSURL URLWithString:@"https://iot.cloud.tencent.com/insight/event"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlString cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingFragmentsAllowed error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSLog(@"log event: %@",params);
        }
    }];
    [task resume];
}
@end
