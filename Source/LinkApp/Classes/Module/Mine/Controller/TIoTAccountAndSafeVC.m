//
//  TIoTAccountAndSafeVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/7/30.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTAccountAndSafeVC.h"
#import "TIoTUserInfomationTableViewCell.h"
#import "TIoTBindAccountVC.h"
#import "TIoTModifyAccountVC.h"
#import "WxManager.h"
#import "TIoTAppConfig.h"
#import "TIoTModifyPasswordVC.h"
#import "TIoTCancelAccountVC.h"

@interface TIoTAccountAndSafeVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *dataArr;
@end

@implementation TIoTAccountAndSafeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"account_and_safety", @"账号与安全");
    
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
    
    //拉去静态配置文件（地区列表），根据手机系统判断显示账号地区
    [[TIoTRequestObject shared] get:TIoTAPPConfig.regionlistString success:^(id responseObject) {

        NSArray *regionListArray = (NSArray *)responseObject;
        
        [regionListArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *regionDic = obj;
            if ([regionDic[@"RegionID"] isEqualToString:[TIoTCoreUserManage shared].userRegionId]) {
                [[TIoTCoreUserManage shared] saveUserInfo:regionDic];
            }
             
        }];
        
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {

    }];
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
            
            __weak typeof(self) weakSelf = self;
            TIoTBindAccountVC * bindPhoneVC = [[TIoTBindAccountVC alloc]init];
            bindPhoneVC.resfreshResponseBlock = ^(BOOL bindSuccess) {
                if (bindSuccess == YES) {
                    [weakSelf.tableView reloadData];
                }
            };
            bindPhoneVC.accountType = AccountType_Phone;
            [self.navigationController pushViewController:bindPhoneVC animated:YES];
        }else {
            TIoTModifyAccountVC *modifyVC = [[TIoTModifyAccountVC alloc]init];
            modifyVC.accountType = AccountModifyType_Phone;
            [self.navigationController pushViewController:modifyVC animated:YES];
        }

    }else if ([sectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"email", @"邮箱")]) {

        if ([sectionArray[indexPath.row][@"value"] isEqualToString:NSLocalizedString(@"unbind", @"未绑定")]) {
            __weak typeof(self) weakSelf = self;
            TIoTBindAccountVC *bindEmailVC = [[TIoTBindAccountVC alloc]init];
            bindEmailVC.accountType = AccountType_Email;
            bindEmailVC.resfreshResponseBlock = ^(BOOL bindSuccess) {
                if (bindSuccess == YES) {
                    [weakSelf.tableView reloadData];
                }
            };
            [self.navigationController pushViewController:bindEmailVC animated:YES];
        }else {
            TIoTModifyAccountVC *modifyVC = [[TIoTModifyAccountVC alloc]init];
            modifyVC.accountType = AccountModifyType_Email;
            [self.navigationController pushViewController:modifyVC animated:YES];
        }

    }else if ([sectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"wechat", @"微信")]) {

        if ([sectionArray[indexPath.row][@"value"] isEqualToString:NSLocalizedString(@"unbind", @"未绑定")]) {
            //微信绑定
            [self wxBindClick];
        }else {
        }

    } else if ([sectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"modify_password", @"修改密码")]) {
        
        TIoTModifyPasswordVC *modifyPassword = [[TIoTModifyPasswordVC alloc]init];
        [self.navigationController pushViewController:modifyPassword animated:YES];
        
    }else if ([sectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"account_logout", @"账号注销")]) {
        TIoTCancelAccountVC *cancelAccountVC = [[TIoTCancelAccountVC alloc]init];
        [self.navigationController pushViewController:cancelAccountVC animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark - enent
- (void)wxBindClick {
    
    [[WxManager sharedWxManager] authFromWxComplete:^(id obj, NSError *error) {
        if (!error) {
            [self getTokenByOpenId:[NSString stringWithFormat:@"%@",obj]];
        }
    }];
}

- (void)getTokenByOpenId:(NSString *)code
{
    NSString *busivalue = @"studioappOpensource";
    
    TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];

    if ([TIoTAppConfig weixinLoginWithModel:model]){
        
        busivalue = @"studioapp";
    }else {
        
        busivalue = @"studioappOpensource";
    }
    NSDictionary *tmpDic = @{@"code":code,@"busi":busivalue,@"AccessToken":[TIoTCoreUserManage shared].accessToken};

    [[TIoTRequestObject shared] postWithoutToken:AppUpdateUserByWeiXin Param:tmpDic success:^(id responseObject) {
        [MBProgressHUD dismissInView:self.view];

        [MBProgressHUD showSuccess:NSLocalizedString(@"bind_success", @"绑定成功")];
        [self getWeiXinNickAndRefresh];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)bindWeiXinWithOpenID:(NSString *)openid {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] post:AppUpdateUser Param:@{@"WxOpenID":openid} success:^(id responseObject) {
        [MBProgressHUD showSuccess:NSLocalizedString(@"bind_success", @"绑定成功")];
        [[TIoTCoreUserManage shared] saveUserInfo:@{@"WxOpenID":openid}];
        [self getWeiXinNickAndRefresh];

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)getWeiXinNickAndRefresh {
    
    [[TIoTRequestObject shared] post:AppGetUser Param:@{} success:^(id responseObject) {
        NSDictionary *data = responseObject[@"Data"];
        [[TIoTCoreUserManage shared] saveUserInfo:data];
        [self.tableView reloadData];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

#pragma mark - setter and getter

- (UITableView *)tableView {
    if (!_tableView) {
        //国际化版本
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TIoTUserInfomationTableViewCell class] forCellReuseIdentifier:ID];
    }
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {

        NSString *phoneNumber = NSLocalizedString(@"unbind", @"未绑定");
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].phoneNumber]) {
            //国际化版本
            phoneNumber = [NSString stringWithFormat:@"%@-%@",[TIoTCoreUserManage shared].countryCode,[TIoTCoreUserManage shared].phoneNumber];
        }
        
        NSString *email = NSLocalizedString(@"unbind", @"未绑定");
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].email]) {
            email = [TIoTCoreUserManage shared].email;
        }
        
        NSString *weixin = NSLocalizedString(@"unbind", @"未绑定");
        NSString *weixinArrow = @"1";
        if ([NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].hasBindWxOpenID]) {
            // hasBindWxOpenID 字段为空
            weixinArrow = @"0";
        }else {
            //hasBindWxOpenID  0 未绑定微信 1 已经绑定微信
            if ([[TIoTCoreUserManage shared].hasBindWxOpenID isEqualToString:@"0"]) {
                weixinArrow = @"1";
            }else if ([[TIoTCoreUserManage shared].hasBindWxOpenID isEqualToString:@"1"]){
                    weixin = @"已绑定";
                weixinArrow = @"0";
            }
        }
        
        // 国际化版本
        NSString *region = @"";
        if (LanguageIsEnglish) {
            region = [TIoTCoreUserManage shared].countryTitleEN;
        }else {
            region = [TIoTCoreUserManage shared].countryTitle;
        }
        _dataArr = [NSMutableArray arrayWithArray:@[
            @[@{@"title":NSLocalizedString(@"phone_number", @"手机号码"),@"value":phoneNumber,@"vc":@"",@"haveArrow":@"1"},
            @{@"title":NSLocalizedString(@"email", @"邮箱"),@"value":email,@"vc":@"",@"haveArrow":@"1"},
            @{@"title":NSLocalizedString(@"wechat", @"微信"),@"value":weixin,@"vc":@"",@"haveArrow":weixinArrow}],
            @[@{@"title":NSLocalizedString(@"location_of_account", @"账户所在地"),@"value":region,@"vc":@"",@"haveArrow":@"0"}],
            @[@{@"title":NSLocalizedString(@"modify_password", @"修改密码"),@"value":@"",@"vc":@"",@"haveArrow":@"1"}],
            @[@{@"title":NSLocalizedString(@"account_logout", @"账号注销"),@"value":@"",@"vc":@"",@"haveArrow":@"1"}],
        ]];

        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].hasPassword]) {
            if ([[TIoTCoreUserManage shared].hasPassword isEqualToString:@"0"]) {
                [_dataArr removeObjectAtIndex:2];
            }
        }else {
            [_dataArr removeObjectAtIndex:2];
        }
    }
    
    return _dataArr;
}

@end
