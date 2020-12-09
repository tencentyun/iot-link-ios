//
//  WCDeviceShareVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTDeviceShareVC.h"
//#import "TIoTUserCell.h"
#import "TIoTInvitationVC.h"
#import "TIoTSingleCustomButton.h"
#import "UIButton+LQRelayout.h"
#import "TIoTShareDeviceMessageCell.h"

static NSString *cellId = @"sd0679";
@interface TIoTDeviceShareVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *userList;
@property (nonatomic, strong) UIView *emptyShareDeviceBackView;
@property  (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *noShareDeviceTipLabel;
@property (nonatomic, strong) UIButton *addShareDeviceButton;
@end

@implementation TIoTDeviceShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    [self queryDeviceUserList];
}

- (void)setupUI
{
    self.title = NSLocalizedString(@"device_share", @"设备分享");
//    [self.tableView registerNib:[UINib nibWithNibName:@"TIoTUserCell" bundle:nil] forCellReuseIdentifier:cellId];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    //添加空白缺省图
    [self addEmptyShareDeviceTipView];
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth - 40, 60)];
    lab.textColor = kFontColor;
    lab.font = [UIFont systemFontOfSize:14];
    lab.text = NSLocalizedString(@"share_user_hint", @"设备已单独分享给以下用户");
    [header addSubview:lab];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 59, kScreenWidth - 40, 1)];
    line.backgroundColor = kLineColor;
    [header addSubview:line];
    self.tableView.tableHeaderView = header;
    
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth - 40, 1)];
    line2.backgroundColor = kLineColor;
    [footer addSubview:line2];
    
    CGFloat kLeftPadding = 16;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(kLeftPadding, 24, kScreenWidth - kLeftPadding*2, 48);
    [btn setTitle:NSLocalizedString(@"add_device_share", @"添加分享") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [btn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setImage:[UIImage imageNamed:@"share_device"] forState:UIControlStateNormal];
    [btn relayoutButton:XDPButtonLayoutStyleLeft];
    [btn addTarget:self action:@selector(toShare) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 20;
    [footer addSubview:btn];
    
    self.tableView.tableFooterView = footer;
}


#pragma mark - event

- (void)toShare
{
    TIoTInvitationVC *vc = [TIoTInvitationVC new];
    vc.title = NSLocalizedString(@"device_share_to_user", @"分享用户");
    vc.familyId = self.deviceDic[@"FamilyId"];
    vc.productId = self.deviceDic[@"ProductId"];
    vc.deviceName = self.deviceDic[@"DeviceName"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    TIoTUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
//    [cell setInfo:self.userList[indexPath.row]];
//    return cell;
    
    TIoTShareDeviceMessageCell *cell = [TIoTShareDeviceMessageCell cellWithTableView:tableView];
    [cell setInfo:self.userList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self removeShareDeviceUser:indexPath.row];
    }
}

// 修改编辑按钮文字

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"delete", @"删除");
}


#pragma mark - request

- (void)queryDeviceUserList
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:self.deviceDic[@"ProductId"] forKey:@"ProductId"];
    [param setValue:self.deviceDic[@"DeviceName"] forKey:@"DeviceName"];
//    [param setValue:@"" forKey:@"Offset"];
//    [param setValue:@"" forKey:@"Limit"];
    [[TIoTRequestObject shared] post:AppListShareDeviceUsers Param:param success:^(id responseObject) {
        [self.userList removeAllObjects];
        [self.userList addObjectsFromArray:responseObject[@"Users"]];
        [self refreshUI:responseObject];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}



- (void)removeShareDeviceUser:(NSUInteger)index
{
    NSString *userId = self.userList[index][@"UserID"];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:userId forKey:@"RemoveUserID"];
    [param setValue:self.deviceDic[@"ProductId"] forKey:@"ProductId"];
    [param setValue:self.deviceDic[@"DeviceName"] forKey:@"DeviceName"];
    [[TIoTRequestObject shared] post:AppRemoveShareDeviceUser Param:param success:^(id responseObject) {
        [MBProgressHUD showSuccess:NSLocalizedString(@"delete_success", @"删除成功")];
        [self.userList removeObjectAtIndex:index];
        [self.tableView reloadData];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

#pragma mark - other

- (void)refreshUI:(NSDictionary *)data{
    
    if ([data[@"Users"] count] == 0) {
        
        self.tableView.hidden = YES;
        self.emptyShareDeviceBackView.hidden = NO;
        [self.tableView reloadData];
    }
    else{
        self.tableView.hidden = NO;
        self.emptyShareDeviceBackView.hidden = YES;
        [self.tableView reloadData];
    }
}

- (void)addEmptyShareDeviceTipView {
    
    self.emptyShareDeviceBackView = [[UIView alloc]init];
    self.emptyShareDeviceBackView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.view addSubview:self.emptyShareDeviceBackView];
    [self.emptyShareDeviceBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64*kScreenAllHeightScale);
        }
    }];
    
    [self.emptyShareDeviceBackView addSubview:self.emptyImageView];
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat kSpaceHeight = 55; //距离中心偏移量
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            kSpaceHeight = 80;
        }
        make.centerY.mas_equalTo(kScreenHeight/2).offset(-kSpaceHeight);
        make.left.equalTo(self.emptyShareDeviceBackView).offset(60);
        make.right.equalTo(self.emptyShareDeviceBackView).offset(-60);
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            make.height.mas_equalTo(190);
        }else {
            make.height.mas_equalTo(160);
        }

    }];
    
    [self.emptyShareDeviceBackView addSubview:self.noShareDeviceTipLabel];
    [self.noShareDeviceTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emptyImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self.emptyShareDeviceBackView);
        make.centerX.equalTo(self.emptyShareDeviceBackView);
    }];
    
    [self.emptyShareDeviceBackView addSubview:self.addShareDeviceButton];
    [self.addShareDeviceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noShareDeviceTipLabel.mas_bottom).offset(20);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(36);
        make.centerX.equalTo(self.emptyShareDeviceBackView);
    }];
}

#pragma mark - getter

- (NSMutableArray *)userList
{
    if (!_userList) {
        _userList = [NSMutableArray array];
    }
    return _userList;
}

- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_noTask"]];
    }
    return _emptyImageView;
}

- (UILabel *)noShareDeviceTipLabel {
    if (!_noShareDeviceTipLabel) {
        _noShareDeviceTipLabel = [[UILabel alloc]init];
        _noShareDeviceTipLabel.text = NSLocalizedString(@"no_share_other_user", @"暂未分享给其他用户");
        _noShareDeviceTipLabel.font = [UIFont wcPfRegularFontOfSize:14];
        _noShareDeviceTipLabel.textColor= [UIColor colorWithHexString:@"#6C7078"];
        _noShareDeviceTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noShareDeviceTipLabel;
}

- (UIButton *)addShareDeviceButton {
    if (!_addShareDeviceButton) {
        _addShareDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addShareDeviceButton.layer.borderWidth = 1;
        _addShareDeviceButton.layer.borderColor = [UIColor colorWithHexString:@"#0066FF"].CGColor;
        _addShareDeviceButton.layer.cornerRadius = 18;
        [_addShareDeviceButton setTitle:NSLocalizedString(@"add_device_share", @"添加分享") forState:UIControlStateNormal];
        [_addShareDeviceButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        _addShareDeviceButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_addShareDeviceButton addTarget:self action:@selector(toShare) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addShareDeviceButton;
}

@end
