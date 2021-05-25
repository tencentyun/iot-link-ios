//
//  WCAddRoomVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTCoreAddRoomVC.h"

@interface TIoTCoreAddRoomVC ()
@property (weak, nonatomic) IBOutlet UITextField *roomTF;

@end

@implementation TIoTCoreAddRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"add_room", @"添加房间");
//    [self setNav];
}

- (void)setNav
{
    self.title = NSLocalizedString(@"add_room", @"添加房间");
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", @"取消") style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = left;
}


- (void)cancel
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(UIButton *)sender {
    
    if (!self.roomTF.hasText) {
        [MBProgressHUD showMessage:NSLocalizedString(@"write_room_name", @"请填写房间名") icon:@""];
        return;
    }
    
    [[TIoTCoreFamilySet shared] createRoomWithFamilyId:self.familyId name:self.roomTF.text success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:NSLocalizedString(@"add_sucess", @"添加成功")];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
    
}



@end
