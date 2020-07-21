//
//  WCMemberInfoVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTCoreMemberInfoVC.h"
#import <UIImageView+WebCache.h>
#import "TIoTCoreUserManage.h"

@interface TIoTCoreMemberInfoVC ()
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *memberNick;
@property (weak, nonatomic) IBOutlet UILabel *account;
@property (weak, nonatomic) IBOutlet UILabel *roleL;
@property (weak, nonatomic) IBOutlet UIButton *removeBtn;

@end

@implementation TIoTCoreMemberInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self fillInfo];
}

- (void)fillInfo
{
    self.title = @"成员设置";
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:self.memberInfo[@"Avatar"]]];
    self.memberNick.text = self.memberInfo[@"NickName"];
    self.roleL.text = [self.memberInfo[@"Role"] integerValue] == 1 ? @"所有者" : @"成员";
    
    if (self.isOwner && ![[TIoTCoreUserManage shared].userId isEqualToString:self.memberInfo[@"UserID"]]) {
        self.removeBtn.hidden = NO;
    }
}

- (IBAction)done:(UIButton *)sender {
    
    [[TIoTCoreFamilySet shared] deleteFamilyMemberWithFamilyId:self.familyId memberId:self.memberInfo[@"UserID"] success:^(id  _Nonnull responseObject) {
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}



@end
