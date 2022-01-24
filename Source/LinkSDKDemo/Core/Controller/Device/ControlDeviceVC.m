//
//  ControlDeviceVC.m
//  QCFrameworkDemo
//
//

#import "ControlDeviceVC.h"
#import "TIoTCoreFoundation.h"

#import "TIoTCoreAlertView.h"

#import "TIoTCoreTimerListVC.h"
#import "TIoTTRTCSessionManager.h"
#import "TIoTCoreSocketCover.h"
#import <YYModel/YYModel.h>
#import "TIoTCoreUtil.h"
#import "TIoTCoreRequestObject.h"
#import "TIoTTRTCUIManage.h"
#import "HXYNotice.h"

@interface ControlDeviceVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) DeviceInfo *ci;
@property (weak, nonatomic) IBOutlet UILabel *theme;
@property (weak, nonatomic) IBOutlet UILabel *navBar;
@property (weak, nonatomic) IBOutlet UILabel *content1;
@property (weak, nonatomic) IBOutlet UILabel *content2;
@property (weak, nonatomic) IBOutlet UILabel *timing;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary *reportData;
@property (nonatomic, strong) TIOTtrtcPayloadModel *reportModel;
@property (nonatomic, strong) DeviceInfo *deviceInfomation;
@end

@implementation ControlDeviceVC{
    TRTCCallingAuidoViewController *_callAudioVC;
    TRTCCallingVideoViewController *_callVideoVC;
    //socket payload
    TIOTtrtcPayloadParamModel *_deviceParam;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [HXYNotice addReportDeviceListener:self reaction:@selector(deviceReport:)];
    self.deviceInfomation.deviceId = self.deviceInfo[@"DeviceId"];
    
    [[TIoTCoreDeviceSet shared] activePushWithDeviceIds:@[self.deviceInfo[@"DeviceId"]] complete:^(BOOL success, id data) {
        
    }];
    
    [TIoTCoreDeviceSet shared].deviceChange = ^(NSDictionary *changeInfo) {
        if ([self.deviceInfo[@"DeviceId"] isEqualToString:changeInfo[@"DeviceId"]]) {
            [self receiveData:changeInfo];
        }
    };
    
    
    [[TIoTCoreDeviceSet shared] getDeviceDetailWithProductId:self.deviceInfo[@"ProductId"] deviceName:self.deviceInfo[@"DeviceName"] success:^(id  _Nonnull responseObject) {
        
        self.ci = responseObject;
        
        DDLogVerbose(@"上清==%@",self.ci.zipData);
        [self refresh];
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
    
}

- (void)zipData:(NSDictionary *)deviceChange {
    
    NSDictionary *payloadDic = [NSString base64Decode:deviceChange[@"Payload"]];
    
    NSDictionary *reportDic = payloadDic[@"state"][@"reported"];
    if (reportDic == nil) {
        reportDic = payloadDic[@"payload"][@"state"];
    }
    if (reportDic == nil) {
        reportDic = payloadDic[@"params"];
    }
    
    
    NSArray *keys = [reportDic allKeys];
    for (NSString *key in keys) {
        for (NSMutableDictionary *propertie in self.ci.zipData) {
            if ([key isEqualToString:propertie[@"id"]]) {
//                NSMutableDictionary *dic = propertie[@"status"];
                [propertie setObject:reportDic[key] forKey:@"Value"];
                break;
            }
        }
    }
}

#pragma mark -

- (void)refresh
{
//    self.theme.text = self.ci.theme;
    self.navBar.text = [self.ci.navBar[@"visible"] boolValue] ? NSLocalizedString(@"display", @"显示") : NSLocalizedString(@"no_display", @"不显示");
    NSString *templateId = self.ci.navBar[@"templateId"];
    if (templateId && templateId.length > 0) {
        
        for (NSDictionary *item in self.ci.zipData) {
            if ([templateId isEqualToString:item[@"id"]]) {
                self.content1.text = item[@"name"];
                break;
            }
        }
        
    }
    else
    {
        self.content1.text = NSLocalizedString(@"no_display", @"不显示");
    }
    self.content2.text = [self.ci.navBar[@"timingProject"] boolValue] ? NSLocalizedString(@"cloud_timing", @"云端定时") : NSLocalizedString(@"no_display", @"不显示");
    self.timing.text = self.ci.timingProject ? NSLocalizedString(@"display", @"显示")  : NSLocalizedString(@"no_display", @"不显示");
    
    [self.tableView reloadData];
    
}
#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.ci.zipData) {
        return self.ci.zipData.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tina"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tina"];
    }
    
    
    NSDictionary *item = self.ci.zipData[indexPath.row];
    cell.textLabel.text = item[@"name"];
    
    NSDictionary *define = item[@"define"];
    NSString *contentText;
    if ([@"int" isEqualToString:define[@"type"]] || [@"float" isEqualToString:define[@"type"]]) {
        contentText = [NSString stringWithFormat:@"%@%@",item[@"status"][@"Value"],define[@"unit"]];
    }
    else if ([@"enum" isEqualToString:define[@"type"]] || [@"bool" isEqualToString:define[@"type"]] || [@"stringrenum" isEqualToString:define[@"type"]])
    {
        NSString *key = [NSString stringWithFormat:@"%@",item[@"status"][@"Value"]];
        contentText = define[@"mapping"][key];
    }
    cell.detailTextLabel.text = contentText;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.ci.zipData[indexPath.row]?:@{};
    
    if (indexPath.row == 0 || indexPath.row == 1) {
        //视频 语音呼叫
        if (dic.allKeys.count != 0) {
            //trtc特殊判断逻辑
            NSString *key = dic[@"id"];
            if ([key isEqualToString:TIoTTRTCaudio_call_status] || [key isEqualToString:TIoTTRTCvideo_call_status]) {
                self.reportData = dic;
                [self reportDeviceData:@{key: @1}];
                return;
            }
        }
    }
}

//下发数据
- (void)reportDeviceData:(NSDictionary *)deviceReport {
    
    //在这里都是主动呼叫，不存在被动
    NSString *key = self.reportData[@"id"];
//    NSNumber *statusValue = self.reportData[@"status"][@"Value"];
    
    if (![[TIoTCoreUserManage shared].sys_call_status isEqualToString:@"-1"]) {
        DDLogInfo(@"--!!-%@---",[TIoTCoreUserManage shared].sys_call_status);
        if ([key isEqualToString:@"_sys_audio_call_status"]) {
            if (![[TIoTCoreUserManage shared].sys_call_status isEqualToString:@"0"]) {
                [MBProgressHUD showError:NSLocalizedString(@"other_part_busy", @"对方正忙...") toView:self.view];
                return;
            }
        }else if ([key isEqualToString:@"_sys_video_call_status"]) {
            if (![[TIoTCoreUserManage shared].sys_call_status isEqualToString:@"0"]) {
                [MBProgressHUD showError:NSLocalizedString(@"other_part_busy", @"对方正忙...") toView:self.view];
                return;
            }
        }
    }
    
    NSMutableDictionary *trtcReport = [deviceReport mutableCopy];
    NSString *userId = [TIoTCoreUserManage shared].userId;
    if (userId) {
//        [trtcReport setValue:userId forKey:@"_sys_userid"];
    }
    NSString *username = [TIoTCoreUserManage shared].nickName;
    if (username) {
        [trtcReport setValue:username forKey:@"username"];
    }

    //拼接主呼叫方_sys_caller_id
    [trtcReport setValue:[TIoTCoreUserManage shared].userId?:@"" forKey:@"_sys_caller_id"];
    
    //拼接被呼叫方_sys_called_id
    NSString *deviceIDString = [NSString stringWithFormat:@"%@/%@",self.deviceInfo[@"ProductId"]?:@"",self.deviceInfo[@"DeviceName"]?:@""];
    [trtcReport setValue:deviceIDString forKey:@"_sys_called_id"];
    
    NSDictionary *tmpDic = @{
                                @"ProductId":self.deviceInfo[@"ProductId"],
                                @"DeviceName":self.deviceInfo[@"DeviceName"],
//                                @"Data":[NSString objectToJson:deviceReport],
                                @"Data":[NSString objectToJson:trtcReport]
                            };
    
    [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
    
    //主动呼叫，开始拨打
    TIoTTRTCSessionCallType audioORvideo = TIoTTRTCSessionCallType_audio;//audio
    BOOL isTRTCDevice = NO;
    for (NSString *prototype in deviceReport.allKeys) {
        
        NSString *protoValue = deviceReport[prototype];
        if ([prototype isEqualToString:TIoTTRTCaudio_call_status] || [prototype isEqualToString:TIoTTRTCvideo_call_status]) {
         
            if (protoValue.intValue == 1) {
                isTRTCDevice = YES;
                
                if ([prototype isEqualToString:TIoTTRTCaudio_call_status]) {
                    audioORvideo = TIoTTRTCSessionCallType_audio;
                }else {
                    audioORvideo = TIoTTRTCSessionCallType_video;
                }
                break;
            }
        }
    }
    if (isTRTCDevice) {
        
//        [[TIoTTRTCUIManage sharedManager] trtccallDeviceFromPanel:audioORvideo withDevideId:[NSString stringWithFormat:@"%@/%@",self.deviceInfo[@"ProductId"]?:@"",self.deviceInfo[@"DeviceName"]?:@""]];
        [[TIoTTRTCUIManage sharedManager] trtcCallDeviceFromPanel:audioORvideo withDevideId:[NSString stringWithFormat:@"%@/%@",self.deviceInfo[@"ProductId"]?:@"",self.deviceInfo[@"DeviceName"]?:@""] reportDeviceDic:trtcReport];
    }
}

//收到上报
- (void)deviceReport:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    [self.deviceInfomation handleReportDevice:dic];
    
    [self reloadForBig];
    [self.tableView reloadData];
    
    
    NSDictionary *payloadDic = [NSString base64Decode:dic[@"Payload"]];
    DDLogInfo(@"\n----收到设备上报信息 payloadDic: %@---\n",payloadDic);
    DDLogInfo(@"\n---收到设备上报 userid---%@\n",[TIoTCoreUserManage shared].userId);
    
    if ([payloadDic.allKeys containsObject:@"params"]) {
        NSDictionary *paramsDic = payloadDic[@"params"];
        self.reportModel = [TIOTtrtcPayloadModel yy_modelWithJSON:payloadDic];
        if (paramsDic[@"_sys_audio_call_status"]) {
            [TIoTCoreUserManage shared].sys_call_status = self.reportModel.params._sys_audio_call_status;
        }else if (paramsDic[@"_sys_video_call_status"]) {
            [TIoTCoreUserManage shared].sys_call_status = self.reportModel.params._sys_video_call_status;
        }
    }
    
    
    if ([dic.allKeys containsObject:@"SubType"] && [dic.allKeys containsObject:@"DeviceId"]) {
        
        NSString *device_Id = dic[@"DeviceId"];
        if (![[NSString stringWithFormat:@"%@/%@",self.deviceInfo[@"ProductId"] , self.deviceInfo[@"DeviceName"]] isEqualToString:device_Id]) {
            return;
        }
        
        NSString *line_status = dic[@"SubType"];
        if ([line_status isEqualToString:@"Offline"]) {
            //下线
            [MBProgressHUD showError:@"设备已离线"];
            
        }else if ([line_status isEqualToString:@"Online"]) {
            
        }
    }
}

//刷新大按钮
- (void)reloadForBig
{

}

#pragma mark -

- (IBAction)delete:(id)sender {
    TIoTCoreAlertView *av = [[TIoTCoreAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleText];
    [av alertWithTitle:NSLocalizedString(@"confirm_delete_device", @"确定要删除设备吗？") message:NSLocalizedString(@"delete_toast_content", @"删除后数据无法直接恢复") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"delete", @"删除")];
    av.doneAction = ^(NSString * _Nonnull text) {
        
        [[TIoTCoreDeviceSet shared] deleteDeviceWithFamilyId:self.deviceInfo[@"FamilyId"] productId:self.deviceInfo[@"ProductId"] andDeviceName:self.deviceInfo[@"DeviceName"] success:^(id  _Nonnull responseObject) {
            [MBProgressHUD showSuccess:NSLocalizedString(@"delete_success", @"删除成功")];
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
            [MBProgressHUD showError:reason];
        }];
        
    };
    [av showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)toTimer:(id)sender {
    TIoTCoreTimerListVC *vc = [TIoTCoreTimerListVC new];
    vc.productId = self.deviceInfo[@"ProductId"];
    vc.deviceName = self.deviceInfo[@"DeviceName"];
    vc.actions = self.ci.zipData;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)modifyAlias:(id)sender {
    TIoTCoreAlertView *av = [[TIoTCoreAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
    [av alertWithTitle:NSLocalizedString(@"device_name", @"设备名称") message:NSLocalizedString(@"less20character", @"20字以内") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"verify", @"确认")];
    av.maxLength = 20;
    av.doneAction = ^(NSString * _Nonnull text) {
        if (text.length > 0) {
            [[TIoTCoreDeviceSet shared] modifyAliasName:text ByProductId:self.deviceInfo[@"ProductId"] andDeviceName:self.deviceInfo[@"DeviceName"] success:^(id  _Nonnull responseObject) {
                [MBProgressHUD showSuccess:NSLocalizedString(@"modify_success", @"修改成功")];
                self.title = text;
            } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                [MBProgressHUD showError:reason];
            }];
        }
    };
    av.defaultText = self.title;
    [av showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)toShareList:(id)sender {
    
    UIViewController *vc = [NSClassFromString(@"UsersOfDeviceVC") new];
    [vc setValue:self.deviceInfo forKey:@"deviceInfo"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)control:(UIButton *)sender {
    
    NSDictionary *firstItem = self.ci.zipData[0];
    
    //id为键,在取值范围内选值
    NSString *key = firstItem[@"id"];
    NSNumber *currentValue = firstItem[@"status"][@"Value"];
    
    NSNumber *aimValue;
    
    NSDictionary *define = firstItem[@"define"];
    if ([@"enum" isEqualToString:define[@"type"]] || [@"bool" isEqualToString:define[@"type"]]) {
        NSArray *values = [define[@"mapping"] allKeys];
        for (NSNumber *value in values) {
            if ([value integerValue] != [currentValue integerValue]) {
                aimValue = value;
                break;
            }
        }
    }
    else if ([@"int" isEqualToString:define[@"type"]] || [@"float" isEqualToString:define[@"type"]])
    {
        aimValue = @([define[@"max"] integerValue] - 1);
        
    }
    
    [self sendControlData:@{key:aimValue}];
    
}


- (void)sendControlData:(NSDictionary *)data {
    
    [[TIoTCoreDeviceSet shared] controlDeviceDataWithProductId:self.deviceInfo[@"ProductId"] deviceName:self.deviceInfo[@"DeviceName"] data:data success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:NSLocalizedString(@"send_success", @"发送成功")];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
    
}

- (void)receiveData:(NSDictionary *)deviceChange{
    
    [self zipData:deviceChange];
    [self.tableView reloadData];
}

- (DeviceInfo *)deviceInfomation
{
    if (!_deviceInfomation) {
        _deviceInfomation = [[DeviceInfo alloc] init];
    }
    return _deviceInfomation;
}


@end
