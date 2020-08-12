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
    
    self.title = @"账号与安全";
    
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
    //国际化版本
    switch (section) {
        case 0:{
            NSArray *accountArray = self.dataArr[0];
            return accountArray.count;
         break;
            
        }
        case 1: {
            NSArray *regionArray = self.dataArr[1];
            return regionArray.count;
            break ;
        }
        case 2: {
            NSArray *resetPasswordArray = self.dataArr[2];
            return resetPasswordArray.count;
            break ;
        }
        case 3: {
            NSArray *cancelAccountArray = self.dataArr[3];
            return cancelAccountArray.count;
            break;
        }
        default:
            break;
    }
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    TIoTUserInfomationTableViewCell *cell = [TIoTUserInfomationTableViewCell cellWithTableView:tableView];
//    cell.dic = self.dataArr[indexPath.row];
//    return cell;
    
    //国际化版本
    TIoTUserInfomationTableViewCell *cell = [TIoTUserInfomationTableViewCell cellWithTableView:tableView];
    cell.dic = self.dataArr[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
    //手机号、邮箱、微信如果是未绑定状态，点击后则跳转到对应的绑定页面，如果已经绑定，则跳转到修改对应账号页面。
    if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"手机号"]) {
        
        if ([self.dataArr[indexPath.row][@"value"] isEqualToString:@"未绑定"]) {
            TIoTBindAccountVC * bindPhoneVC = [[TIoTBindAccountVC alloc]init];
            bindPhoneVC.resfreshResponseBlock = ^(BOOL bindSuccess) {
                if (bindSuccess == YES) {
                    [self.tableView reloadData];
                }
            };
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
            bindEmailVC.resfreshResponseBlock = ^(BOOL bindSuccess) {
                if (bindSuccess == YES) {
                    [self.tableView reloadData];
                }
            };
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
        
        TIoTModifyPasswordVC *modifyPassword = [[TIoTModifyPasswordVC alloc]init];
        [self.navigationController pushViewController:modifyPassword animated:YES];
        
    }else if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"账号注销"]) {
        TIoTCancelAccountVC *cancelAccountVC = [[TIoTCancelAccountVC alloc]init];
        [self.navigationController pushViewController:cancelAccountVC animated:YES];
    }
     */
    
    NSArray *sectionArray = self.dataArr[indexPath.section];
    //国际化版本
      switch (indexPath.section) {
          case 0:{
              if ([sectionArray[indexPath.row][@"title"] isEqualToString:@"手机号"]) {
                  
                  if ([sectionArray[indexPath.row][@"value"] isEqualToString:@"未绑定"]) {
                      TIoTBindAccountVC * bindPhoneVC = [[TIoTBindAccountVC alloc]init];
                      bindPhoneVC.resfreshResponseBlock = ^(BOOL bindSuccess) {
                          if (bindSuccess == YES) {
                              [self.tableView reloadData];
                          }
                      };
                      bindPhoneVC.accountType = AccountType_Phone;
                      [self.navigationController pushViewController:bindPhoneVC animated:YES];
                  }else {
                      TIoTModifyAccountVC *modifyVC = [[TIoTModifyAccountVC alloc]init];
                      modifyVC.accountType = AccountModifyType_Phone;
                      [self.navigationController pushViewController:modifyVC animated:YES];
                  }
                  
              }else if ([sectionArray[indexPath.row][@"title"] isEqualToString:@"邮箱"]) {
                  
                  if ([sectionArray[indexPath.row][@"value"] isEqualToString:@"未绑定"]) {
                      TIoTBindAccountVC *bindEmailVC = [[TIoTBindAccountVC alloc]init];
                      bindEmailVC.accountType = AccountType_Email;
                      bindEmailVC.resfreshResponseBlock = ^(BOOL bindSuccess) {
                          if (bindSuccess == YES) {
                              [self.tableView reloadData];
                          }
                      };
                      [self.navigationController pushViewController:bindEmailVC animated:YES];
                  }else {
                      TIoTModifyAccountVC *modifyVC = [[TIoTModifyAccountVC alloc]init];
                      modifyVC.accountType = AccountModifyType_Email;
                      [self.navigationController pushViewController:modifyVC animated:YES];
                  }
                  
              }else if ([sectionArray[indexPath.row][@"title"] isEqualToString:@"微信"]) {
                  
                  if ([sectionArray[indexPath.row][@"value"] isEqualToString:@"未绑定"]) {
                      //微信绑定
                      [self wxBindClick];
                  }else {
                  }
                  
              }
           break;
              
          }
          case 1: {
              
              break;
          }
          case 2: {
              if ([sectionArray[indexPath.row][@"title"] isEqualToString:@"修改密码"]) {
                  
                  TIoTModifyPasswordVC *modifyPassword = [[TIoTModifyPasswordVC alloc]init];
                  [self.navigationController pushViewController:modifyPassword animated:YES];
                  
              }
              break;
          }
          case 3: {
              if ([sectionArray[indexPath.row][@"title"] isEqualToString:@"账号注销"]) {
                  TIoTCancelAccountVC *cancelAccountVC = [[TIoTCancelAccountVC alloc]init];
                  [self.navigationController pushViewController:cancelAccountVC animated:YES];
              }
              break;
          }
          default:
              break;
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

        [MBProgressHUD showSuccess:@"绑定成功"];
        [self getWeiXinNickAndRefresh];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)bindWeiXinWithOpenID:(NSString *)openid {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] post:AppUpdateUser Param:@{@"WxOpenID":openid} success:^(id responseObject) {
        [MBProgressHUD showSuccess:@"绑定成功"];
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
//        _tableView = [[UITableView alloc]init];
        //国际化版本
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.backgroundColor = [UIColor clearColor];
        //国际化版本
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
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
            phoneNumber = [NSString stringWithFormat:@"%@-%@",[TIoTCoreUserManage shared].countryCode,[TIoTCoreUserManage shared].phoneNumber];
        }
        
        NSString *email = @"未绑定";
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].email]) {
            email = [TIoTCoreUserManage shared].email;
        }
        
        NSString *weixin = @"未绑定";
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
//        _dataArr = [NSMutableArray arrayWithArray:@[
//            @{@"title":@"手机号",@"value":phoneNumber,@"vc":@"",@"haveArrow":@"1"},
//            @{@"title":@"邮箱",@"value":email,@"vc":@"",@"haveArrow":@"1"},
//            @{@"title":@"微信",@"value":weixin,@"vc":@"",@"haveArrow":weixinArrow},
//            @{@"title":@"修改密码",@"value":@"",@"vc":@"",@"haveArrow":@"1"},
//            @{@"title":@"账号注销",@"value":@"",@"vc":@"",@"haveArrow":@"1"},
//        ]];
//
//        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].hasPassword]) {
//            if ([[TIoTCoreUserManage shared].hasPassword isEqualToString:@"1"]) {
//            }
//        }else {
//            [_dataArr removeObjectAtIndex:3];
//        }
        
        
        // 国际化版本
        NSString *region = @"XXX地区";
        _dataArr = [NSMutableArray arrayWithArray:@[
            @[@{@"title":@"手机号",@"value":phoneNumber,@"vc":@"",@"haveArrow":@"1"},
            @{@"title":@"邮箱",@"value":email,@"vc":@"",@"haveArrow":@"1"},
            @{@"title":@"微信",@"value":weixin,@"vc":@"",@"haveArrow":weixinArrow}],
            @[@{@"title":@"账号所在地",@"value":region,@"vc":@"",@"haveArrow":@"0"}],
            @[@{@"title":@"修改密码",@"value":@"",@"vc":@"",@"haveArrow":@"1"}],
            @[@{@"title":@"账号注销",@"value":@"",@"vc":@"",@"haveArrow":@"1"}],
        ]];
        
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].hasPassword]) {
            if ([[TIoTCoreUserManage shared].hasPassword isEqualToString:@"1"]) {
                
            }
        }else {
            [_dataArr removeObjectAtIndex:2];
        }
    }
    
    return _dataArr;
}

@end
