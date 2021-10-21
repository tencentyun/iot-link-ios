//
//  TIoTAuthentationVC.m
//  LinkApp
//  Copyright © 2021 Tencent. All rights reserved.

#import "TIoTAuthentationVC.h"
#import "TIoTUserInfomationTableViewCell.h"

@interface TIoTAuthentationVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *dataArr;
@end

@implementation TIoTAuthentationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"modify_authentation", @"权限管理");
    
    [self setUpUI];
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view);
        }
    }];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 16 * kScreenAllHeightScale)];
    headerView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - tableViewDataSource and tableViewDelegate

//国际化版本
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    //国际化版本
    NSArray *sectionDataArray = self.dataArr[section];
    return sectionDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //国际化版本
    TIoTUserInfomationTableViewCell *cell = [TIoTUserInfomationTableViewCell cellWithTableView:tableView];
    cell.dic = self.dataArr[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *sectionArray = self.dataArr[indexPath.section];
    //国际化版本
    
    if ([sectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"phone_number", @"手机号码")]) {

        if ([sectionArray[indexPath.row][@"value"] isEqualToString:NSLocalizedString(@"unbind", @"未绑定")]) {
            
        
        }else {
//            TIoTModifyAccountVC *modifyVC = [[TIoTModifyAccountVC alloc]init];
//            modifyVC.accountType = AccountModifyType_Phone;
//            [self.navigationController pushViewController:modifyVC animated:YES];
        }

    }else if ([sectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"email", @"邮箱")]) {

        if ([sectionArray[indexPath.row][@"value"] isEqualToString:NSLocalizedString(@"unbind", @"未绑定")]) {
            __weak typeof(self) weakSelf = self;
            
//            [self.navigationController pushViewController:bindEmailVC animated:YES];
        }else {
            
            
        }

    }else if ([sectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"wechat", @"微信")]) {

        if ([sectionArray[indexPath.row][@"value"] isEqualToString:NSLocalizedString(@"unbind", @"未绑定")]) {
            //微信绑定
        }else {
        }

        
    } else if ([sectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"modify_authentation", @"权限管理")]) {
        
        TIoTAuthentationVC *modifyPassword = [[TIoTAuthentationVC alloc]init];
        [self.navigationController pushViewController:modifyPassword animated:YES];
        
    } else if ([sectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"modify_password", @"修改密码")]) {
        
        
        
    }else if ([sectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"account_logout", @"账号注销")]) {
        
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UITableView *)tableView {
    if (!_tableView) {
        //国际化版本
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        _tableView.rowHeight = 48;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TIoTUserInfomationTableViewCell class] forCellReuseIdentifier:ID];
    }
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {

        _dataArr = [NSMutableArray arrayWithArray:@[
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte1", @"推送权限"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte2", @"位置信息"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte3", @"摄像头/麦克风权限"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte4", @"蓝牙权限"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
        ]];
    }
    
    return _dataArr;
}
@end
