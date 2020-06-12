//
//  WCAddRoomVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTAddRoomVC.h"

@interface TIoTAddRoomVC ()
@property (weak, nonatomic) IBOutlet UITextField *roomTF;

@end

@implementation TIoTAddRoomVC

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
    NSDictionary *param = @{@"FamilyId":self.familyId,@"Name":self.roomTF.text};
    [[TIoTRequestObject shared] post:AppCreateRoom Param:param success:^(id responseObject) {
        [HXYNotice addUpdateRoomListPost];
        [self cancel];
    } failure:^(NSString *reason, NSError *error) {
        
    }];
}



@end
