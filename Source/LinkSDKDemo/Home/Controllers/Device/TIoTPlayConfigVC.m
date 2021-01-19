//
//  TIoTPlayConfigVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTPlayConfigVC.h"

#import "NSObject+additions.h"
#import "UIColor+Color.h"
#import "NSString+Extension.h"
#import "TIoTPlayListVC.h"

@interface TIoTPlayConfigVC ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *secretID;
@property (nonatomic, strong) UITextField *secretKey;
@property (nonatomic, strong) UITextField *productID;

@property (nonatomic, strong) NSString *secretIDString;
@property (nonatomic, strong) NSString *secretKeyString;
@property (nonatomic, strong) NSString *productIDString;
@end

@implementation TIoTPlayConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat kTopPadding = 40 + kNavBarAndStatusBarHeight;
    CGFloat kLeftPadding = 30;
    CGFloat kWidth = kScreenWidth - kLeftPadding*2;
    CGFloat kHeight = 40;
    CGFloat kInterval = 10;
    
    self.secretID = [[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, kTopPadding, kWidth,kHeight)];
    self.secretID.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.secretID.font = [UIFont systemFontOfSize:18];
    self.secretID.placeholder = @"请输入SecretID";
    self.secretID.textAlignment = NSTextAlignmentCenter;
    self.secretID.returnKeyType = UIReturnKeyDone;
    self.secretID.delegate = self;
    self.secretID.layer.cornerRadius = 10;
    self.secretID.layer.borderWidth = 1;
    self.productID.layer.borderColor = [UIColor blueColor].CGColor;
//    [self.view addSubview:self.secretID];
    
    self.secretKey = [[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.secretID.frame)+kInterval, kWidth, kHeight)];
    self.secretKey.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.secretKey.font = [UIFont systemFontOfSize:18];
    self.secretKey.placeholder = @"请输入SecretKey";
    self.secretKey.textAlignment = NSTextAlignmentCenter;
    self.secretKey.returnKeyType = UIReturnKeyDone;
    self.secretKey.delegate = self;
    self.secretKey.layer.cornerRadius = 10;
    self.secretKey.layer.borderWidth = 1;
    self.secretKey.layer.borderColor = [UIColor blueColor].CGColor;
//    [self.view addSubview:self.secretKey];
    
    self.productID =[[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.secretKey.frame)+kInterval, kWidth, kHeight)];
    self.productID.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.productID.font = [UIFont systemFontOfSize:18];
    self.productID.placeholder = @"请输入ProductID";
    self.productID.textAlignment = NSTextAlignmentCenter;
    self.productID.returnKeyType = UIReturnKeyDone;
    self.productID.delegate = self;
    self.productID.layer.cornerRadius = 10;
    self.productID.layer.borderWidth = 1;
    self.productID.layer.borderColor = [UIColor blueColor].CGColor;
//    [self.view addSubview:self.productID];
    
    UIButton *requestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    requestButton.frame = CGRectMake(kLeftPadding, 200+kInterval, kWidth, kHeight);
    [requestButton setTitle:@"获取PRODUCTIF下的设备列表" forState:UIControlStateNormal];
    [requestButton setTitleColor:[UIColor colorWithHexString:kMainThemeColor] forState:UIControlStateNormal];
    requestButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [requestButton addTarget:self action:@selector(requestDeviceList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:requestButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
    [self.secretID becomeFirstResponder];
    
    
    
    self.secretIDString = @"";
    self.secretKeyString = @"";
    self.productIDString = @"";
}

- (void)hideKeyBoard {
    [self.secretKey resignFirstResponder];
    [self.secretID resignFirstResponder];
    [self.productID resignFirstResponder];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == self.secretID) {
        self.secretIDString = textField.text;
    }
    if (textField == self.secretKey) {
        self.secretKeyString = textField.text;
    }
    if (textField == self.productID) {
        self.productIDString = textField.text;
    }
    
    [self hideKeyBoard];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.secretID) {
        self.secretIDString = textField.text;
    }
    if (textField == self.secretKey) {
        self.secretKeyString = textField.text;
    }
    if (textField == self.productID) {
        self.productIDString = textField.text;
    }

    [self hideKeyBoard];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *inputString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSInteger kMaxLength = 10;
    NSString *toBeString = inputString;
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (toBeString.length > kMaxLength) {
                inputString = [toBeString substringToIndex:kMaxLength];
            }

        }
        else{//有高亮选择的字符串，则暂不对文字进行统计和限制

        }

    }else{//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > kMaxLength) {
            inputString = [toBeString substringToIndex:kMaxLength];
        }

    }
    
    if (textField == self.secretID) {
        self.secretIDString = inputString;
    }
    if (textField == self.secretKey) {
        self.secretKeyString = inputString;
    }
    if (textField == self.productID) {
        self.productIDString = inputString;
    }
    return YES;
}

#pragma mark - event

- (void)setLabelFormateTitle:(NSString *)title font:(UIFont *)font titleColorHexString:(NSString *)titleColorString textAlignment:(NSTextAlignment)alignment label:(UILabel *)label {
    label.text = title;
    label.textColor = [UIColor colorWithHexString:titleColorString];
    label.font = font;
    label.textAlignment = alignment;
}

- (void)requestDeviceList {
    TIoTPlayListVC *playListVC = [[TIoTPlayListVC alloc]init];
    [self.navigationController pushViewController:playListVC animated:YES];
    
}
    
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
