//
//  TIoTWiredDistributionNetVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2020/12/30.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTWiredDistributionNetVC.h"
#import "UILabel+TIoTExtension.h"
#import "NSObject+additions.h"
#import "UIColor+Color.h"
#import "NSString+Extension.h"

#import "TIoTCoreAddDevice.h"
#import "GCDAsyncUdpSocket.h"

@interface TIoTWiredDistributionNetVC ()<UITextFieldDelegate,TIoTCoreAddDeviceDelegate>
@property (nonatomic, strong) TIoTCoreWired *wiredDisTributeNet;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) BOOL isSendSuccess;

@property (nonatomic, strong) UITextField *wifiName;
@property (nonatomic, strong) UITextField *wifiPassword;
@property (nonatomic, strong) UILabel *progressTip;
@property (nonatomic, strong) UITextField *token;
@property (nonatomic, strong) UITextField *port;
@property (nonatomic, strong) UITextField *addressID;

@property (nonatomic, strong) NSString *apSsid;
@property (nonatomic, strong) NSString *wifiNameString;
@property (nonatomic, strong) NSString *wifiPasswordString;
@property (nonatomic, strong) NSString *tokenString;
@property (nonatomic, strong) NSString *portString;
@property (nonatomic, strong) NSString *addressIDString;
@end

@implementation TIoTWiredDistributionNetVC

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self releaseAlloc];
}

- (void)dealloc {
    [self releaseAlloc];
}

- (void)releaseAlloc{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
    
    [self.wiredDisTributeNet stopConnect];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    [self initInformation];
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat kTopPadding = 20 + kNavBarAndStatusBarHeight;
    CGFloat kLeftPadding = 60;
    CGFloat kWidth = kScreenWidth - kLeftPadding*2;
    CGFloat kHeight = 40;
    CGFloat kInterval = 10;
    
    self.wifiName = [[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, kTopPadding, kWidth/2,kHeight)];
    self.wifiName.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.wifiName.font = [UIFont systemFontOfSize:18];
    self.wifiName.placeholder = @"DeviceName";
    self.wifiName.textAlignment = NSTextAlignmentLeft;
    self.wifiName.returnKeyType = UIReturnKeyDone;
    self.wifiName.delegate = self;
    self.wifiName.enabled = NO;
    [self.view addSubview:self.wifiName];
    
    self.wifiPassword = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.wifiName.frame)+kLeftPadding, kTopPadding, kWidth/2, kHeight)];
    self.wifiPassword.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.wifiPassword.font = [UIFont systemFontOfSize:18];
    self.wifiPassword.placeholder = @"ProductID";
    self.wifiPassword.enabled = NO;
    self.wifiPassword.textAlignment = NSTextAlignmentLeft;
    self.wifiPassword.returnKeyType = UIReturnKeyDone;
    self.wifiPassword.delegate = self;
    [self.view addSubview:self.wifiPassword];
    
    
    self.addressID = [[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.wifiPassword.frame)+kInterval, kWidth, kHeight)];
    self.addressID.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.addressID.font = [UIFont systemFontOfSize:18];
    self.addressID.placeholder = @"请输入组播/广播地址";
    self.addressID.textAlignment = NSTextAlignmentCenter;
    self.addressID.returnKeyType = UIReturnKeyDone;
    self.addressID.delegate = self;
    [self.view addSubview:self.addressID];
    
    self.progressTip = [[UILabel alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.addressID.frame)+kInterval, kWidth, kHeight)];
    [self setLabelFormateTitle:@"progress Tip " font:[UIFont systemFontOfSize:18] titleColorHexString:kMainThemeColor textAlignment:NSTextAlignmentCenter label:self.progressTip];
    [self.view addSubview:self.progressTip];
    
    self.token =[[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.progressTip.frame)+kInterval, kWidth, kHeight)];
    self.token.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.token.font = [UIFont systemFontOfSize:18];
    self.token.placeholder = @"请输入token";
    self.token.textAlignment = NSTextAlignmentCenter;
    self.token.returnKeyType = UIReturnKeyDone;
    self.token.delegate = self;
    [self.view addSubview:self.token];
        
    self.port =[[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.token.frame)+kInterval, kWidth, kHeight)];
    self.port.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.port.font = [UIFont systemFontOfSize:18];
    self.port.placeholder = @"请输入port";
    self.port.textAlignment = NSTextAlignmentCenter;
    self.port.returnKeyType = UIReturnKeyDone;
    self.port.delegate = self;
    [self.view addSubview:self.port];
    
    UIButton *startApConfigBuuton = [UIButton buttonWithType:UIButtonTypeCustom];
    startApConfigBuuton.frame = CGRectMake(kLeftPadding, CGRectGetMaxY(self.port.frame)+kInterval, kWidth, kHeight);
    [startApConfigBuuton setTitle:@"开始" forState:UIControlStateNormal];
    [startApConfigBuuton setTitleColor:[UIColor colorWithHexString:kMainThemeColor] forState:UIControlStateNormal];
    startApConfigBuuton.titleLabel.font = [UIFont systemFontOfSize:18];
    [startApConfigBuuton addTarget:self action:@selector(connectionSocket) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startApConfigBuuton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
    
    self.wifiNameString = @"";
    self.wifiPasswordString = @"";
    self.tokenString = @"";
    self.portString = @"7838";
    self.addressIDString = @"239.0.0.255";
}

- (void)initInformation {
    
    self.wifiName.text = @"";
    self.wifiNameString = self.wifiName.text;
    self.wifiPassword.text = @"";
    self.wifiPasswordString = self.wifiPassword.text;
    [self.view reloadInputViews];
}

#pragma mark 代理-TIoTCoreAddDeviceDelegate

/// 连接成功
- (void)wiredDistributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"--address--%@",address);
}
/// 连接失败
- (void)wiredDistributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error {
    NSLog(@"--error--%@",error);
}

/// 发送成功
- (void)wiredDistributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self connectFaildWith:@"发送信息成功"];
    });
}

/// 发送失败
- (void)wiredDistributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self connectFaildWith:@"发送信息失败"];
    });
}

/// 接收消息成功
- (void)wiredDistributionNetUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
//    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSError *jsonerror = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
    NSLog(@"收到设备端的响应 [%@:%d] %@", ip, port, dic);
    
    if (!jsonerror) {
        
        if ([dic.allKeys containsObject:@"status"] && [dic[@"status"] isEqualToString:@"online"]) {
            //重复发送广播
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(self.timer, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.wifiPassword.text = dic[@"productId"]?:@"";
                    self.wifiName.text = dic[@"deviceName"]?:@"";
                });
                
                if (self.isSendSuccess == YES) {
                    [self releaseAlloc];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self connectFaildWith:@"APP发送token成功"];
                    });
                    return;
                }
                
        #warning token 需通过自建服务器获取
                NSString *Token = self.tokenString?:@"";
                
                [self.wiredDisTributeNet sendDeviceMessage:@{@"productId":dic[@"productId"]?:@"",@"deviceName":dic[@"deviceName"]?:@"",@"token":Token}];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(59 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.isSendSuccess == YES) {
                        [self releaseAlloc];
                    }
                });

            });
            dispatch_resume(self.timer);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self connectFaildWith:@"设备上线,接收消息成功"];
            });
            
        }else if ([dic.allKeys containsObject:@"status"] && [dic[@"status"] isEqualToString:@"received"]) {
            //需要将第一次接收的productId 和 deviceName 保存，用户设备端再次发送确定消息中的信息对比，是否相等（用户多设备广播鉴别）
            dispatch_async(dispatch_get_main_queue(), ^{
                if (([self.wifiPassword.text isEqualToString:dic[@"productId"]] && ([self.wifiName.text isEqualToString:dic[@"deviceName"]]))) {
                    self.isSendSuccess = YES;
                }
            });
 
        }
        
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self connectFaildWith:@"接收消息失败"];
        });
    }
}

#pragma mark - event

- (void)connectionSocket {
    [self hideKeyBoard];
    
    [self releaseAlloc];
    
    self.isSendSuccess = NO;
    
    self.wifiPassword.text = @"";
    self.wifiName.text = @"";
    
    if ([NSString isNullOrNilWithObject:self.tokenString]) {
        [self connectFaildWith:@"token不能为空"];
        return;
    }
    
    if ([NSString isNullOrNilWithObject:self.addressIDString]) {
        [self connectFaildWith:@"组播/广播地址不能为空"];
        return;
    }
    
    if (![self judgeIsNumberByRegularExpressionWith:self.portString]) {
        [self connectFaildWith:@"port端口号非法"];
        return;
    }
    
    self.wiredDisTributeNet = [[TIoTCoreWired alloc]initWithPort:self.portString multicastGroupOrHost:self.addressIDString];
    
    self.wiredDisTributeNet.delegate = self;
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [self.wiredDisTributeNet monitorDeviceSignal];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(59 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD dismissInView:nil];
    });
}


- (BOOL)judgeIsNumberByRegularExpressionWith:(NSString *)str
{
   if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

- (void)connectFaildWith:(NSString *)test {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD dismissInView:nil];
        self.progressTip.text = test;
        [self.view reloadInputViews];
    });
}

- (void)hideKeyBoard {
    [self.wifiPassword resignFirstResponder];
    [self.wifiName resignFirstResponder];
    [self.token resignFirstResponder];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == self.wifiName) {
        self.wifiNameString = textField.text;
    }
    if (textField == self.wifiPassword) {
        self.wifiPasswordString = textField.text;
    }
    if (textField == self.token) {
            self.tokenString = textField.text;
        }
    if (textField == self.port) {
        self.portString = textField.text;
    }
    if (textField == self.addressID) {
        self.addressIDString = textField.text;
    }
    
    [self hideKeyBoard];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.wifiName) {
        self.wifiNameString = textField.text;
    }
    if (textField == self.wifiPassword) {
        self.wifiPasswordString = textField.text;
    }
    if (textField == self.token) {
            self.tokenString = textField.text;
        }
    if (textField == self.port) {
        self.portString = textField.text;
    }
    if (textField == self.addressID) {
        self.addressIDString = textField.text;
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
    
    if (textField == self.wifiName) {
        self.wifiNameString = inputString;
    }
    if (textField == self.wifiPassword) {
        self.wifiPasswordString = inputString;
    }
    if (textField == self.token) {
            self.tokenString = inputString;
        }
    if (textField == self.port) {
        self.portString = inputString;
    }
    if (textField == self.addressID) {
        self.addressIDString = inputString;
    }
    return YES;
}

- (void)setLabelFormateTitle:(NSString *)title font:(UIFont *)font titleColorHexString:(NSString *)titleColorString textAlignment:(NSTextAlignment)alignment label:(UILabel *)label {
    label.text = title;
    label.textColor = [UIColor colorWithHexString:titleColorString];
    label.font = font;
    label.textAlignment = alignment;
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
