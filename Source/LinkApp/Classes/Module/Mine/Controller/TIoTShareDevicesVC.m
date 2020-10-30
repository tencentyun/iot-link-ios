//
//  WCShareDevicesVC.m
//  TenextCloud
//
//  Created by Wp on 2020/3/16.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTShareDevicesVC.h"
#import "TIoTEquipmentTableViewCell.h"
#import "TIoTPanelVC.h"
#import "TIoTWebVC.h"
#import "TIoTAppEnvironment.h"

@interface TIoTShareDevicesVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArr;
@end

@implementation TIoTShareDevicesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[TIoTRequestObject shared] post:AppListUserShareDevices Param:@{@"Offset":@0,@"Limit":@50} success:^(id responseObject) {
        [self.dataArr addObjectsFromArray:responseObject[@"ShareDevices"]];
        
        [self updateDeviceStatus];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

//获取设备状态
- (void)updateDeviceStatus{
    NSArray *arr = [self.dataArr valueForKey:@"DeviceId"];
    
    if (arr.count > 0) {
        NSDictionary *dic = @{@"ProductId":self.dataArr[0][@"ProductId"],@"DeviceIds":arr};
        
        [[TIoTRequestObject shared] post:AppGetDeviceStatuses Param:dic success:^(id responseObject) {
            NSArray *statusArr = responseObject[@"DeviceStatuses"];
            
            NSMutableArray *tmpArr = [NSMutableArray array];
            for (NSDictionary *tmpDic in self.dataArr) {
                
                NSString *deviceId = tmpDic[@"DeviceId"];
                for (NSDictionary *statusDic in statusArr) {
                    if ([deviceId isEqualToString:statusDic[@"DeviceId"]]) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic addEntriesFromDictionary:tmpDic];
                        [dic setValue:statusDic[@"Online"] forKey:@"Online"];
                        [tmpArr addObject:dic];
                    }
                }
                
                
            }
            
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:tmpArr];
            [self.tableView reloadData];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }
}

#pragma mark - TableViewDelegate && TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTEquipmentTableViewCell *cell = [TIoTEquipmentTableViewCell cellWithTableView:tableView];
    cell.dataDic = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *devIds = @[self.dataArr[indexPath.row][@"DeviceId"]];
    if ([TIoTWebSocketManage shared].socketReadyState == WC_OPEN) {
        [HXYNotice addActivePushPost:devIds];
    }

//    TIoTPanelVC *vc = [[TIoTPanelVC alloc] init];
//    vc.title = [NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"AliasName"]];
//    vc.productId = self.dataArr[indexPath.row][@"ProductId"];
//    vc.deviceName = [NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"DeviceName"]];
//    vc.deviceDic = [self.dataArr[indexPath.row] mutableCopy];
//    [self.navigationController pushViewController:vc animated:YES];
    
    
    
    NSString *productIDString = self.dataArr[indexPath.row][@"ProductId"] ?:@"";
    
    [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[productIDString]} success:^(id responseObject) {
        NSArray *data = responseObject[@"Data"];
        if (data.count > 0) {
            NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
            
            TIoTProductConfigModel *configModel = [TIoTProductConfigModel yy_modelWithJSON:config];
            if ([configModel.Panel.type isEqualToString:@"h5"]) {
                
                //h5自定义面板
                NSDictionary *deviceDic = [self.dataArr[indexPath.row] copy];
                NSString *deviceID = deviceDic[@"DeviceId"];
                NSString *familyId = [TIoTCoreUserManage shared].familyId;
                NSString *roomID = [TIoTCoreUserManage shared].currentRoomId ? : @"0";
                NSString *familyType = [NSString stringWithFormat:@"%ld",(long)[TIoTCoreUserManage shared].FamilyType];
                
                __weak typeof(self) weadkSelf= self;
                
                [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
                [[TIoTRequestObject shared] post:AppGetTokenTicket Param:@{} success:^(id responseObject) {

                    WCLog(@"AppGetTokenTicket responseObject%@", responseObject);
                    NSString *ticket = responseObject[@"TokenTicket"]?:@"";
                    NSString *requestID = responseObject[@"RequestId"]?:@"";
                    NSString *platform = @"iOS";
                    TIoTWebVC *vc = [TIoTWebVC new];
                    NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
                    NSString *url = [NSString stringWithFormat:@"%@/?deviceId=%@&familyId=%@&appID=%@&roomId=%@&familyType=%@&lid=%@&quid=%@&platform=%@&regionId=%@&ticket=%@&uin=%@", [TIoTCoreAppEnvironment shareEnvironment].deviceDetailH5URL,deviceID,familyId,bundleId,roomID,familyType,requestID,requestID,platform,[TIoTCoreUserManage shared].userRegionId,ticket,TIoTAPPConfig.GlobalDebugUin];
                    if (deviceDic[@"FromUserID"]) {
                        NSString *fromUserID = deviceDic[@"FromUserID"];
                        url = [NSString stringWithFormat:@"%@/?deviceId=%@&familyId=%@&isShareDevice=%@&appID=%@&roomId=%@&familyType=%@&lid=%@&quid=%@&platform=%@&regionId=%@&ticket=%@&uin=%@", [TIoTCoreAppEnvironment shareEnvironment].deviceDetailH5URL,deviceID,familyId,fromUserID,bundleId,roomID,familyType,requestID,requestID,platform,[TIoTCoreUserManage shared].userRegionId,ticket,TIoTAPPConfig.GlobalDebugUin];;
                    }
                    
                    vc.urlPath = url;
                    vc.needJudgeJump = YES;
                    vc.needRefresh = YES;
                    vc.deviceDic = [self.dataArr[indexPath.row] mutableCopy];
                    [weadkSelf.navigationController pushViewController:vc animated:YES];
                    [MBProgressHUD dismissInView:weadkSelf.view];

                } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                    [MBProgressHUD dismissInView:weadkSelf.view];
                }];
                
            }else {
                
                //标准面板
                TIoTPanelVC *vc = [[TIoTPanelVC alloc] init];
                vc.title = [NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"AliasName"]];
                vc.productId = self.dataArr[indexPath.row][@"ProductId"];
                vc.deviceName = [NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"DeviceName"]];
                vc.deviceDic = [self.dataArr[indexPath.row] mutableCopy];
//                vc.isOwner = [self.currentFamilyRole integerValue] == 1;
                vc.configData = config;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
    
}

#pragma mark - getter

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
