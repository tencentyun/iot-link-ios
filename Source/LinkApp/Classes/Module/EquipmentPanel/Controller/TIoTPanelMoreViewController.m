//
//  WCPanelMoreViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTPanelMoreViewController.h"
#import "TIoTCoreDeviceSet.h"
#import "TIoTDeviceDetailTableViewCell.h"
#import "TIoTDeviceShareVC.h"
#import "TIoTModifyRoomVC.h"
#import "TIoTSingleCustomButton.h"
#import "TIoTModifyDeviceNameVC.h"

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
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    
    [self addTableHeaderView];
    [self addTableFooterView];
}

- (void)addTableHeaderView{
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)addTableFooterView{
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];

    TIoTSingleCustomButton *singleButton = [[TIoTSingleCustomButton alloc]init];
    [singleButton singleCustomButtonStyle:SingleCustomButtonCenale withTitle:NSLocalizedString(@"delete_device", @"删除设备")];
    singleButton.kLeftRightPadding = 20;
    singleButton.singleAction = ^{
        TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
        [av alertWithTitle:NSLocalizedString(@"confirm_delete_device", @"确定要删除设备吗？") message:NSLocalizedString(@"delete_toast_content", @"删除后数据无法直接恢复") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"delete", @"删除")];
        av.doneAction = ^(NSString * _Nonnull text) {
            [self deleteDevice];
        };
        [av showInView:[UIApplication sharedApplication].keyWindow];
    };
    [tableFooterView addSubview:singleButton];
    [singleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(tableFooterView);
        make.height.mas_equalTo(40);
        make.top.equalTo(tableFooterView).offset(60 * kScreenAllHeightScale);
    }];
    
    self.tableView.tableFooterView = tableFooterView;
}


#pragma mark - requset

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
    
    TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
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
        
        __weak typeof(self)WeakSelf = self;
        TIoTModifyDeviceNameVC *modifyDeviceNameVC = [[TIoTModifyDeviceNameVC alloc]init];
        NSString *tipString = NSLocalizedString(@"less20character", @"20字以内");
        tipString = [self getDeviceAliasName:tipString];
        modifyDeviceNameVC.titleText = [self dataArr][indexPath.row][@"title"];
        modifyDeviceNameVC.defaultText = tipString;
        modifyDeviceNameVC.deviceDic = self.deviceDic;
        modifyDeviceNameVC.title = NSLocalizedString(@"device_name", @"设备名称");
        modifyDeviceNameVC.modifyDeviceNameBlcok = ^(NSString * _Nonnull name) {
            [HXYNotice addUpdateDeviceListPost];
            [WeakSelf.deviceDic setValue:name forKey:@"AliasName"];
            NSMutableDictionary *dic = WeakSelf.dataArr[0];
            [dic setValue:name forKey:@"value"];
            [WeakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:modifyDeviceNameVC animated:YES];
        
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

- (NSString *)getDeviceAliasName:(NSString *)tipString {
    NSString * alias = self.deviceDic[@"AliasName"];
    if (alias && [alias isKindOfClass:[NSString class]] && alias.length > 0) {
        tipString = self.deviceDic[@"AliasName"];
    }
    else
    {
        tipString = self.deviceDic[@"DeviceName"];
    }
    return  tipString;
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
        
        NSString * tipString = @"";
        tipString = [self getDeviceAliasName:tipString];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_name", @"设备名称"),@"value":tipString,@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_info", @"设备信息"),@"value":@"",@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"room_setting", @"房间设置"),@"value":@"",@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_share", @"设备分享"),@"value":@"",@"needArrow":@"1"}]];
    }
    return _dataArr;
}

@end
