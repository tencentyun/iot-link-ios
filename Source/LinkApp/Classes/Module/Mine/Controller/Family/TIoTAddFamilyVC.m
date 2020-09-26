//
//  WCAddFamilyVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTAddFamilyVC.h"

@interface TIoTAddFamilyVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameL;
@property (weak, nonatomic) IBOutlet UITextField *addressL;

@end

@implementation TIoTAddFamilyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"add_family", @"添加家庭");
    
    [self.nameL addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//    [self setNav];
}

- (void)setNav
{
    self.title = NSLocalizedString(@"add_family", @"添加家庭");
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", @"取消") style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = left;
}


#pragma mark - evnet

- (void)textFieldDidChange:(UITextField *)textField

{
    NSInteger kMaxLength = 10;
    NSString *toBeString = textField.text;
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
                
            }
            
        }
        else{//有高亮选择的字符串，则暂不对文字进行统计和限制
            
        }
        
    }else{//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
            
        }
        
    }

}


- (IBAction)done:(UIButton *)sender {
    
    if (self.nameL.hasText && self.addressL.hasText) {
        NSDictionary *param = @{@"Name":self.nameL.text,@"Address":self.addressL.text};
        [[TIoTRequestObject shared] post:AppCreateFamily Param:param success:^(id responseObject) {
            [HXYNotice addUpdateFamilyListPost];
            [self cancel];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }
    else
    {
        [MBProgressHUD showMessage:NSLocalizedString(@"Complete_supplementary_information", @"请将信息填写完整") icon:@""];
    }
    
}

- (void)cancel
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
