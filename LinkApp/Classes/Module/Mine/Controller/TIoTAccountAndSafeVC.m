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

@interface TIoTAccountAndSafeVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *dataArr;
@end

@implementation TIoTAccountAndSafeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 20 * kScreenAllHeightScale)];
    headerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - tableViewDataSource and tableViewDelegate

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTUserInfomationTableViewCell *cell = [TIoTUserInfomationTableViewCell cellWithTableView:tableView];
    cell.dic = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //手机号、邮箱、微信如果是未绑定状态，点击后则跳转到对应的绑定页面，如果已经绑定，则跳转到修改对应账号页面。
    if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"手机号"]) {
        if ([self.dataArr[indexPath.row][@"value"] isEqualToString:@"未绑定"]) {
            TIoTBindAccountVC * bindPhoneVC = [[TIoTBindAccountVC alloc]init];
            bindPhoneVC.accountType = AccountType_Phone;
            [self.navigationController pushViewController:bindPhoneVC animated:YES];
        }else {
            TIoTModifyAccountVC *modifyVC = [[TIoTModifyAccountVC alloc]init];
            modifyVC.accountType = AccountModifyType_Phone;
            [self.navigationController pushViewController:modifyVC animated:YES];
        }
        
    }else if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"邮箱"]) {
        if ([self.dataArr[indexPath.row][@"value"] isEqualToString:@"未绑定"]) {
            TIoTBindAccountVC *bindEmailVC = [[TIoTBindAccountVC alloc]init];
            bindEmailVC.accountType = AccountType_Email;
            [self.navigationController pushViewController:bindEmailVC animated:YES];
        }else {
            TIoTModifyAccountVC *modifyVC = [[TIoTModifyAccountVC alloc]init];
            modifyVC.accountType = AccountModifyType_Email;
            [self.navigationController pushViewController:modifyVC animated:YES];
        }
    }else if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"微信"]) {
        if ([self.dataArr[indexPath.row][@"value"] isEqualToString:@"未绑定"]) {
            //微信绑定
            [self wxBindClick];
        }else {
        }
    }else if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"修改密码"]) {
        
    }else if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"账号注销"]) {
        
    }
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
    NSDictionary *tmpDic = @{@"code":code,@"busi":busivalue};
    
    [[TIoTRequestObject shared] postWithoutToken:AppGetTokenByWeiXin Param:tmpDic success:^(id responseObject) {
        [MBProgressHUD dismissInView:self.view];
        [[TIoTCoreUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
        [self bindWeiXinWithOpenID:responseObject[@"Data"][@"Openid"]];
        
        //信鸽推送注册
//        [[XGPushManage sharedXGPushManage] bindPushToken];
//        [HXYNotice addLoginInPost];
        
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)bindWeiXinWithOpenID:(NSString *)openid {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] post:AppUpdateUser Param:@{@"WxOpenID":openid} success:^(id responseObject) {
        [MBProgressHUD showSuccess:@"绑定成功"];
        [[TIoTCoreUserManage shared] saveUserInfo:@{@"WxOpenID":openid}];
        [self getWeiXinNickAndRefresh];
        [HXYNotice addModifyUserInfoPost];
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
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TIoTUserInfomationTableViewCell class] forCellReuseIdentifier:ID];
    }
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {

        NSString *phoneNumber = @"未绑定";
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].phoneNumber]) {
            phoneNumber = [TIoTCoreUserManage shared].phoneNumber;
        }
        
        NSString *email = @"未绑定";
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].email]) {
            email = [TIoTCoreUserManage shared].email;
        }
        
        NSString *weixin = @"未绑定";
        NSString *weixinArrow = @"1";
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].nickName]) {
            weixin = [TIoTCoreUserManage shared].nickName;
            weixinArrow = @"0";
        }
        
        _dataArr = [NSMutableArray arrayWithArray:@[
            @{@"title":@"手机号",@"value":phoneNumber,@"vc":@"",@"haveArrow":@"1"},
            @{@"title":@"邮箱",@"value":email,@"vc":@"",@"haveArrow":@"1"},
            @{@"title":@"微信",@"value":weixin,@"vc":@"",@"haveArrow":weixinArrow},
            @{@"title":@"修改密码",@"value":@"",@"vc":@"",@"haveArrow":@"1"},
            @{@"title":@"账号注销",@"value":@"",@"vc":@"",@"haveArrow":@"1"},
        ]];
        
        if (![[TIoTCoreUserManage shared].hasPassword isEqual: @"1"]) {    //没有设置密码
            [_dataArr removeObjectAtIndex:3];
        }
    }
    
    return _dataArr;
}

@end
