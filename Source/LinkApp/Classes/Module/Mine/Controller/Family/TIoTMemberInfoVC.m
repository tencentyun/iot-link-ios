//
//  WCMemberInfoVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTMemberInfoVC.h"
#import "TIoTSingleCustomButton.h"
#import "TIoTUserInfomationTableViewCell.h"

@interface TIoTMemberInfoVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) TIoTSingleCustomButton *removeMemberButton;
@end

@implementation TIoTMemberInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIViews];
    
    [self fillInfo];
}

- (void)setupUIViews {
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(48*4);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64*kScreenAllHeightScale + 20);
        }
    }];
    
    __weak typeof(self)weakSelf = self;
    CGFloat kLeftPadding = 16;
    self.removeMemberButton = [[TIoTSingleCustomButton alloc]init];
    self.removeMemberButton.kLeftRightPadding = kLeftPadding;
    [self.removeMemberButton singleCustomButtonStyle:SingleCustomButtonCenale withTitle:NSLocalizedString(@"delete_member", @"移除成员")];
    self.removeMemberButton.singleAction = ^{
        NSDictionary *param = @{@"MemberID":weakSelf.memberInfo[@"UserID"],@"FamilyId":weakSelf.familyId};
        [[TIoTRequestObject shared] post:AppDeleteFamilyMember Param:param success:^(id responseObject) {
            [MBProgressHUD showSuccess:NSLocalizedString(@"remove_success", @"移除成功")];
            [HXYNotice postUpdateMemberList];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [MBProgressHUD showError:reason];
        }];
    };
    [self.view addSubview:self.removeMemberButton];
    [self.removeMemberButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.top.equalTo(self.tableView.mas_bottom).offset(30);
        
    }];
    
    self.removeMemberButton.hidden = YES;
}

- (void)fillInfo
{
    self.title = NSLocalizedString(@"member_setting", @"成员设置");

    NSMutableDictionary *avatarDic = self.dataArray[0];
    [avatarDic setValue:self.memberInfo[@"Avatar"]?:@"" forKey:@"Avatar"];
    
    NSMutableDictionary *nickNameDic = self.dataArray[1];
    [nickNameDic setValue:self.memberInfo[@"NickName"]?:@"" forKey:@"value"];
    
    NSMutableDictionary *roleDic = self.dataArray[3];
    NSString *roleString = [self.memberInfo[@"Role"] integerValue] == 1 ? NSLocalizedString(@"role_owner", @"所有者") : NSLocalizedString(@"role_member",@"成员");
    [roleDic setValue:roleString?:@"" forKey:@"value"];
    
    if (self.isOwner && ![[TIoTCoreUserManage shared].userId isEqualToString:self.memberInfo[@"UserID"]]) {
        self.removeMemberButton.hidden = NO;
    }else {
        self.removeMemberButton.hidden = YES;
    }
}


#pragma mark - TableViewDelgate TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTUserInfomationTableViewCell *cell = [TIoTUserInfomationTableViewCell cellWithTableView:tableView];
    cell.dic = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - lazy loading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 48;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithArray:@[
            [NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"avatar", @"头像"),@"value":@"",@"haveArrow":@"0",}],
            [NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"user_nickName", @"用户昵称"),@"value":@"",@"haveArrow":@"0"}],
            [NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"member_account", @"关联账号"),@"value":@"",@"haveArrow":@"0"}],
            [NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"member_role", @"角色"),@"value":@"",@"haveArrow":@"0"}]]];
    }
    return _dataArray;
}

@end
