//
//  TIoTAreaNetworkConfigVC.m
//  LinkSDKDemo

#import "TIoTAreaNetworkConfigVC.h"
#import "TIoTAreaNetworkPreviewVC.h"
#import "TIoTAreaNetworkDeviceCell.h"
#import "TIoTLocalNetDetch.h"
#import <YYModel.h>
#import "TIoTAreaNetDetectionModel.h"

static NSString * kAreaNetworkDeviceCellID = @"kAreaNetworkDeviceCellID";

@interface TIoTAreaNetworkConfigVC ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,TIoTAreaNetworkDeviceCellDelegate,TIoTLocalNetDetchDelegate>
@property (nonatomic, strong) UITextField *productID;
@property (nonatomic, strong) UITextField *clientToken;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *productIDString;
@property (nonatomic, strong) NSString *clientTokenString;
@property (nonatomic, strong) TIoTLocalNetDetch *localDetch;
@property (nonatomic, strong) NSMutableArray *detectDataArray;
@end

@implementation TIoTAreaNetworkConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    [self initVariable];
}

- (void)dealloc {
    [self.localDetch stopLocalMonitor];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"IoT Video (局域网)";
    
    CGFloat kWidthPadding = 16;
    CGFloat kItemHeight = 56;
    CGFloat kAPIBtnWidthHeight = 24;
    CGFloat kInputItemLeftPadding = 150;
    
    //第一行
    UILabel *productIDLabel = [[UILabel alloc]init];
    [productIDLabel setLabelFormateTitle:@"Product ID" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.view addSubview:productIDLabel];
    [productIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64).offset(20);
        }
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    self.productID = [[UITextField alloc]init];
    self.productID.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    self.productID.returnKeyType = UIReturnKeyDone;
    self.productID.placeholder = @"请输入Product ID";
    self.productID.delegate = self;
    self.productID.textAlignment = NSTextAlignmentLeft;
    self.productID.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.productID];
    [self.productID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kInputItemLeftPadding);
        make.centerY.equalTo(productIDLabel);
        make.height.equalTo(productIDLabel);
        make.right.equalTo(self.view.mas_right).offset(-kWidthPadding - kAPIBtnWidthHeight);
    }];
    
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [UIColor colorWithHexString:kVideoDemoPlaceColor];
    [self.view addSubview:line2];
    [line2  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.right.equalTo(self.view);
        make.top.equalTo(productIDLabel.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    //第二行
    UILabel *clientTokenLabel = [[UILabel alloc]init];
    [clientTokenLabel setLabelFormateTitle:@"client Token" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.view addSubview:clientTokenLabel];
    [clientTokenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.top.equalTo(line2.mas_bottom);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    self.clientToken = [[UITextField alloc]init];
    self.clientToken.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    self.clientToken.placeholder = @"请输入Client Token";
    self.clientToken.delegate = self;
//    self.clientToken.secureTextEntry = YES;
    self.clientToken.textAlignment = NSTextAlignmentLeft;
    self.clientToken.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.clientToken];
    [self.clientToken mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kInputItemLeftPadding);
        make.centerY.equalTo(clientTokenLabel);
        make.height.equalTo(clientTokenLabel);
        make.right.equalTo(self.view.mas_right).offset(-kWidthPadding);
    }];
    
    UIView *line3 = [[UIView alloc]init];
    line3.backgroundColor = [UIColor colorWithHexString:kVideoDemoPlaceColor];
    [self.view addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(clientTokenLabel.mas_bottom);
        make.height.mas_equalTo(1);
        make.left.right.equalTo(line2);
    }];
    
    UIButton *detectDeviceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    detectDeviceBtn.backgroundColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    [detectDeviceBtn setButtonFormateWithTitlt:@"探测设备" titleColorHexString:@"#FFFFFF" font:[UIFont wcPfRegularFontOfSize:17]];
    [detectDeviceBtn addTarget:self action:@selector(detectEquipment) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:detectDeviceBtn];
    [detectDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.right.equalTo(self.view.mas_right).offset(-kWidthPadding);
        make.top.equalTo(line3.mas_bottom).offset(30);
        make.height.mas_equalTo(45);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(detectDeviceBtn.mas_bottom).offset(30);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)initVariable {
    self.localDetch = [[TIoTLocalNetDetch alloc]init];
    self.localDetch.delegate = self;
    [self.localDetch startLocalMonitorService:nil];
}

///MARK: 探测设备
- (void)detectEquipment {
    [self.localDetch sendUDPData:self.productIDString?:@"" clientToken:self.clientTokenString?:@""];
    [self hideKeyBoard];
}

#pragma mark - 探测代理回调
- (void)reviceDeviceMessage:(NSData *)deviceMessage {
    if (deviceMessage != nil) {
        NSString *jsonString = [[NSString alloc]initWithData:deviceMessage encoding:NSUTF8StringEncoding];
        TIoTAreaNetDetectionModel *model = [TIoTAreaNetDetectionModel yy_modelWithJSON:jsonString];
        
        //添加探测到的设备，刷新列表, 停止探测
        if (self.detectDataArray != nil) {
            if (self.detectDataArray.count == 0) {
                [self.detectDataArray addObject:model];
            }else {
                [self.detectDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    TIoTAreaNetDetectionModel *detectedModel = obj;
                    if (![detectedModel.params.deviceName isEqualToString:model.params.deviceName]) {
                        [self.detectDataArray addObject:model];
                    }
                }];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }
    }
}

#pragma mark - UITableViewDelegate And TableViewDataDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.detectDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAreaNetworkDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:kAreaNetworkDeviceCellID forIndexPath:indexPath];
    cell.delegate = self;
    if (self.detectDataArray.count != 0 && indexPath.row <= self.detectDataArray.count-1) {
        cell.rspDetectionDeviceModel = self.detectDataArray[indexPath.row];
    }
    return cell;
}

#pragma mark - cell delegate
- (void)previewAreaNetworkDetectDevice  {
    TIoTAreaNetworkPreviewVC *liveVC = [[TIoTAreaNetworkPreviewVC alloc]init];
    [self.navigationController pushViewController:liveVC animated:YES];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == self.productID) {
        self.productIDString = textField.text;
    }
    if (textField == self.clientToken) {
        self.clientTokenString = textField.text;
    }
    
    [self hideKeyBoard];
    return YES;
}

- (void)hideKeyBoard {
    [self.productID resignFirstResponder];
    [self.clientToken resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.productID) {
        self.productIDString = textField.text;
    }
    if (textField == self.clientToken) {
        self.clientTokenString = textField.text;
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
    
    if (textField == self.productID) {
        self.productIDString = textField.text;
    }
    if (textField == self.clientToken) {
        self.clientTokenString = textField.text;
    }
    return YES;
}

#pragma mark - lazy load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        [_tableView registerClass:[TIoTAreaNetworkDeviceCell class] forCellReuseIdentifier:kAreaNetworkDeviceCellID];
    }
    return _tableView;
}

- (NSMutableArray *)detectDataArray {
    if (!_detectDataArray) {
        _detectDataArray = [[NSMutableArray alloc]init];
    }
    return _detectDataArray;
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
