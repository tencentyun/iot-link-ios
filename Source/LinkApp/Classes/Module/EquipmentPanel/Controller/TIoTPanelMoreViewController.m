//
//  WCPanelMoreViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTPanelMoreViewController.h"
#import "TIoTDeviceData.h"
#import "TIoTDeviceDetailTableViewCell.h"
#import "TIoTDeviceShareVC.h"
#import "TIoTModifyRoomVC.h"

@interface TIoTPanelMoreViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *timeLab;

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation TIoTPanelMoreViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

#pragma mark privateMethods
- (void)setupUI{
    self.view.backgroundColor = kBgColor;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    
    [self addTableHeaderView];
    [self addTableFooterView];
}

- (void)addTableHeaderView{
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    
//    self.nameLab = [[UILabel alloc] init];
//    self.nameLab.text = self.deviceDic[@"DeviceName"];
//    self.nameLab.textColor = kRGBColor(51, 51, 51);
//    self.nameLab.font = [UIFont wcPfSemiboldFontOfSize:20];
//    [tableHeaderView addSubview:self.nameLab];
//    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(tableHeaderView).offset(20);
//        make.top.equalTo(tableHeaderView).offset(30);
//    }];
//    
//    self.timeLab = [[UILabel alloc] init];
//    self.timeLab.text = [NSString stringWithFormat:@"绑定时间：%@",[NSString convertTimestampToTime:[NSString stringWithFormat:@"%@",self.deviceDic[@"CreateTime"]] byDateFormat:@"yyyy-MM-dd HH:mm:ss"]];
//    self.timeLab.textColor = kRGBColor(204, 204, 204);
//    self.timeLab.font = [UIFont wcPfRegularFontOfSize:10];
//    [tableHeaderView addSubview:self.timeLab];
//    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(tableHeaderView).offset(20);
//        make.top.equalTo(self.nameLab.mas_bottom).offset(10);
//    }];
    
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)addTableFooterView{
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];

    UIButton *deleteEquipmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteEquipmentBtn setTitle:NSLocalizedString(@"delete_device", @"删除设备") forState:UIControlStateNormal];
    [deleteEquipmentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteEquipmentBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:20];
    [deleteEquipmentBtn addTarget:self action:@selector(deleteEquipment:) forControlEvents:UIControlEventTouchUpInside];
    deleteEquipmentBtn.backgroundColor = kWarnColor;
    deleteEquipmentBtn.layer.cornerRadius = 3;
    [tableFooterView addSubview:deleteEquipmentBtn];
    [deleteEquipmentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tableFooterView).offset(30);
        make.top.equalTo(tableFooterView).offset(80 * kScreenAllHeightScale);
        make.right.equalTo(tableFooterView).offset(-30);
        make.height.mas_equalTo(48);
    }];
    
    self.tableView.tableFooterView = tableFooterView;
}


#pragma mark - requset

- (void)modifyName:(NSString *)name
{
    [[TIoTRequestObject shared] post:AppUpdateDeviceInFamily Param:@{@"ProductID":self.deviceDic[@"ProductId"],@"DeviceName":self.deviceDic[@"DeviceName"],@"AliasName":name} success:^(id responseObject) {
        [HXYNotice addUpdateDeviceListPost];
        
        [self.deviceDic setValue:name forKey:@"AliasName"];
        NSMutableDictionary *dic = self.dataArr[0];
        [dic setValue:name forKey:@"value"];
        [self.tableView reloadData];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)deleteDevice
{
    [[TIoTRequestObject shared] post:AppDeleteDeviceInFamily Param:@{@"FamilyId":self.deviceDic[@"FamilyId"],@"ProductID":self.deviceDic[@"ProductId"],@"DeviceName":self.deviceDic[@"DeviceName"]} success:^(id responseObject) {
        
        [HXYNotice addUpdateDeviceListPost];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

#pragma mark - event


- (void)deleteEquipment:(id)sender{
    
    TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleText];
    [av alertWithTitle:NSLocalizedString(@"confirm_delete_device", @"确定要删除设备吗？") message:NSLocalizedString(@"delete_toast_content", @"删除后数据无法直接恢复") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"delete", @"删除")];
    av.doneAction = ^(NSString * _Nonnull text) {
        [self deleteDevice];
    };
    [av showInView:[UIApplication sharedApplication].keyWindow];
    
}


#pragma mark - TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self dataArr].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTDeviceDetailTableViewCell *cell = [TIoTDeviceDetailTableViewCell cellWithTableView:tableView];
    cell.dic = [self dataArr][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[self dataArr][indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"device_name", @"设备名称")]) {
        
        TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
        
        NSString *tipString = NSLocalizedString(@"less20character", @"20字以内");
//        if (![NSString isNullOrNilWithObject:self.deviceDic[@"DeviceName"]]) {
//            tipString = self.deviceDic[@"DeviceName"];
//        }
        
//        NSString * alias = self.deviceDic[@"AliasName"];
//        if (alias && [alias isKindOfClass:[NSString class]] && alias.length > 0) {
//            tipString = self.deviceDic[@"AliasName"];
//        }
//        else
//        {
//            tipString = self.deviceDic[@"DeviceName"];
//        }
        
        [av alertWithTitle:NSLocalizedString(@"device_name", @"设备名称") message:tipString cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"verify", @"确认")];
        av.maxLength = 20;
        av.doneAction = ^(NSString * _Nonnull text) {
            if (text.length > 0) {
                [self modifyName:text];
            }
        };
        av.defaultText = [self dataArr][indexPath.row][@"value"];
        [av showInView:[UIApplication sharedApplication].keyWindow];
        
    }
    else if ([[self dataArr][indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"device_share", @"设备分享")])
    {
        TIoTDeviceShareVC *vc = [[TIoTDeviceShareVC alloc] init];
        vc.deviceDic = self.deviceDic;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([[self dataArr][indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"room_setting", @"房间设置")])
    {
        TIoTModifyRoomVC *vc = [[TIoTModifyRoomVC alloc] init];
        vc.deviceInfo = self.deviceDic;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([[self dataArr][indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"device_info", @"设备信息")])
    {
        UIViewController *vc = [NSClassFromString(@"TIoTDeviceDetailVC") new];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_name", @"设备名称"),@"value":self.deviceDic[@"AliasName"],@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_info", @"设备信息"),@"value":@"",@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"room_setting", @"房间设置"),@"value":@"",@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_share", @"设备分享"),@"value":@"",@"needArrow":@"1"}]];
    }
    return _dataArr;
}

@end
