//
//  TIoTRegionViewController.m
//  LinkApp
//
//  Created by eagleychen on 2021/10/25.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTRegionViewController.h"
#import "TIoTSendPhoneCodeViewController.h"
#import "XWCountryCodeController.h"
#import "TIoTWebVC.h"
#import "TIoTChooseRegionVC.h"
#import "UILabel+TIoTExtension.h"
#import "UIButton+LQRelayout.h"
#import "TIoTAlertCustomView.h"
#import "TIoTOpensourceLicenseViewController.h"
#import "TIoTRegisterViewController.h"

static CGFloat const kLeftRightPadding = 16; //左右边距
static CGFloat const kHeightCell = 48; //每一项高度
static CGFloat const kWidthTitle = 80; //左侧title 提示宽度

@interface TIoTRegionViewController ()<UITextViewDelegate>
{
    BOOL _emailStyle;//false:手机，true:邮箱
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *areaCodeBtn;
@property (nonatomic, strong) UILabel *phoneAreaLabel;
@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UIButton *procolBtn;
@property (nonatomic, strong) UIButton *sendCodeBtn;

@property (nonatomic, strong) UIButton *deletePhoneBtn;
@property (nonatomic, strong) UIButton *deleteEmailBtn;

@property (nonatomic, strong) UIButton *areaCodeBtn2;
@property (nonatomic, strong) UILabel *phoneAreaLabel2;
@property (nonatomic, strong) UITextField *emailTF;

@property (nonatomic, copy) NSString *conturyCode;
@property (nonatomic, copy) NSString *conturyCode2;


@property (nonatomic, strong) UILabel *phoneTipLabel;
@property (nonatomic, strong) UILabel *emailTipLabel;
@end

@implementation TIoTRegionViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    //不选地区列表赋默认值
    [TIoTCoreUserManage shared].userRegion = @"ap-guangzhou";
    [TIoTCoreUserManage shared].userRegionId = @"1";
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_emailStyle) {
        if (![NSString isNullOrNilWithObject:self.emailTF.text]) {
            [TIoTCoreUserManage shared].signIn_Email_Address = self.emailTF.text;
        }
    }else {
        if (![NSString isNullOrNilWithObject:self.phoneTF.text]) {
            [TIoTCoreUserManage shared].signIn_Phone_Numner = self.phoneTF.text;
        }
    }
}

#pragma mark privateMethods
- (void)setupUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"authentation_resister_title", @"国家/地区");
    self.conturyCode = @"86";
    self.conturyCode2 = @"86";
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64);
        }
        make.height.mas_equalTo(kHeightCell*2); //30为顶部空白 2两条分割线
    }];
    
    [self showPhoneRegisterStyle];
    
    UILabel *contentinfo = [[UILabel alloc] init];
    [contentinfo setText:NSLocalizedString(@"authentation_resister_privacy", nil)];
    [contentinfo setTextColor:[UIColor colorWithHexString:kPhoneEmailHexColor]];
    [contentinfo setFont:[UIFont wcPfRegularFontOfSize:16]];
    [contentinfo setNumberOfLines:0];
    [self.view addSubview:contentinfo];
    [contentinfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLeftRightPadding);
        make.right.equalTo(self.view).offset(-kLeftRightPadding);
        make.top.equalTo(self.scrollView.mas_bottom).offset(16);
    }];
    

    
    self.sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendCodeBtn setTitle:NSLocalizedString(@"next", @"下一步") forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.sendCodeBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateDisabled];
    self.sendCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.sendCodeBtn addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    self.sendCodeBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    self.sendCodeBtn.enabled = YES;
    self.sendCodeBtn.layer.cornerRadius = 20;
    [self.view addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kLeftRightPadding);
        make.top.equalTo(contentinfo.mas_bottom).offset(24);
        make.right.equalTo(self.view).offset(-kLeftRightPadding);
        make.height.mas_equalTo(kHeightCell - 8);
    }];
 
    [self refreshUserActionItems];
    
}


#pragma mark - 显示用户之前操作项
- (void)refreshUserActionItems {
    
    // 1、对区域和手机号、邮箱内容赋值或填充  2、对手机号、邮箱格式检测
    if (_emailStyle) {
        
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_countryCode]) {
            self.conturyCode2 = [TIoTCoreUserManage shared].signIn_countryCode;
            self.phoneAreaLabel2.text = [NSString stringWithFormat:@"(+%@)",[TIoTCoreUserManage shared].signIn_countryCode];
        }
        
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_Title]) {
            [self.areaCodeBtn2 setTitle:[NSString stringWithFormat:@"%@",[TIoTCoreUserManage shared].signIn_Title] forState:UIControlStateNormal];
        }
        
    }else {
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_countryCode]) {
            self.conturyCode = [TIoTCoreUserManage shared].signIn_countryCode;
            self.phoneAreaLabel.text = [NSString stringWithFormat:@"(+%@)",[TIoTCoreUserManage shared].signIn_countryCode];
        }
        
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_Title]) {
            [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",[TIoTCoreUserManage shared].signIn_Title] forState:UIControlStateNormal];
        }
    }
    
    if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_Phone_Numner]) {
        self.phoneTF.text = [TIoTCoreUserManage shared].signIn_Phone_Numner;
    }
    
    if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_Email_Address]) {
        self.emailTF.text = [TIoTCoreUserManage shared].signIn_Email_Address;
    }
}

- (void)showPhoneRegisterStyle {
    //先显示手机注册
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.equalTo(self.scrollView);
        make.width.height.equalTo(self.scrollView);
    }];
}


#pragma mark - eventResponse

- (void)choseAreaCode{
    
    TIoTChooseRegionVC *regionVC = [[TIoTChooseRegionVC alloc]init];
    
    regionVC.returnRegionBlock = ^(NSString * _Nonnull Title,NSString * _Nonnull region,NSString * _Nonnull RegionID,NSString *_Nullable CountryCode) {
    
        if (self->_emailStyle == NO) {
            self.conturyCode = CountryCode;
            [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
            self.phoneAreaLabel.text = [NSString stringWithFormat:@"(+%@)",CountryCode];
            [TIoTCoreUserManage shared].signIn_countryCode = CountryCode;
            [TIoTCoreUserManage shared].signIn_Title = Title;
        }else {
             self.conturyCode2 = CountryCode;
            [self.areaCodeBtn2 setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
            self.phoneAreaLabel2.text = [NSString stringWithFormat:@"(+%@)",CountryCode];
            [TIoTCoreUserManage shared].signIn_countryCode = CountryCode;
            [TIoTCoreUserManage shared].signIn_Title = Title;
        }
        
    };
    [self.navigationController pushViewController:regionVC animated:YES];
}

- (void)registStyleChange:(UIButton *)sender
{
    [self.view endEditing:YES];
    self.sendCodeBtn.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
    self.sendCodeBtn.enabled = NO;
    if ([sender.titleLabel.text containsString:NSLocalizedString(@"mobile_phone_register", @"手机注册")]) {
        _emailStyle = NO;
        self.title = NSLocalizedString(@"mobile_phone_register", @"手机注册");
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//        self.emailTF.text = @"";
        [sender setTitle:NSLocalizedString(@"email_to_register", @"使用邮箱注册") forState:UIControlStateNormal];
        [TIoTCoreUserManage shared].signIn_Email_Address = self.emailTF.text;
    }
    else
    {
        _emailStyle = YES;
        self.title = NSLocalizedString(@"email_register", @"邮箱注册");
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
//        self.phoneTF.text = @"";
        [sender setTitle:NSLocalizedString(@"mobile_phone_number_to_register", @"使用手机注册") forState:UIControlStateNormal];
        [TIoTCoreUserManage shared].signIn_Phone_Numner = self.phoneTF.text;
        if (![NSString isNullOrNilWithObject:self.emailTF.text]) {
        }
        
    }
    
    [self refreshUserActionItems];
}

- (void)sendCode:(id)sender{    
    TIoTRegisterViewController *registerVC = [[TIoTRegisterViewController alloc]init];
    [self.navigationController pushViewController:registerVC animated:YES];
}




#pragma mark setter or getter
- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.clipsToBounds = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = NO;
    }
    return _scrollView;
}

- (UIView *)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        
        UILabel *contryLabel = [[UILabel alloc]init];
        [contryLabel setLabelFormateTitle:NSLocalizedString(@"contry_region", @"国家/地区") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
        [_contentView addSubview:contryLabel];
        [contryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kLeftRightPadding);
            make.top.mas_equalTo(30*kScreenAllHeightScale);
            make.height.mas_equalTo(kHeightCell);
            make.width.mas_equalTo(kWidthTitle);
        }];
        
        self.areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
        [self.areaCodeBtn setTitleColor:[UIColor colorWithHexString:kRegionHexColor] forState:UIControlStateNormal];
        self.areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.areaCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_contentView addSubview:self.areaCodeBtn];
        [self.areaCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(contryLabel);
            make.left.equalTo(contryLabel.mas_right);
            make.height.mas_equalTo(kHeightCell);
        }];
        
        self.phoneAreaLabel = [[UILabel alloc]init];
        [self.phoneAreaLabel setLabelFormateTitle:@"(+86)" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kRegionHexColor textAlignment:NSTextAlignmentLeft];
        [_contentView addSubview:self.phoneAreaLabel];
        [self.phoneAreaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.areaCodeBtn.mas_right).offset(5);
            make.centerY.equalTo(contryLabel);
            make.height.mas_equalTo(kHeightCell);
        }];
        
        UIImageView *imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:@"mineArrow"];
        [_contentView addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-kLeftRightPadding);
            make.centerY.equalTo(contryLabel);
            make.width.height.mas_equalTo(18);
        }];
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = kLineColor;
        [_contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.bottom.equalTo(contryLabel.mas_bottom).offset(-1);
            make.leading.mas_equalTo(kLeftRightPadding);
            make.trailing.mas_equalTo(0);
        }];
        
        UIButton *chooseContryAreaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [chooseContryAreaBtn addTarget:self action:@selector(choseAreaCode) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:chooseContryAreaBtn];
        [chooseContryAreaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(0);
            make.top.equalTo(contryLabel.mas_top);
            make.bottom.equalTo(contryLabel.mas_bottom);
        }];
    }
    return _contentView;
}

@end
