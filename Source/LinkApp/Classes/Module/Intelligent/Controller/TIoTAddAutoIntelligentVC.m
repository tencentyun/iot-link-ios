//
//  TIoTAddAutoIntelligentVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAddAutoIntelligentVC.h"
#import "TIoTIntelligentBottomActionView.h"
#import "TIoTAutoIntelligentSectionTitleCell.h"
#import "TIoTAutoIntelligentConditionCell.h"
#import "TIoTIntelligentCustomCell.h"
#import "TIoTDeviceDetailTableViewCell.h"
#import "TIoTCustomSheetView.h"
#import "TIoTAutoIntelligentTimingVC.h"
#import "TIoTAutoEffectTimePriodView.h"

@interface TIoTAddAutoIntelligentVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) TIoTIntelligentBottomActionView * nextButtonView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *conditionArray;
@property (nonatomic, strong) NSMutableArray *actionArray;

@property (nonatomic, strong) TIoTCustomSheetView *customSheet;  //添加条件底部sheet
@property (nonatomic, strong) TIoTCustomSheetView *customActionSheet; //添加任务底部sheet
@end

@implementation TIoTAddAutoIntelligentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.title = NSLocalizedString(@"addAutoTask", @"添加自动智能");
    
    
    CGFloat kBottomViewHeight = 90;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
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


#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.conditionArray.count == 0) {
            return 2;
        }else {
            return 1 + self.conditionArray.count;
        }
    }else if (section == 1 ){
        if (self.actionArray.count == 0) {
            return 2;
        }else {
            return 1 + self.actionArray.count;
        }
    }else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            TIoTAutoIntelligentSectionTitleCell *cell = [TIoTAutoIntelligentSectionTitleCell cellWithTableView:tableView];
            cell.autoIntelligentItemType = AutoIntelligentItemTypeConditoin;
            if (self.conditionArray.count == 0) {
                cell.isHideAddConditionButton = YES;
                
            }else {
                cell.isHideAddConditionButton = NO;
                cell.autoInteAddConditionBlock = ^{
//MARK: 弹出添加条件sheet
                    [self addConditionEnter];
                };
            }
            cell.conditionTitleString = NSLocalizedString(@"autoIntelligent_meet_condition", @"满足以下所有条件");
            
            return cell;
            
        }else {
            TIoTIntelligentCustomCell *cell = [TIoTIntelligentCustomCell cellWithTableView:tableView];
            if (self.conditionArray.count > 0) {
                cell.isHideBlankAddView = YES;
            }else {
                cell.isHideBlankAddView = NO;
                cell.blankAddTipString = NSLocalizedString(@"autoIntelligeng_addCondition", @"添加条件");
            }
            return cell;
        }
        
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            TIoTAutoIntelligentSectionTitleCell *cell = [TIoTAutoIntelligentSectionTitleCell cellWithTableView:tableView];
            cell.autoIntelligentItemType = AutoIntelligentItemTypeAction;
            cell.conditionTitleString = NSLocalizedString(@"execute_Task", @"执行以下任务");
            if (self.actionArray.count == 0) {
                cell.isHideAddConditionButton = YES;
            }else {
                cell.isHideAddConditionButton = NO;
                cell.autoInteAddTaskBlock = ^{
#warning 弹出添加任务sheet
                    [self addActionEnter];
                };
            }
            cell.isHideChoiceConditionButton = YES;
            return cell;
        }else {
            TIoTIntelligentCustomCell *cell = [TIoTIntelligentCustomCell cellWithTableView:tableView];
            if (self.actionArray.count > 0) {
                cell.isHideBlankAddView = YES;
            }else {
                cell.isHideBlankAddView = NO;
                cell.blankAddTipString = NSLocalizedString(@"autoIntelligeng_task", @"添加任务");
            }
            return cell;
        }
    }else {
        TIoTDeviceDetailTableViewCell *cell = [TIoTDeviceDetailTableViewCell cellWithTableView:tableView];
        cell.isAddTimePriod = YES;
        cell.timePriodNumFont = [UIFont wcPfRegularFontOfSize:14];
        cell.dic = @{@"title":NSLocalizedString(@"auto_effective_time_period", @"生效时间段"),@"value":NSLocalizedString(@"auto_effect_allDay", @"全天"),@"needArrow":@"1"};
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.actionArray.count == 0) {
            if (indexPath.row == 1) {
                [self addConditionEnter];
            }
        }else {
#warning 进入对应条件编辑页面
        }
        
    }else if (indexPath.section == 1) {
        if (self.actionArray.count == 0) {
            if (indexPath.row == 1) {
                [self addActionEnter];
            }
        }else {
            
        }
        
    }else {
        
        __weak typeof(self)Weakself = self;
        
        //MARK:生效时间段view
        TIoTAutoEffectTimePriodView *timePeriodView = [[TIoTAutoEffectTimePriodView alloc]init];
        //生成有效时间段，显示在控制器中
        timePeriodView.generateTimePeriodBlock = ^(NSMutableDictionary * _Nonnull timePeriodDic) {
            TIoTDeviceDetailTableViewCell *cell = [Weakself.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            NSString *effectTimeStr = timePeriodDic[@"time"];
            if ([NSString isNullOrNilWithObject:effectTimeStr]) {
                effectTimeStr = NSLocalizedString(@"auto_effect_allDay", @"全天");
            }
            cell.dic = @{@"title":NSLocalizedString(@"auto_effective_time_period", @"生效时间段"),@"value":effectTimeStr,@"needArrow":@"1"};
            
        };
        [[UIApplication sharedApplication].delegate.window addSubview:timePeriodView];
        [timePeriodView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo([UIApplication sharedApplication].delegate.window);
        }];
    }
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat kFirstRowHeight = 38;
    CGFloat kRowHeight = 96;
    CGFloat kTimeSegmentHeight = 64;
    
    if (indexPath.section == 2) {
        return kTimeSegmentHeight;
    }else {
        if (indexPath.row == 0) {
            return kFirstRowHeight;
        }else {
            return kRowHeight;
        }
    }
}

- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark - event
/**
 添加条件
 */
- (void)addConditionEnter {
    self.customSheet = [[TIoTCustomSheetView alloc]init];
    [self.customSheet sheetViewTopTitleFirstTitle:NSLocalizedString(@"auto_deviceStatus_change", @"设备状态发生变化") secondTitle:NSLocalizedString(@"auto_timer", @"定时")];
    __weak typeof(self)weakSelf = self;
    
    self.customSheet.chooseIntelligentFirstBlock = ^{
#warning 跳转到设备列表，再点击设备的时候跳转到设置页面 注意选择设备时候，需要筛选;跳转定时页面，并移除当前sheet
        [weakSelf removeBottomCustomConditionSheetView];
        
    };
    self.customSheet.chooseIntelligentSecondBlock = ^{
        //MARK: 跳转定时页面，并移除当前sheet
        [weakSelf removeBottomCustomConditionSheetView];
        TIoTAutoIntelligentTimingVC *timingVC = [[TIoTAutoIntelligentTimingVC alloc]init];
        [weakSelf.navigationController pushViewController:timingVC animated:YES];
    };
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.customSheet];
    [self.customSheet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
    }];
}

//添加任务
- (void)addActionEnter {
    
    NSArray *actionTitleArray = @[NSLocalizedString(@"manualIntelligent_deviceControl", @"设备控制"),NSLocalizedString(@"manualIntelligent_delay", @"延时"),NSLocalizedString(@"manualIntalligent_choice", @"选择手动"),NSLocalizedString(@"post_notice", @"发送通知")];
    
    __weak typeof(self)weakSelf = self;
    
    //设备控制
    ChooseFunctionBlock deviceControlBlock = ^(TIoTCustomSheetView *view){
        [weakSelf removeBottomCustomActionSheetView];
    };
    //延时
    ChooseFunctionBlock delayBlock = ^(TIoTCustomSheetView *view){
        [weakSelf removeBottomCustomActionSheetView];
    };
    //选择手动
    ChooseFunctionBlock manualBlock = ^(TIoTCustomSheetView *view){
        [weakSelf removeBottomCustomActionSheetView];
    };
    //发送通知
    ChooseFunctionBlock noticeBlock = ^(TIoTCustomSheetView *view){
        [weakSelf removeBottomCustomActionSheetView];
    };
    //取消按钮
    ChooseFunctionBlock cancelBlock = ^(TIoTCustomSheetView *view){
        [view removeFromSuperview];
    };
    
    NSArray *actionBlockArray = @[deviceControlBlock,delayBlock,manualBlock,noticeBlock,cancelBlock];
    
    self.customActionSheet = [[TIoTCustomSheetView alloc]init];
    [self.customActionSheet sheetViewTopTitleArray:actionTitleArray withMatchBlocks:actionBlockArray];
    [[UIApplication sharedApplication].delegate.window addSubview:self.customActionSheet];
    [self.customActionSheet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
    }];
    
}

/**
 移除当前添加条件sheet
 */
- (void)removeBottomCustomConditionSheetView {
    if (self.customSheet) {
        [self.customSheet removeFromSuperview];
    }
}

/**
 移除当前添加任务sheet
 */
- (void)removeBottomCustomActionSheetView {
    if (self.customActionSheet) {
        [self.customActionSheet removeFromSuperview];
    }
}

#pragma mark - lazy loading

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionFooterHeight = 0.1;
        _tableView.sectionHeaderHeight = 0.1;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    }
    return _tableView;
}

#pragma mark - lazy loading
- (NSMutableArray *)conditionArray {
    if (!_conditionArray) {
        _conditionArray = [NSMutableArray array];
    }
    return _conditionArray;
}

- (NSMutableArray *)actionArray {
    if (!_actionArray) {
        _actionArray = [NSMutableArray array];
    }
    return _actionArray;
}

- (TIoTIntelligentBottomActionView *)nextButtonView {
    if (!_nextButtonView) {
        _nextButtonView = [[TIoTIntelligentBottomActionView alloc]init];
        _nextButtonView.backgroundColor = [UIColor whiteColor];
        [_nextButtonView bottomViewType:IntelligentBottomViewTypeSingle withTitleArray:@[NSLocalizedString(@"next", @"下一步")]];
        __weak typeof(self)weakSelf = self;
        _nextButtonView.confirmBlock = ^{
#warning 跳转前需要先移除弹框
            if (weakSelf.customSheet) {
                [weakSelf.customSheet removeFromSuperview];
            }
        };
    }
    return _nextButtonView;
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
