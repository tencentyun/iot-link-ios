//
//  TIoTLoginCustomView.m
//  LinkApp
//
//

#import "TIoTLoginCustomView.h"
#import "TIoTCoreXP2PBridge.h"
#import "TIoTAccessIDPickerView.h"
#import "TIoTCoreUserManage.h"
#import "TIoTRegionPickerView.h"

@interface TIoTLoginCustomView ()<UITextFieldDelegate>
//选择应用端
@property (nonatomic, strong) UIButton *APIBtn;
@property (nonatomic, strong) UIButton *withoutAPIBtn;
//AccessID
@property (nonatomic, strong) UIButton *choiceIDBtn;
@property (nonatomic, strong) TIoTAccessIDPickerView *choiceAccessIDView;
@property (nonatomic, strong) TIoTRegionPickerView *choiceRegionNameView;
@property (nonatomic, readwrite, strong) NSString *regionIDString;
@end

@implementation TIoTLoginCustomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initLoginView];
    }
    return self;
}

- (void)initLoginView {
    
    CGFloat kWidthPadding = 16;
    CGFloat kItemHeight = 56;
    CGFloat kAPIBtnWidthHeight = 24;
    CGFloat kInputItemLeftPadding = 150;
    CGFloat kChoiceRegionBtnWidth = 60;
    
    //第一行 选择应用端   应用端选择先隐藏预留
    /*
    UILabel *APITypeLabel = [[UILabel alloc]init];
    [APITypeLabel setLabelFormateTitle:@"应用端API" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self addSubview:APITypeLabel];
    [APITypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left).offset(kWidthPadding);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    self.APIBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.APIBtn.layer.cornerRadius = kAPIBtnWidthHeight/2;
    [self addSubview:self.APIBtn];
    [self.APIBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kInputItemLeftPadding);
        make.width.height.mas_equalTo(kAPIBtnWidthHeight);
        make.centerY.equalTo(APITypeLabel);
    }];
    
    UILabel *APILabel = [[UILabel alloc]init];
    [APILabel setLabelFormateTitle:@"有" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentCenter];
    [self addSubview:APILabel];
    [APILabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.APIBtn);
        make.left.equalTo(self.APIBtn.mas_right).offset(8);
    }];
    
    self.withoutAPIBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.withoutAPIBtn];
    [self.withoutAPIBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.APIBtn);
        make.width.height.mas_equalTo(kAPIBtnWidthHeight);
        make.left.equalTo(APILabel.mas_right).offset(28);
    }];
    
    UILabel *withoutAPILabel = [[UILabel alloc]init];
    [withoutAPILabel setLabelFormateTitle:@"无" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentCenter];
    [self addSubview:withoutAPILabel];
    [withoutAPILabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.withoutAPIBtn.mas_right).offset(8);
        make.centerY.equalTo(self.withoutAPIBtn);
    }];
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [UIColor colorWithHexString:@"#BBBBBB"];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthPadding);
        make.right.equalTo(self);
        make.top.equalTo(APITypeLabel.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    */
    
    //第二行 AccessID
    UILabel *accessIDLabel = [[UILabel alloc]init];
    [accessIDLabel setLabelFormateTitle:@"Access ID" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self addSubview:accessIDLabel];
    [accessIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthPadding);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    self.choiceIDBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.choiceIDBtn addTarget:self action:@selector(chooseAccessID) forControlEvents:UIControlEventTouchUpInside];
    [self.choiceIDBtn setImage:[UIImage imageNamed:@"dir_down"] forState:UIControlStateNormal];
    [self addSubview:self.choiceIDBtn];
    [self.choiceIDBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kAPIBtnWidthHeight);
        make.right.equalTo(self.mas_right).offset(-kWidthPadding);
        make.centerY.equalTo(accessIDLabel);
    }];
    
    self.accessID = [[UITextField alloc]init];
    self.accessID.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    self.accessID.returnKeyType = UIReturnKeyDone;
    self.accessID.placeholder = @"请输入Access ID";
    self.accessID.delegate = self;
    self.accessID.textAlignment = NSTextAlignmentLeft;
    self.accessID.returnKeyType = UIReturnKeyDone;
    [self addSubview:self.accessID];
    [self.accessID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kInputItemLeftPadding);
        make.centerY.equalTo(accessIDLabel);
        make.height.equalTo(accessIDLabel);
        make.right.equalTo(self.mas_right).offset(-kWidthPadding - kAPIBtnWidthHeight);
    }];
    
    
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [UIColor colorWithHexString:kVideoDemoPlaceColor];
    [self addSubview:line2];
    [line2  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthPadding);
        make.right.equalTo(self);
        make.top.equalTo(accessIDLabel.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    
    //第三行 Access Token
    UILabel *accessTokenLabel = [[UILabel alloc]init];
    [accessTokenLabel setLabelFormateTitle:@"Access Token" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self addSubview:accessTokenLabel];
    [accessTokenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthPadding);
        make.top.equalTo(line2.mas_bottom);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    self.accessToken = [[UITextField alloc]init];
    self.accessToken.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    self.accessToken.placeholder = @"请输入Access Token";
    self.accessToken.delegate = self;
    self.accessToken.secureTextEntry = YES;
    self.accessToken.textAlignment = NSTextAlignmentLeft;
    self.accessToken.returnKeyType = UIReturnKeyDone;
    [self addSubview:self.accessToken];
    [self.accessToken mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kInputItemLeftPadding);
        make.centerY.equalTo(accessTokenLabel);
        make.height.equalTo(accessTokenLabel);
        make.right.equalTo(self.mas_right).offset(-kWidthPadding);
    }];
    
    UIView *line3 = [[UIView alloc]init];
    line3.backgroundColor = [UIColor colorWithHexString:kVideoDemoPlaceColor];
    [self addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accessTokenLabel.mas_bottom);
        make.height.mas_equalTo(1);
        make.left.right.equalTo(line2);
    }];
    
    //Product ID
    UILabel *productIDLabel = [[UILabel alloc]init];
    [productIDLabel setLabelFormateTitle:@"Product ID" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self addSubview:productIDLabel];
    [productIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthPadding);
        make.top.equalTo(line3.mas_bottom);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    self.productID = [[UITextField alloc]init];
    self.productID.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    self.productID.placeholder = @"请输入Product ID";
    self.productID.delegate = self;
    self.productID.secureTextEntry = YES;
    self.productID.textAlignment = NSTextAlignmentLeft;
    self.productID.returnKeyType = UIReturnKeyDone;
    [self addSubview:self.productID];
    [self.productID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kInputItemLeftPadding);
        make.centerY.equalTo(productIDLabel);
        make.height.equalTo(productIDLabel);
        make.right.equalTo(self.mas_right).offset(-kWidthPadding);
    }];
    
    UIView *line4 = [[UIView alloc]init];
    line4.backgroundColor = [UIColor colorWithHexString:kVideoDemoPlaceColor];
    [self addSubview:line4];
    [line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(productIDLabel.mas_bottom);
        make.height.mas_equalTo(1);
        make.left.right.equalTo(line2);
    }];
    
    //地域
    self.regionConettString = @"中国";
    self.regionIDString = @"ap-guangzhou";
    
    UILabel *regionLabel = [[UILabel alloc]init];
    [regionLabel setLabelFormateTitle:@"地域名称" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self addSubview:regionLabel];
    [regionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthPadding);
        make.top.equalTo(line4.mas_bottom);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    UIButton *choiceRegion = [UIButton buttonWithType:UIButtonTypeSystem];
    [choiceRegion setButtonFormateWithTitlt:@"选择地域" titleColorHexString:kMainThemeColor font:[UIFont wcPfRegularFontOfSize:14]];
    [choiceRegion addTarget:self action:@selector(chooseRegionName) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:choiceRegion];
    [choiceRegion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kChoiceRegionBtnWidth);
        make.top.bottom.equalTo(regionLabel);
        make.right.equalTo(self.mas_right).offset(-kWidthPadding);
        make.centerY.equalTo(regionLabel);
    }];
    
    self.regionContent = [[UILabel alloc]init];
    [self.regionContent setLabelFormateTitle:self.regionConettString font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:kVideoDemoPlaceColor textAlignment:NSTextAlignmentLeft];
    [self addSubview:self.regionContent];
    [self.regionContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kInputItemLeftPadding);
        make.centerY.equalTo(regionLabel);
        make.height.equalTo(regionLabel);
        make.right.equalTo(choiceRegion.mas_left);
    }];
    
    UIView *line5 = [[UIView alloc]init];
    line5.backgroundColor = [UIColor colorWithHexString:kVideoDemoPlaceColor];
    [self addSubview:line5];
    [line5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(regionLabel.mas_bottom);
        make.height.mas_equalTo(1);
        make.left.right.equalTo(line2);
    }];
    
    
    //选择 多媒体SDK按钮先隐藏预留
    UIButton *mediaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [mediaBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self addSubview:mediaBtn];
    mediaBtn.hidden = YES;
    [mediaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthPadding);
        make.width.height.mas_equalTo(kAPIBtnWidthHeight);
        make.top.equalTo(line4.mas_bottom).offset(21);
    }];
    
    UILabel *mediaLabel = [[UILabel alloc]init];
    mediaLabel.hidden = YES;
    [self addSubview:mediaLabel];
    [mediaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(mediaBtn.mas_right).offset(8);
        make.centerY.equalTo(mediaBtn.mas_centerY);
        make.right.equalTo(self.mas_right);
    }];
    
    //数据帧写入文件
    UISwitch *fileSwitch = [[UISwitch alloc] init];
    [fileSwitch addTarget:self action:@selector(changeWriteFileSwitch:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:fileSwitch];
    [fileSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthPadding);
//        make.width.height.mas_equalTo(kAPIBtnWidthHeight);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(35);
        make.top.equalTo(line4.mas_bottom).offset(21);
    }];
    
    UILabel *fileSwitchTip = [[UILabel alloc]init];
    [fileSwitchTip setLabelFormateTitle:@"数据帧写入文件" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self addSubview:fileSwitchTip];
    [fileSwitchTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(fileSwitch.mas_centerY);
        make.left.equalTo(fileSwitch.mas_right).offset(20);
        make.right.equalTo(self.mas_right);
    }];
    fileSwitch.hidden = YES;
    fileSwitchTip.hidden = YES;
    
    self.secretIDString = @"";
    self.secretKeyString = @"";
    self.productIDString = @"";
}

- (void)changeWriteFileSwitch:(UISwitch *)sender {
    [TIoTCoreXP2PBridge sharedInstance].writeFile = sender.on;
}

- (void)chooseAccessID {
    
    [self hideKeyBoard];
    
    __weak typeof (self) weakSelf = self;
    self.choiceAccessIDView = [[TIoTAccessIDPickerView alloc]init];
    self.choiceAccessIDView.defaultAccessID = self.accessID.text?:@"";
    self.choiceAccessIDView.accessIDStringBlock = ^(NSString * _Nonnull accessIDString) {
        weakSelf.accessID.text = accessIDString?:@"";
        
        NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
        NSDictionary *tokenAndProductIDDic = [NSDictionary dictionaryWithDictionary:[defaluts objectForKey:weakSelf.accessID.text?:@""]];
        if (tokenAndProductIDDic != nil) {
            weakSelf.accessToken.text = [tokenAndProductIDDic objectForKey:@"AccessTokenString"];
            weakSelf.productID.text = [tokenAndProductIDDic objectForKey:@"productIDString"];
            weakSelf.regionContent.text = [tokenAndProductIDDic objectForKey:@"regionNameString"];
        }
    };
    [[UIApplication sharedApplication].delegate.window addSubview:self.choiceAccessIDView];
    [self.choiceAccessIDView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.top.equalTo([UIApplication sharedApplication].delegate.window);
    }];
}  

//选择域名方法
- (void)chooseRegionName {
    [self hideKeyBoard];
    
    __weak typeof (self) weakSelf = self;
    self.choiceRegionNameView = [[TIoTRegionPickerView alloc]init];
    self.choiceRegionNameView.regionStringBlock = ^(NSString * _Nonnull regionString, NSString * _Nonnull regioinID) {
        weakSelf.regionContent.text = regionString?:@"";
        weakSelf.regionIDString = regioinID;
    };
    [[UIApplication sharedApplication].delegate.window addSubview:self.choiceRegionNameView];
    [self.choiceRegionNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.top.equalTo([UIApplication sharedApplication].delegate.window);
    }];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == self.accessID) {
        self.secretIDString = textField.text;
    }
    if (textField == self.accessToken) {
        self.secretKeyString = textField.text;
    }
    if (textField == self.productID) {
        self.productIDString = textField.text;
    }
    
    [self hideKeyBoard];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.accessID) {
        self.secretIDString = textField.text;
    }
    if (textField == self.accessToken) {
        self.secretKeyString = textField.text;
    }
    if (textField == self.productID) {
        self.productIDString = textField.text;
    }

    [self hideKeyBoard];
    return YES;
}

- (void)hideKeyBoard {
    [self.accessID resignFirstResponder];
    [self.accessToken resignFirstResponder];
    [self.productID resignFirstResponder];
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
    
    if (textField == self.accessID) {
        self.secretIDString = inputString;
    }
    if (textField == self.accessToken) {
        self.secretKeyString = inputString;
    }
    if (textField == self.productID) {
        self.productIDString = inputString;
    }
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
