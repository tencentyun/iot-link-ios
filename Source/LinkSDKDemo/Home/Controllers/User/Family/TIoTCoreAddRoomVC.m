//
//  WCAddRoomVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCAddRoomVC.h"

@interface WCAddRoomVC ()
@property (weak, nonatomic) IBOutlet UITextField *roomTF;

@end

@implementation WCAddRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加房间";
//    [self setNav];
}

- (void)setNav
{
    self.title = @"添加房间";
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = left;
}


- (void)cancel
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(UIButton *)sender {
    
    if (!self.roomTF.hasText) {
        [MBProgressHUD showMessage:@"请填写房间名" icon:@""];
        return;
    }
    
    [[QCFamilySet shared] createRoomWithFamilyId:self.familyId name:self.roomTF.text success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:@"添加成功"];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
    
}



@end
