//
//  WCMineViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/16.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCMineViewController.h"
#import "WCMineTableViewCell.h"
#import "WCUserInfomationViewController.h"

#import "WCAlertView.h"

#import "NSString+Extension.h"

@interface WCMineViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *telLab;
@property (nonatomic, copy) NSArray *dataArr;

@end

@implementation WCMineViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fd_prefersNavigationBarHidden = YES;
    
    [HXYNotice addModifyUserInfoListener:self reaction:@selector(modifyUserInfo:)];
    
    [self setupUI];
    
    [self getUserInfo];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self modifyUserInfo:nil];
}

- (void)dealloc{
    [HXYNotice removeListener:self];
}

#pragma mark - other

- (void)setupUI{
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = kBgColor;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    
    [self addTableHeaderView];
}

- (void)addTableHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 140 * kScreenAllHeightScale + [WCUIProxy shareUIProxy].statusHeight + 10)];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView xdp_addTarget:self action:@selector(userClick:)];
    
    
    UIView *bgBorder = [[UIView alloc] init];
    bgBorder.backgroundColor = kRGBAColor(0, 0, 0, 0.04);
    bgBorder.layer.cornerRadius = 46 * kScreenAllWidthScale;
    [headerView addSubview:bgBorder];
    [bgBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headerView).offset(28);
        make.centerY.equalTo(headerView).offset([WCUIProxy shareUIProxy].statusHeight * 0.5);
        make.width.height.mas_equalTo(92 * kScreenAllWidthScale);
    }];
    
    self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userDefalut"]];
    self.iconImageView.layer.cornerRadius = 80 * kScreenAllWidthScale / 2;
    self.iconImageView.layer.masksToBounds = YES;
//    self.iconImageView.layer.borderWidth = 4;
//    self.iconImageView.layer.borderColor = kRGBAColor(255, 255, 255, 0.5).CGColor;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    [headerView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headerView).offset(34);
        make.centerY.equalTo(headerView).offset([WCUIProxy shareUIProxy].statusHeight * 0.5);
        make.width.height.mas_equalTo(80 * kScreenAllWidthScale);
    }];
    
    self.nameLab = [[UILabel alloc] init];
    self.nameLab.font = [UIFont boldSystemFontOfSize:20];
//    self.nameLab.textAlignment = NSTextAlignmentCenter;
    self.nameLab.textColor = kFontColor;
    [headerView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_top).offset(18);
        make.leading.equalTo(self.iconImageView.mas_trailing).offset(40);
        make.trailing.mas_equalTo(-30);
        make.height.mas_equalTo(24);
    }];
    
    self.telLab = [[UILabel alloc] init];
    self.telLab.font = [UIFont systemFontOfSize:16];
//    self.telLab.textAlignment = NSTextAlignmentCenter;
    self.telLab.textColor = kRGBColor(187, 187, 187);
    [headerView addSubview:self.telLab];
    [self.telLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLab.mas_bottom).offset(5);
        make.leading.trailing.equalTo(self.nameLab);
        
    }];
    
    UIView *sep = [UIView new];
    sep.backgroundColor = kRGBColor(242, 242, 242);
    [headerView addSubview:sep];
    [sep mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(10);
    }];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)getUserInfo{
    
    
    [[WCRequestObject shared] post:AppGetUser Param:@{} success:^(id responseObject) {
        NSDictionary *data = responseObject[@"Data"];
        self.nameLab.text = data[@"NickName"];
        [self.iconImageView setImageWithURLStr:data[@"Avatar"] placeHolder:@"userDefalut"];
        self.telLab.text = data[@"PhoneNumber"];
        
        [[WCUserManage shared] saveUserInfo:data];
    } failure:^(NSString *reason, NSError *error) {
        
    }];
}

#pragma mark eventResponse
- (void)userClick:(id)sender{
    WCUserInfomationViewController *vc = [[WCUserInfomationViewController alloc] init];
    vc.title = @"个人信息";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)modifyUserInfo:(id)sender{
    self.nameLab.text = [WCUserManage shared].nickName;
    [self.iconImageView setImageWithURLStr:[WCUserManage shared].avatar placeHolder:@"userDefalut"];
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WCMineTableViewCell *cell = [WCMineTableViewCell cellWithTableView:tableView];
    cell.dic = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController *vc = [[NSClassFromString(self.dataArr[indexPath.row][@"vc"]) alloc] init];
    [vc setValue:self.dataArr[indexPath.row][@"title"] forKey:@"title"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 80 * [UIScreen mainScreen].bounds.size.height / 812.0;
        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (NSArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = @[
            @{@"title":@"家庭管理",@"image":@"mineFamily",@"vc":@"WCFamiliesVC"},
            @{@"title":@"共享设备",@"image":@"mineDevice",@"vc":@"WCShareDevicesVC"},
            @{@"title":@"消息通知",@"image":@"mineMessage",@"vc":@"WCMessageViewController"},
            @{@"title":@"帮助中心",@"image":@"mineHelp",@"vc":@"WCHelpCenterViewController"},
            @{@"title":@"意见反馈",@"image":@"mineFeed",@"vc":@"WCFeedBackViewController"},
            @{@"title":@"关于我们",@"image":@"mineAbout",@"vc":@"WCAboutVC"}
        ];
    }
    return _dataArr;
}

@end
