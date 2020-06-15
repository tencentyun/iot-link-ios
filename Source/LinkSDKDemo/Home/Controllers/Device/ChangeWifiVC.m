//
//  ChangeWifiVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/9.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "ChangeWifiVC.h"
#import <QCDeviceCenter/QCAddDevice.h>

#import <NetworkExtension/NEHotspotConfigurationManager.h>

@interface ChangeWifiVC ()<QCAddDeviceDelegate>

@property (nonatomic,strong) QCSoftAP *sa;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIButton *btn;


@property (nonatomic,copy) NSString *sig;//q

@end

@implementation ChangeWifiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    NSLog(@"==%@==%@",self.wName,self.wPassword);
    
}

- (IBAction)toSetting:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:@"App-prefs:root=WIFI"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        
    }];
}

- (IBAction)next:(UIButton *)sender {
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@"配网中"];
    
    _sa = [[QCSoftAP alloc] initWithSSID:self.wName PWD:self.wPassword];
    _sa.delegate = self;
    [_sa startAddDevice];
}

- (IBAction)bind:(id)sender {
    
    NSString *familyId = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstFamilyId"];
    NSAssert(familyId, @"家庭id");
    
    [[QCDeviceSet shared] bindDeviceWithSignatureInfo:self.sig inFamilyId:familyId roomId:@"" success:^(id  _Nonnull responseObject) {
        self.status.text = @"绑定设备成功";
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        self.status.text = reason;
    }];
}

- (void)onResult:(QCResult *)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD dismissInView:nil];
        if (result.code == 0) {
            
            self.sig = result.signatureInfo;
            self.status.text = @"配网成功，请切换至热点或移动网，确保手机网络畅通，然后点击绑定设备";
            [self.btn setHidden:NO];
        }
        else
        {
            self.status.text = result.errMsg;
        }
        
    });
    
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
