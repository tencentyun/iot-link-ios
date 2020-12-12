//
//  TIoTChoseFamilyVC.m
//  TIoTLinkKit
//
//  Created by ccharlesren on 2020/12/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTChoseFamilyVC.h"
#import "TIoTIntelligentBottomActionView.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTChoseFamilyCell.h"
#import "FamilyModel.h"
#import "TIoTConfigHardwareViewController.h"

@interface TIoTChoseFamilyVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TIoTIntelligentBottomActionView * nextButtonView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) NSArray *families;
@property (nonatomic, strong) FamilyModel *selectedModel;
@property (nonatomic, strong) NSDictionary *configData;
@end

@implementation TIoTChoseFamilyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
    
    [self getFamilyListData];
}

- (void)setupViews {
    self.title = NSLocalizedString(@"choose_family", @"选择家庭");
    
    CGFloat kBottomViewHeight = 90;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale);
        }
        make.bottom.equalTo(self.view.mas_bottom).offset(-kBottomViewHeight);
    }];

    [self.view addSubview:self.nextButtonView];
    [self.nextButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
}

- (void)getFamilyListData {
    [[TIoTRequestObject shared] post:AppGetFamilyList Param:@{} success:^(id responseObject) {
        self.families = [NSArray yy_modelArrayWithClass:[FamilyModel class] json:responseObject[@"FamilyList"]];
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [self.tableView reloadData];
        TIoTChoseFamilyCell *cell = [self.tableView cellForRowAtIndexPath:index];
        cell.selected = YES;
        self.selectedModel = self.families[0];
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            
        }];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.families.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTChoseFamilyCell *cell = [TIoTChoseFamilyCell cellForTableView:tableView];
    cell.model = self.families[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedModel = self.families[indexPath.row];
}

#pragma mark - event
- (void)jumpConfigVC:(NSString *)title{
    TIoTConfigHardwareViewController *vc = [[TIoTConfigHardwareViewController alloc] init];
    vc.configurationData = self.configData;
    if ([title isEqualToString:NSLocalizedString(@"smart_config", @"智能配网")]) {
        vc.configHardwareStyle = TIoTConfigHardwareStyleSmartConfig;
    } else {
        vc.configHardwareStyle = TIoTConfigHardwareStyleSoftAP;
    }
    vc.roomId = self.roomId?:@"";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - lazy loading

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionHeaderHeight = 44;
        _tableView.rowHeight = 60;
        _tableView.tableHeaderView = self.headerView;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    }
    return _tableView;
}

- (TIoTIntelligentBottomActionView *)nextButtonView {
    if (!_nextButtonView) {
        _nextButtonView = [[TIoTIntelligentBottomActionView alloc]init];
        _nextButtonView.backgroundColor = [UIColor whiteColor];
        [_nextButtonView bottomViewType:IntelligentBottomViewTypeSingle withTitleArray:@[NSLocalizedString(@"next", @"下一步")]];
        __weak typeof(self)weakSelf = self;
        _nextButtonView.confirmBlock = ^{
            [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[weakSelf.productID?:@""]} success:^(id responseObject) {
                
                NSArray *data = responseObject[@"Data"];
                if (data.count > 0) {
                    NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
                    weakSelf.configData = [[NSDictionary alloc]initWithDictionary:config];
                    WCLog(@"AppGetProductsConfig config%@", config);
                    NSArray *wifiConfTypeList = config[@"WifiConfTypeList"];
                    if (wifiConfTypeList.count > 0) {
                        NSString *configType = wifiConfTypeList.firstObject;
                        if ([configType isEqualToString:@"softap"]) {
                            [weakSelf jumpConfigVC:NSLocalizedString(@"soft_ap", @"自助配网")];
                            return;
                        }
                    }
                }
                [weakSelf jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
                WCLog(@"AppGetProductsConfig responseObject%@", responseObject);
                
            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                [weakSelf jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
            }];
        };
    }
    return _nextButtonView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        _headerView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 16, kScreenWidth-32,    20)];
        [headerLabel setLabelFormateTitle:NSLocalizedString(@"please_choose_familyOfdevice", @"请选择添加设备的家庭") font:[UIFont wcPfMediumFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
        [_headerView addSubview:headerLabel];
    }
    return _headerView;
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
