//
//  ControlDeviceVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/5.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "ControlDeviceVC.h"
#import "TIoTCoreFoundation.h"

#import "TIoTCoreAlertView.h"

#import "TIoTCoreTimerListVC.h"
#import "TIoTTRTCSessionManager.h"
#import "TIoTCoreSocketCover.h"
#import <YYModel/YYModel.h>
#import "TIoTCoreUtil.h"

@interface ControlDeviceVC ()<UITableViewDelegate,UITableViewDataSource, TIoTTRTCSessionUIDelegate, TRTCCallingViewDelegate>

@property (nonatomic,strong) DeviceInfo *ci;
@property (weak, nonatomic) IBOutlet UILabel *theme;
@property (weak, nonatomic) IBOutlet UILabel *navBar;
@property (weak, nonatomic) IBOutlet UILabel *content1;
@property (weak, nonatomic) IBOutlet UILabel *content2;
@property (weak, nonatomic) IBOutlet UILabel *timing;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
    [TIoTCoreSocketManager shared].delegate = [TIoTCoreSocketCover shared];
    //TRTC UI Delegate
    [TIoTTRTCSessionManager sharedManager].uidelegate = self;

    [[TIoTCoreDeviceSet shared] activePushWithDeviceIds:@[self.deviceInfo[@"DeviceId"]] complete:^(BOOL success, id data) {
        
    }];
    
    [TIoTCoreDeviceSet shared].deviceChange = ^(NSDictionary *changeInfo) {
        if ([self.deviceInfo[@"DeviceId"] isEqualToString:changeInfo[@"DeviceId"]]) {
            [self receiveData:changeInfo];
        }
    };
    
    
    [[TIoTCoreDeviceSet shared] getDeviceDetailWithProductId:self.deviceInfo[@"ProductId"] deviceName:self.deviceInfo[@"DeviceName"] success:^(id  _Nonnull responseObject) {
        
        self.ci = responseObject;
        
        NSLog(@"上清==%@",self.ci.zipData);
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
    else if ([@"enum" isEqualToString:define[@"type"]] || [@"bool" isEqualToString:define[@"type"]])
    {
        NSString *key = [NSString stringWithFormat:@"%@",item[@"status"][@"Value"]];
        contentText = define[@"mapping"][key];
    }
    cell.detailTextLabel.text = contentText;
    return cell;
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
    
    
    //检测是否TRTC设备，是否在呼叫中
    NSDictionary *payloadDic = [NSString base64Decode:deviceChange[@"Payload"]];
    TIOTtrtcPayloadModel *model = [TIOTtrtcPayloadModel yy_modelWithJSON:payloadDic];
    if (model.params._sys_userid.length < 1) {
        model.params._sys_userid = deviceChange[@"DeviceId"];
    }

    if (model.params._sys_audio_call_status.intValue == 1 || model.params._sys_video_call_status.intValue == 1) {
        _deviceParam = model.params;
        
        [self isActiveCalling:_deviceParam._sys_userid];
    }
}

//主动呼叫的UI逻辑
- (BOOL)isActiveCalling:(NSString *)deviceUserID {
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC || _callVideoVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动,直接进房间
        [self didAcceptJoinRoom];
        return  YES;
    }
    
    
    //被呼叫了，点击接听后才进房间吧
    if (_deviceParam._sys_audio_call_status.intValue == 1) { //audio
        
        _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:_deviceParam._sys_userid];
        _callAudioVC.actionDelegate = self;
        _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:nil];

    }else if (_deviceParam._sys_video_call_status.intValue == 1) { //video
        
        _callVideoVC = [[TRTCCallingVideoViewController alloc] initWithOcUserID:_deviceParam._sys_userid];
        _callVideoVC.actionDelegate = self;
        _callVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TIoTCoreUtil topViewController] presentViewController:_callVideoVC animated:NO completion:^{
//            [[TIoTTRTCSessionManager sharedManager] enterRoom];
        }];
    }
    
    return NO;
}


#pragma mark- TRTCCallingViewDelegate ui决定是否进入房间
- (void)didAcceptJoinRoom {
    //2.根据UI决定是否进入房间
    
    //开始准备进房间，通话中状态
//    NSDictionary *param = @{@"DeviceId":_deviceParam._sys_userid};
    
    //TRTC设备需要通话，开始通话,防止不是trtc设备的通知
    [[TIoTTRTCSessionManager sharedManager] preEnterRoom:_deviceParam failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
        [MBProgressHUD showError:reason];
    }];
}


#pragma mark -TIoTTRTCSessionUIDelegate
//呼起被叫页面，如果当前正在主叫页面，则外界UI不处理

- (void)showRemoteUser:(NSString *)remoteUserID {
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动
        [_callAudioVC OCEnterUserWithUserID:remoteUserID];
    }else {
        [_callVideoVC OCEnterUserWithUserID:remoteUserID];
    }
}

- (void)exitRoom:(NSString *)remoteUserID {
    [_callAudioVC remoteDismiss];
    [_callVideoVC remoteDismiss];
    
    _callAudioVC = nil;
    _callVideoVC = nil;
}

@end
