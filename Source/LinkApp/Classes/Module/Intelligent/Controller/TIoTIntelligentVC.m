//
//  TIoTIntelligentVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentVC.h"
#import "TIoTAddManualIntelligentVC.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTCustomSheetView.h"
#import "TIoTIntelligentSceneCell.h"
#import "TIoTAppEnvironment.h"
#import "TIoTAddAutoIntelligentVC.h"

@interface TIoTIntelligentVC ()<UITableViewDelegate,UITableViewDataSource,TIoTIntelligentSceneCellDelegate>
@property  (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *noIntelligentTipLabel;
@property (nonatomic, strong) UIButton *addIntelligentButton;
@property (nonatomic, strong) UIView *navCustomTopView;
@property (nonatomic, strong) TIoTCustomSheetView *customSheet;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *deviceNumberArray;
@property (nonatomic, strong) NSMutableArray *autoSceneArray;
@property (nonatomic, strong) UIView *customSectionHeaderView;

@property (nonatomic, strong) NSDictionary *sceneParamDic;
@property (nonatomic, strong) NSArray *sectionTitleArray;
@end

@implementation TIoTIntelligentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navCustomTopView.hidden = NO;
    
    [self loadSceneList];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navCustomTopView.hidden = YES;
    if (self.customSheet) {
        [self.customSheet removeFromSuperview];
    }
    
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    self.navigationController.tabBarController.tabBar.hidden = YES;
}

- (void)setupUI {
    
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self addEmptyIntelligentDeviceTipView];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale);
        }
    }];
    
//    [[UIApplication sharedApplication].delegate.window addSubview:self.navCustomTopView];
  
} 

- (void)loadSceneList {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    NSDictionary *dic = @{@"FamilyId":[TIoTCoreUserManage shared].familyId,@"Offset":@(0),@"Limit":@(999)};
    self.sceneParamDic = [NSDictionary dictionaryWithDictionary:dic];
    
    [[TIoTRequestObject shared] post:AppGetSceneList Param:dic success:^(id responseObject) {
        
        self.dataArray = [NSMutableArray arrayWithArray:responseObject[@"SceneList"]?:@[]];
        [self.deviceNumberArray removeAllObjects];
        
        for (int i = 0; i <self.dataArray.count ; i++) {
            NSDictionary *sceneDic = self.dataArray[i];
            NSMutableSet *sceneActions = [[NSMutableSet alloc]init];
            NSArray *actionsArray = sceneDic[@"Actions"]?:@[];
            for (int j = 0; j < actionsArray.count; j++) {
                NSDictionary *actionDic = actionsArray[j];
                if (![NSString isNullOrNilWithObject:actionDic[@"DeviceName"]] && ![NSString isNullOrNilWithObject:actionDic[@"ProductId"]]) {
                    NSString *uniqueID = [NSString stringWithFormat:@"%@%@",actionDic[@"DeviceName"],actionDic[@"ProductId"]];
                    [sceneActions addObject:uniqueID];
                }
                    
            }
            
            [self.deviceNumberArray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)sceneActions.count]];
        }
        
        [self.tableView reloadData];
        
        [[TIoTRequestObject shared] post:AppGetAutomationList Param:dic success:^(id responseObject) {
            
            self.autoSceneArray = [NSMutableArray arrayWithArray:responseObject[@"List"]?:@[]];
            
            [self.tableView reloadData];
            
            if (self.dataArray.count == 0 && self.autoSceneArray.count == 0) {
                self.tableView.hidden = YES;
            }
            
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            
        }];
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
    
}

- (void)addEmptyIntelligentDeviceTipView {
    [self.view addSubview:self.emptyImageView];
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            CGFloat kHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top+10;
            make.centerY.equalTo(self.view.mas_centerY).offset(-kHeight);
        } else {
            // Fallback on earlier versions
        }
        make.left.equalTo(self.view).offset(60);
        make.right.equalTo(self.view).offset(-60);
        make.height.mas_equalTo(160);
    }];
    
    [self.view addSubview:self.noIntelligentTipLabel];
    [self.noIntelligentTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emptyImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    [self.view addSubview:self.addIntelligentButton];
    [self.addIntelligentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noIntelligentTipLabel.mas_bottom).offset(20);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(36);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDelegate And TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.dataArray.count;
    }else {
        return self.autoSceneArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TIoTIntelligentSceneCell *sceneCell = [TIoTIntelligentSceneCell cellWithTableView:tableView];
        sceneCell.dic = self.dataArray[indexPath.row];
        sceneCell.delegate = self;
        sceneCell.deviceNum = self.deviceNumberArray[indexPath.row];
        sceneCell.sceneType = IntelligentSceneTypeManual;
        return sceneCell;
    }else {
        TIoTIntelligentSceneCell *sceneCell = [TIoTIntelligentSceneCell cellWithTableView:tableView];
        sceneCell.dic = self.autoSceneArray[indexPath.row];
        sceneCell.deviceNum = @"";
        sceneCell.delegate = self;
        sceneCell.sceneType = IntelligentSceneTypeAuto;
        return sceneCell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //MARK:跳转手动详情
        TIoTAddManualIntelligentVC *addManualTask = [[TIoTAddManualIntelligentVC alloc]init];
        addManualTask.isSceneDetail = YES;
        addManualTask.sceneManualDic = self.dataArray[indexPath.row];
        self.navigationController.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:addManualTask animated:YES];
    }else if (indexPath.section == 1) {
        //MARK:跳转自动详情
        TIoTAddAutoIntelligentVC *addAutoTask = [[TIoTAddAutoIntelligentVC alloc]init];
        addAutoTask.paramDic = self.sceneParamDic;
        addAutoTask.isSceneDetail = YES;
        addAutoTask.autoSceneInfoDic = self.autoSceneArray[indexPath.row];
        self.navigationController.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:addAutoTask animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerSectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    headerSectionView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    UILabel *sectionTitle = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, kScreenWidth, 50)];
    [sectionTitle setLabelFormateTitle:self.sectionTitleArray[section] font:[UIFont wcPfMediumFontOfSize:14] titleColorHexString:@"#6C7078" textAlignment:NSTextAlignmentLeft];
    [headerSectionView addSubview:sectionTitle];

    return headerSectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
        //只要实现这个方法，就实现了默认滑动删
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            // 删除数据
            [self deleteSelectIndexPath:indexPath];
        }
}

- (void)deleteSelectIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        NSDictionary *manualSceneDic = self.dataArray[indexPath.row];
        NSString *sceneId = manualSceneDic[@"SceneId"]?:@"";
        [self requestDeleteManualScene:sceneId];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        
    }else {
        
        NSDictionary *autoSceneDic = self.autoSceneArray[indexPath.row];
        NSString *sceneID = autoSceneDic[@"AutomationId"]?:@"";
        [self requestDeleteAutoScene:sceneID];
        [self.autoSceneArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
    
}

#pragma mark - 删除/执行 场景方法
/**
 手动智能场景删除
 */
- (void)requestDeleteManualScene:(NSString *)sceneID {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    NSString *sceneIDString = sceneID?:@"";
    NSDictionary *paramDic = @{@"SceneId":sceneIDString};
    [[TIoTRequestObject shared] post:AppDeleteScene Param:paramDic success:^(id responseObject) {
        [MBProgressHUD dismissInView:self.view];
        [MBProgressHUD showMessage:NSLocalizedString(@"delete_success", @"删除成功") icon:@""];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}
/**
 自动智能场景删除
 */
- (void)requestDeleteAutoScene:(NSString *)sceneID {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    NSString *sceneIDString = sceneID?:@"";
    NSDictionary *paramDic = @{@"AutomationId":sceneIDString};
    [[TIoTRequestObject shared] post:AppDeleteAutomation Param:paramDic success:^(id responseObject) {
        [MBProgressHUD dismissInView:self.view];
        [MBProgressHUD showMessage:NSLocalizedString(@"delete_success", @"删除成功") icon:@""];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

/**
 手动智能场景执行
 */
- (void)requestRunManualScene:(NSString *)sceneID {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    NSString *sceneIDString = sceneID?:@"";
    NSDictionary *paramDic = @{@"SceneId":sceneIDString};
    [[TIoTRequestObject shared] post:AppRunScene Param:paramDic success:^(id responseObject) {
        [MBProgressHUD dismissInView:self.view];
        [MBProgressHUD showMessage:NSLocalizedString(@"execute_Manual_success", @"执行手动智能成功") icon:@""];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

/**
 自动智能场景执行
 */
- (void)requestModifyAutoScene:(NSString *)scnenID status:(NSInteger)statusNum tipString:(NSString *)tipString{
    NSString *sceneIDString = scnenID?:@"";
    NSInteger sceneStauts = statusNum;
    NSDictionary *paramDic = @{@"AutomationId":sceneIDString,@"Status":@(sceneStauts)};
    
    [[TIoTRequestObject shared] post:AppModifyAutomationStatus Param:paramDic success:^(id responseObject) {
        [MBProgressHUD dismissInView:self.view];
        [MBProgressHUD showMessage:tipString?:@"" icon:@""];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
    
}

#pragma mark - 场景cell代理
- (void)changeSwitchStatus:(UISwitch *)switchControl withAutoScendData:(NSDictionary *)autoSceneDic {
    
    NSString *sceneIDStr = autoSceneDic[@"AutomationId"]?:@"";
    NSNumber *sceneStatus = autoSceneDic[@"Status"];
    NSInteger statusNum = 0;
    if (sceneStatus.intValue) {
        statusNum = sceneStatus.intValue;
    }
    
    if ([switchControl isOn]) {
        [self requestModifyAutoScene:sceneIDStr status:statusNum tipString:NSLocalizedString(@"open_auto_success", @"开启自动智能成功")];
    }else {
        [self requestModifyAutoScene:sceneIDStr status:statusNum tipString:NSLocalizedString(@"close_auto_success", @"关闭自动智能成功")];
    }
}

- (void)runManualSceneWithSceneID:(NSString *)sceneID {
    
    [self requestRunManualScene:sceneID];
}

#pragma mark - event

- (void)addClick {
    self.customSheet = [[TIoTCustomSheetView alloc]init];
    [self.customSheet sheetViewTopTitleFirstTitle:NSLocalizedString(@"intelligent_manual", @"手动智能") secondTitle:NSLocalizedString(@"intelligent_auto", @"自动智能")];
    __weak typeof(self)weakSelf = self;
    self.customSheet.chooseIntelligentFirstBlock = ^{
        //MARK: 跳转手动智能
        TIoTAddManualIntelligentVC *addManualTask = [[TIoTAddManualIntelligentVC alloc]init];
        weakSelf.navigationController.tabBarController.tabBar.hidden = YES;
        [weakSelf.navigationController pushViewController:addManualTask animated:YES];
        
    };
    self.customSheet.chooseIntelligentSecondBlock = ^{
        //MARK: 跳转自动智能
        TIoTAddAutoIntelligentVC *addAutoTask = [[TIoTAddAutoIntelligentVC alloc]init];
        addAutoTask.paramDic = weakSelf.sceneParamDic;
        weakSelf.navigationController.tabBarController.tabBar.hidden = YES;
        [weakSelf.navigationController pushViewController:addAutoTask animated:YES];
    };
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.customSheet];
    [self.customSheet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([UIApplication sharedApplication].delegate.window);
        make.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
    }];
}

- (void)addIntelligentDevice {
    [self addClick];
}

#pragma mark - lazy loading
- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_placeHold"]];
    }
    return _emptyImageView;
}

- (UILabel *)noIntelligentTipLabel {
    if (!_noIntelligentTipLabel) {
        _noIntelligentTipLabel = [[UILabel alloc]init];
        _noIntelligentTipLabel.text = NSLocalizedString(@"intelligent_noDeviceTip", @"当前暂无智能，点击添加智能");
        _noIntelligentTipLabel.font = [UIFont wcPfRegularFontOfSize:14];
        _noIntelligentTipLabel.textColor= [UIColor colorWithHexString:@"#6C7078"];
        _noIntelligentTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noIntelligentTipLabel;
}

- (UIButton *)addIntelligentButton {
    if (!_addIntelligentButton) {
        _addIntelligentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addIntelligentButton.layer.borderWidth = 1;
        _addIntelligentButton.layer.borderColor = [UIColor colorWithHexString:@"#0066FF"].CGColor;
        _addIntelligentButton.layer.cornerRadius = 18;
        [_addIntelligentButton setTitle:NSLocalizedString(@"addDeveice_immediately", @"立即添加") forState:UIControlStateNormal];
        [_addIntelligentButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        _addIntelligentButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_addIntelligentButton addTarget:self action:@selector(addIntelligentDevice) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addIntelligentButton;
}

- (UIView *)navCustomTopView {
    if (!_navCustomTopView) {
        
        CGFloat kTopHeight = [TIoTUIProxy shareUIProxy].statusHeight;
        
        _navCustomTopView = [[UIView alloc]initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, [TIoTUIProxy shareUIProxy].navigationBarHeight - [TIoTUIProxy shareUIProxy].statusHeight)];
        
        UIButton *addActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addActionButton setImage:[UIImage imageNamed:@"addManual_Intelligent"] forState:UIControlStateNormal];
        [addActionButton addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
        [_navCustomTopView addSubview:addActionButton];
        [addActionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-15*kScreenAllWidthScale);
            make.centerY.equalTo(_navCustomTopView.mas_centerY);
            make.width.height.mas_equalTo(22);
        }];
        
        
        UILabel *titleLab = [[UILabel alloc] init];
        [titleLab setLabelFormateTitle:NSLocalizedString(@"home_intelligent", @"智能") font:[UIFont wcPfMediumFontOfSize:17] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
        [_navCustomTopView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.centerX.equalTo(_navCustomTopView);
            make.height.mas_equalTo(kTopHeight);
            make.top.equalTo(_navCustomTopView.mas_top);
        }];
        
        _navCustomTopView.backgroundColor = [UIColor whiteColor];
        
    }
    return  _navCustomTopView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 106;
        _tableView.allowsMultipleSelection = NO;
        _tableView.allowsSelectionDuringEditing = NO;
        _tableView.allowsMultipleSelectionDuringEditing = NO;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    }
    return _tableView;
}

- (NSMutableArray *)deviceNumberArray {
    if (!_deviceNumberArray) {
        _deviceNumberArray = [NSMutableArray array];
    }
    return _deviceNumberArray;
}

- (NSMutableArray *)autoSceneArray {
    if (!_autoSceneArray) {
        _autoSceneArray = [NSMutableArray array];
    }
    return _autoSceneArray;
}

- (NSArray *)sectionTitleArray {
    if (!_sectionTitleArray) {
        _sectionTitleArray = @[NSLocalizedString(@"manual_scene", @"手动"),NSLocalizedString(@"auto_scene", @"自动")];
    }
    return _sectionTitleArray;
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
