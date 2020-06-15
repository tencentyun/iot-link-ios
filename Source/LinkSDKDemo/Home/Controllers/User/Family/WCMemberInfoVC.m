//
//  WCMemberInfoVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCMemberInfoVC.h"
#import <UIImageView+WebCache.h>
#import <QCFoundation/QCUserManage.h>

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
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:self.memberInfo[@"Avatar"]]];
    self.memberNick.text = self.memberInfo[@"NickName"];
    self.roleL.text = [self.memberInfo[@"Role"] integerValue] == 1 ? @"所有者" : @"成员";
    
    if (self.isOwner && ![[QCUserManage shared].userId isEqualToString:self.memberInfo[@"UserID"]]) {
        self.removeBtn.hidden = NO;
    }
}

- (IBAction)done:(UIButton *)sender {
    
    [[QCFamilySet shared] deleteFamilyMemberWithFamilyId:self.familyId memberId:self.memberInfo[@"UserID"] success:^(id  _Nonnull responseObject) {
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}



@end
