//
//  WCMemberInfoVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCMemberInfoVC.h"

@interface WCMemberInfoVC ()
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *memberNick;
@property (weak, nonatomic) IBOutlet UILabel *account;
@property (weak, nonatomic) IBOutlet UILabel *roleL;
@property (weak, nonatomic) IBOutlet UIButton *removeBtn;

@end

@implementation WCMemberInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self fillInfo];
}

- (void)fillInfo
{
    self.title = @"成员设置";
    [self.headImg setImageWithURLStr:self.memberInfo[@"Avatar"] placeHolder:@"userDefalut"];
    self.memberNick.text = self.memberInfo[@"NickName"];
    self.roleL.text = [self.memberInfo[@"Role"] integerValue] == 1 ? @"所有者" : @"成员";
    
    if (self.isOwner && ![[WCUserManage shared].userId isEqualToString:self.memberInfo[@"UserID"]]) {
        self.removeBtn.hidden = NO;
    }
}

- (IBAction)done:(UIButton *)sender {
    NSDictionary *param = @{@"MemberID":self.memberInfo[@"UserID"],@"FamilyId":self.familyId};
    [[WCRequestObject shared] post:AppDeleteFamilyMember Param:param success:^(id responseObject) {
        [MBProgressHUD showSuccess:@"移除成功"];
        [HXYNotice postUpdateMemberList];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *reason, NSError *error) {
        [MBProgressHUD showError:reason];
    }];
}



@end
