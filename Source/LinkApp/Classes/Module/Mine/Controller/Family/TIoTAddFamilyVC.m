//
//  WCAddFamilyVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTAddFamilyVC.h"
#import "TIoTSingleCustomButton.h"
#import "TIoTAddFamilyCell.h"

@interface TIoTAddFamilyVC ()<UITableViewDelegate,UITableViewDataSource>
//@property (weak, nonatomic) IBOutlet UITextField *nameL;
//@property (weak, nonatomic) IBOutlet UITextField *addressL;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) TIoTSingleCustomButton *singleButton;
@end

@implementation TIoTAddFamilyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"add_family", @"添加家庭");
    
//    [self.nameL addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    CGFloat kTopPadding = 20;
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(96);
        if (@available(iOS 11.0,*)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kTopPadding);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64*kScreenAllHeightScale + kTopPadding);
        }
    }];
    
    CGFloat kLeftPadding = 15;
    CGFloat kBackViewHeight = 40;
    
    __weak typeof(self)weakSelf = self;
    self.singleButton = [[TIoTSingleCustomButton alloc]init];
    self.singleButton.kLeftRightPadding = kLeftPadding;
    [self.singleButton singleCustomButtonStyle:SingleCustomButtonConfirm withTitle:NSLocalizedString(@"confirm", @"确定")];
    [self.singleButton singleCustomBUttonBackGroundColor:kNoSelectedHexColor isSelected:NO];
    self.singleButton.singleAction = ^{
        NSMutableDictionary *nameDic = weakSelf.dataArray[0];
        NSMutableDictionary *addressDic = weakSelf.dataArray[1];
        NSDictionary *param = @{@"Name":nameDic[@"value"]?:@"",@"Address":addressDic[@"value"]?:@""};
        [[TIoTRequestObject shared] post:AppCreateFamily Param:param success:^(id responseObject) {
            [HXYNotice addUpdateFamilyListPost];
            [weakSelf cancel];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    };
    self.singleButton.kLeftRightPadding = kLeftPadding;
    [self.view addSubview:self.singleButton];
    [self.singleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kBackViewHeight);
        make.top.equalTo(self.tableView.mas_bottom).offset(kTopPadding*2);
    }];
}

#pragma mark -UITableViewDelegate And UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAddFamilyCell *cell = [TIoTAddFamilyCell cellForTableView:tableView];
    NSMutableDictionary *dic = self.dataArray[indexPath.row];
    cell.titleString = dic[@"title"];
    cell.placeHoldString = dic[@"placeHold"];
    cell.contectString = dic[@"value"];
    if (indexPath.row == 0) {
        cell.familyType = FillFamilyTypeFamilyName;
    }
    __weak typeof(self)weakSelf = self;
    cell.fillMessageBlock = ^(NSString * _Nonnull contentString) {
        NSMutableDictionary *tempDic = weakSelf.dataArray[indexPath.row];
        [tempDic setValue:contentString?:@"" forKey:@"value"];
        [weakSelf.tableView reloadData];
        
        //循环遍历数据源中是否有空值，有：按钮不响应，反之则允许点击
        BOOL buttonIsEnable = NO;
        for (int i = 0; i<weakSelf.dataArray.count; i++) {
            NSMutableDictionary *tempDic = weakSelf.dataArray[i];
            
            if ([NSString isNullOrNilWithObject:tempDic[@"value"]] || [NSString isFullSpaceEmpty:tempDic[@"value"]]) {
                buttonIsEnable = NO;
            }else {
                buttonIsEnable = YES;
            }
        }
        
        if (buttonIsEnable == YES) {
            [self.singleButton singleCustomBUttonBackGroundColor:kIntelligentMainHexColor isSelected:YES];
        }else {
            [self.singleButton singleCustomBUttonBackGroundColor:kNoSelectedHexColor isSelected:NO];
        }
    };
    return cell;
}


#pragma mark - lazy loading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithArray:@[[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"family_name", @"家庭名称"),@"value":@"",@"placeHold":NSLocalizedString(@"fill_family_name", @"请输入家庭名称")}],
                                                      [NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"family_address", @"家庭位置"),@"value":@"",@"placeHold":NSLocalizedString(@"setting_family_address", @"设置位置")}]]];
    }
    return _dataArray;
}

//- (void)setNav
//{
//    self.title = NSLocalizedString(@"add_family", @"添加家庭");
//    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", @"取消") style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
//    self.navigationItem.leftBarButtonItem = left;
//}


#pragma mark - evnet

//- (void)textFieldDidChange:(UITextField *)textField
//
//{
//    NSInteger kMaxLength = 10;
//    NSString *toBeString = textField.text;
//    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
//    if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
//        UITextRange *selectedRange = [textField markedTextRange];
//        //获取高亮部分
//        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
//        if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
//            if (toBeString.length > kMaxLength) {
//                textField.text = [toBeString substringToIndex:kMaxLength];
//
//            }
//
//        }
//        else{//有高亮选择的字符串，则暂不对文字进行统计和限制
//
//        }
//
//    }else{//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
//        if (toBeString.length > kMaxLength) {
//            textField.text = [toBeString substringToIndex:kMaxLength];
//
//        }
//
//    }
//
//}


//- (IBAction)done:(UIButton *)sender {
//
//    if (self.nameL.hasText && self.addressL.hasText) {
//        NSDictionary *param = @{@"Name":self.nameL.text,@"Address":self.addressL.text};
//        [[TIoTRequestObject shared] post:AppCreateFamily Param:param success:^(id responseObject) {
//            [HXYNotice addUpdateFamilyListPost];
//            [self cancel];
//        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
//
//        }];
//    }
//    else
//    {
//        [MBProgressHUD showMessage:NSLocalizedString(@"Complete_supplementary_information", @"请将信息填写完整") icon:@""];
//    }
//
//}

- (void)cancel
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
