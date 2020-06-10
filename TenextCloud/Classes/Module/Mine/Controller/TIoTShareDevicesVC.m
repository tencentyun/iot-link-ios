//
//  WCShareDevicesVC.m
//  TenextCloud
//
//  Created by Wp on 2020/3/16.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCShareDevicesVC.h"
#import "WCEquipmentTableViewCell.h"
#import "WCPanelVC.h"

@interface WCShareDevicesVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArr;
@end

@implementation WCShareDevicesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[WCRequestObject shared] post:AppListUserShareDevices Param:@{@"Offset":@0,@"Limit":@50} success:^(id responseObject) {
        [self.dataArr addObjectsFromArray:responseObject[@"ShareDevices"]];
        
        [self updateDeviceStatus];
        
    } failure:^(NSString *reason, NSError *error) {
        
    }];
}

//获取设备状态
- (void)updateDeviceStatus{
    NSArray *arr = [self.dataArr valueForKey:@"DeviceId"];
    
    if (arr.count > 0) {
        NSDictionary *dic = @{@"ProductId":self.dataArr[0][@"ProductId"],@"DeviceIds":arr};
        
        [[WCRequestObject shared] post:AppGetDeviceStatuses Param:dic success:^(id responseObject) {
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
        } failure:^(NSString *reason, NSError *error) {
            
        }];
    }
}

#pragma mark - TableViewDelegate && TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WCEquipmentTableViewCell *cell = [WCEquipmentTableViewCell cellWithTableView:tableView];
    cell.dataDic = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *devIds = @[self.dataArr[indexPath.row][@"DeviceId"]];
    if ([WCWebSocketManage shared].socketReadyState == SR_OPEN) {
        [HXYNotice addActivePushPost:devIds];
    }

    WCPanelVC *vc = [[WCPanelVC alloc] init];
    vc.title = [NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"AliasName"]];
    vc.productId = self.dataArr[indexPath.row][@"ProductId"];
    vc.deviceName = [NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"DeviceName"]];
    vc.deviceDic = [self.dataArr[indexPath.row] mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
    
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
