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
#import "TIoTIntelligentCustomCell.h"
#import "TIoTDeviceDetailTableViewCell.h"
#import "TIoTCustomSheetView.h"
#import "TIoTAutoIntelligentTimingVC.h"
#import "TIoTAutoEffectTimePriodView.h"
#import "TIoTAutoConditionsView.h"
#import "TIoTAutoAddManualIntelliListVC.h"
#import "TIoTAutoIntelligentModel.h" //model
#import "TIoTChooseIntelligentDeviceVC.h"
#import "TIoTAutoNoticeVC.h"
#import "TIoTComplementIntelligentVC.h"
#import "TIoTChooseDelayTimeVC.h"
#import "TIoTDeviceSettingVC.h"

@interface TIoTAddAutoIntelligentVC ()<UITableViewDelegate,UITableViewDataSource,TIoTChooseDelayTimeVCDelegate>
@property (nonatomic, strong) TIoTIntelligentBottomActionView * nextButtonView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *conditionArray;
@property (nonatomic, strong) NSMutableArray *actionArray;

@property (nonatomic, strong) TIoTCustomSheetView *customSheet;  //添加条件底部sheet
@property (nonatomic, strong) TIoTCustomSheetView *customActionSheet; //添加任务底部sheet

@property (nonatomic, assign) NSInteger selectedConditonNum;
@property (nonatomic, strong) NSString *effectDayIDString;  //重复周期对应天 ID
@property (nonatomic, strong) NSString *effectBeginTimeString; //有效时间段起始时间
@property (nonatomic, strong) NSString *effectEndTimeString; //有效时间段结束时间
@end

@implementation TIoTAddAutoIntelligentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    
    self.selectedConditonNum = 0;
    self.effectDayIDString = @"1111111";
    self.effectBeginTimeString = @"00:00";
    self.effectEndTimeString = @"23:59";
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
                cell.autoIntellModel = self.conditionArray[indexPath.row - 1];
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
                cell.autoIntellModel = self.actionArray[indexPath.row - 1];
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
        if (self.conditionArray.count == 0) {
            if (indexPath.row == 0) {
                //MARK:弹出选择条件的view
                TIoTAutoConditionsView *choiceConditionView = [[TIoTAutoConditionsView alloc]init];
                choiceConditionView.chooseConditionBlock = ^(NSString * _Nonnull conditionContent, NSInteger number) {
                    TIoTAutoIntelligentSectionTitleCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell.conditionTitleString = conditionContent?:NSLocalizedString(@"autoIntelligent_meet_condition", @"满足以下所有条件");
                    self.selectedConditonNum = number;
                };
                [self.view addSubview:choiceConditionView];
                [choiceConditionView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.bottom.equalTo(self.view);
                    make.top.equalTo(self.tableView.mas_top);
                }];
            }else if (indexPath.row == 1) {
                //MARK:弹出添加条件sheet
                [self addConditionEnter];
            }
        }else {
//MARK: 进入对应条件编辑页面(条件 type 0 设备状态、1 定时)
            TIoTAutoIntelligentModel *autoModel = self.conditionArray[indexPath.row - 1];
            if ([autoModel.type isEqualToString:@"0"]) {
                NSLog(@"00");
                
                TIoTDeviceSettingVC *editSettingVC = [[TIoTDeviceSettingVC alloc]init];
                
                [self.navigationController pushViewController:editSettingVC animated:YES];
                
            }else if ([autoModel.type isEqualToString:@"1"])  {
                NSLog(@"11");
                
                __weak typeof(self)weakSelf = self;
                TIoTAutoIntelligentTimingVC *timingVC = [[TIoTAutoIntelligentTimingVC alloc]init];
                timingVC.isEdit = YES;
                timingVC.editModel = autoModel;
                timingVC.autoIntelAddTimerBlock = ^(TIoTAutoIntelligentModel * _Nonnull timerModel) {
                    
                    [weakSelf.conditionArray replaceObjectAtIndex:indexPath.row - 1 withObject:timerModel];
                    [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    
                    NSLog(@"-----");
                };
                [self.navigationController pushViewController:timingVC animated:YES];
            }
            
        }
        
    }else if (indexPath.section == 1) {
        if (self.actionArray.count == 0) {
            if (indexPath.row == 1) {
                [self addActionEnter];
            }
        }else {
//MARK: 进入对应条件编辑页面(任务 type 2 设备控制，3 延时，4 选择手动，5 发送通知)
            TIoTAutoIntelligentModel *autoModel = self.actionArray[indexPath.row - 1];
            if ([autoModel.type isEqualToString:@"2"]) {
                NSLog(@"222");
            }else if ([autoModel.type isEqualToString:@"3"])  {
                
                TIoTChooseDelayTimeVC *delayTimeVC = [[TIoTChooseDelayTimeVC alloc]init];
                delayTimeVC.isEditing = YES;
                delayTimeVC.delegate = self;
                delayTimeVC.autoDelayDateString = autoModel.delayTimeFormat;
                delayTimeVC.autoEditedDelayIndex = indexPath.row - 1;
                [self.navigationController pushViewController:delayTimeVC animated:YES];
                
            }else if ([autoModel.type isEqualToString:@"4"]) {

                __weak typeof(self)weakSelf = self;
                TIoTAutoAddManualIntelliListVC *addManualIntellVC = [[TIoTAutoAddManualIntelliListVC alloc]init];
                addManualIntellVC.paramDic = weakSelf.paramDic;
                addManualIntellVC.isEdit = YES;
                addManualIntellVC.updateManualSceneBlock = ^(TIoTAutoIntelligentModel * _Nullable changedModel, NSInteger index) {
                    
                    [weakSelf.actionArray replaceObjectAtIndex:index withObject:changedModel];
                    [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

                };
                addManualIntellVC.editModel = autoModel;//在智能列表所选的
                addManualIntellVC.editIndex = indexPath.row - 1;  //在智能列表中的index;

                [self.navigationController pushViewController:addManualIntellVC animated:YES];
                
            }else if ([autoModel.type isEqualToString:@"5"]) {
                __weak typeof(self)weakSelf = self;
                TIoTAutoNoticeVC *noticeVC = [[TIoTAutoNoticeVC alloc]init];
                noticeVC.isEdit = YES;
                noticeVC.editModel = autoModel;
                noticeVC.deleteNoticeBlcok = ^(NSMutableArray<TIoTAutoIntelligentModel *> * _Nullable noticeArray) {
                    if (noticeArray.count == 0) {
                        [weakSelf.actionArray removeObjectAtIndex:indexPath.row - 1];
                        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                    }
                };
//                noticeVC.addNoticeBlock = ^(NSArray<TIoTAutoIntelligentModel *> *noticeArray) {
//                    for (TIoTAutoIntelligentModel *model in noticeArray) {
//                        [weakSelf.actionArray addObject:model];
//                    }
//                    [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
//                };
                [self.navigationController pushViewController:noticeVC animated:YES];
                
                
            }
        }
        
    }else {
        
        __weak typeof(self)Weakself = self;
        
        //MARK:生效时间段view
        TIoTAutoEffectTimePriodView *timePeriodView = [[TIoTAutoEffectTimePriodView alloc]init];
        //生成有效时间段，显示在控制器中
        timePeriodView.generateTimePeriodBlock = ^(NSMutableDictionary * _Nonnull timePeriodDic, NSString * _Nonnull dayIDString) {
            TIoTDeviceDetailTableViewCell *cell = [Weakself.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            NSString *effectTimeStr = timePeriodDic[@"time"]?:@"";
            if ([NSString isNullOrNilWithObject:effectTimeStr]) {
                effectTimeStr = NSLocalizedString(@"auto_effect_allDay", @"全天");
            }
            cell.dic = @{@"title":NSLocalizedString(@"auto_effective_time_period", @"生效时间段"),@"value":effectTimeStr,@"needArrow":@"1"};
            
            NSArray *timeArray = [effectTimeStr componentsSeparatedByString:@"-"];
            self.effectDayIDString = dayIDString;
            self.effectBeginTimeString = timeArray.firstObject?:@"";
            self.effectEndTimeString = timeArray.lastObject?:@"";
            
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

#pragma mark - 定时编辑完回调代理
//MARK:编辑完定时后，刷新任务列表
- (void)changeDelayTimeString:(NSString *)timeString hour:(NSString *)hourString minuteString:(NSString *)min withAutoDelayIndex:(NSInteger)autoDelayIndex{
    
    NSCharacterSet* hourCharacterSet =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    int hourNumber =[[hourString stringByTrimmingCharactersInSet:hourCharacterSet] intValue];
    
    NSCharacterSet* minutCharacterSet =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    int minutNumber =[[min stringByTrimmingCharactersInSet:minutCharacterSet] intValue];
    NSString *timeStr = [NSString stringWithFormat:@"%d",hourNumber*60*60 + minutNumber*60];
    
    NSMutableDictionary *delayTineDic = [NSMutableDictionary dictionary];
    [delayTineDic setValue:timeStr forKey:@"Data"];
    [delayTineDic setValue:@(1) forKey:@"ActionType"];
    [delayTineDic setValue:@"3" forKey:@"type"];
    [delayTineDic setValue:timeString forKey:@"delayTime"];
    [delayTineDic setValue:[NSString stringWithFormat:@"%d:%d",hourNumber,minutNumber] forKey:@"delayTimeFormat"];
    TIoTAutoIntelligentModel *model = [TIoTAutoIntelligentModel yy_modelWithJSON:delayTineDic];
    [self.actionArray replaceObjectAtIndex:autoDelayIndex withObject:model];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark - event

//MARK:添加设备状态条件（model数组）后，刷新list
- (void)refreshAutoIntelligentList:(BOOL)isAction {
    
    if (isAction == YES) {//任务
        if (self.autoDeviceStatusArray.count != 0) {
            for (TIoTAutoIntelligentModel *model in self.autoDeviceStatusArray) {
                [self.actionArray addObject:model];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else { //条件
        if (self.autoDeviceStatusArray.count != 0) {
            for (TIoTAutoIntelligentModel *model in self.autoDeviceStatusArray) {
                [self.conditionArray addObject:model];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    
    
}


//MARK: 添加条件入口
- (void)addConditionEnter {
    self.customSheet = [[TIoTCustomSheetView alloc]init];
    [self.customSheet sheetViewTopTitleFirstTitle:NSLocalizedString(@"auto_deviceStatus_change", @"设备状态发生变化") secondTitle:NSLocalizedString(@"auto_timer", @"定时")];
    __weak typeof(self)weakSelf = self;
    
    self.customSheet.chooseIntelligentFirstBlock = ^{
        //MARK:跳转到设备列表，再点击设备的时候跳转到设置页面 注意选择设备时候，需要筛选;跳转定时页面，并移除当前sheet
        TIoTChooseIntelligentDeviceVC *chooseDeviceVC = [[TIoTChooseIntelligentDeviceVC alloc]init];
        chooseDeviceVC.enterType = DeviceChoiceEnterTypeAuto;
        
        [weakSelf.navigationController pushViewController:chooseDeviceVC animated:YES];
        
        [weakSelf removeBottomCustomConditionSheetView];
        
    };
    self.customSheet.chooseIntelligentSecondBlock = ^{
        //MARK: 跳转定时页面，并移除当前sheet
        [weakSelf removeBottomCustomConditionSheetView];
        TIoTAutoIntelligentTimingVC *timingVC = [[TIoTAutoIntelligentTimingVC alloc]init];
        timingVC.autoIntelAddTimerBlock = ^(TIoTAutoIntelligentModel * _Nonnull timerModel) {
            [weakSelf.conditionArray addObject:timerModel];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        };
        [weakSelf.navigationController pushViewController:timingVC animated:YES];
    };
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.customSheet];
    [self.customSheet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
    }];
}


//MARK: 添加任务入口
- (void)addActionEnter {
    
    NSArray *actionTitleArray = @[NSLocalizedString(@"manualIntelligent_deviceControl", @"设备控制"),NSLocalizedString(@"manualIntelligent_delay", @"延时"),NSLocalizedString(@"manualIntalligent_choice", @"选择手动"),NSLocalizedString(@"post_notice", @"发送通知"),NSLocalizedString(@"cancel", @"取消")];
    
    __weak typeof(self)weakSelf = self;
    
    //设备控制
    ChooseFunctionBlock deviceControlBlock = ^(TIoTCustomSheetView *view){
        
        TIoTChooseIntelligentDeviceVC *chooseDeviceVC = [[TIoTChooseIntelligentDeviceVC alloc]init];
//        if (weakSelf.customSheet) {
//            [weakSelf.customSheet removeFromSuperview];
//
//        }
//        chooseDeviceVC.actionOriginArray = [weakSelf.dataArray mutableCopy];
//        if (weakSelf.valueArray == nil) {
//            weakSelf.valueArray = [NSMutableArray array];
//        }
//        chooseDeviceVC.valueOriginArray =  [weakSelf.valueArray mutableCopy];
        
        chooseDeviceVC.enterType = DeviceChoiceEnterTypeAuto;
        chooseDeviceVC.deviceAutoChoiceEnterActionType = YES;
        [weakSelf.navigationController pushViewController:chooseDeviceVC animated:YES];
        
        [weakSelf removeBottomCustomActionSheetView];
    };
    //延时
    ChooseFunctionBlock delayBlock = ^(TIoTCustomSheetView *view){
        TIoTChooseDelayTimeVC *delayTimeVC = [[TIoTChooseDelayTimeVC alloc]init];
        delayTimeVC.isEditing = NO;

        delayTimeVC.addDelayTimeBlcok = ^(NSString * _Nonnull timeString, NSString * _Nonnull hourStr, NSString * _Nonnull minu) {
            
            NSCharacterSet* hourCharacterSet =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            int hourNumber =[[hourStr stringByTrimmingCharactersInSet:hourCharacterSet] intValue];
            
            NSCharacterSet* minutCharacterSet =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            int minutNumber =[[minu stringByTrimmingCharactersInSet:minutCharacterSet] intValue];
            NSString *timeStr = [NSString stringWithFormat:@"%d",hourNumber*60*60 + minutNumber*60];
            
            NSMutableDictionary *delayTineDic = [NSMutableDictionary dictionary];
            [delayTineDic setValue:timeStr forKey:@"Data"];
            [delayTineDic setValue:@(1) forKey:@"ActionType"];
            [delayTineDic setValue:@"3" forKey:@"type"];
            [delayTineDic setValue:timeString forKey:@"delayTime"];
            [delayTineDic setValue:[NSString stringWithFormat:@"%d:%d",hourNumber,minutNumber] forKey:@"delayTimeFormat"];
            TIoTAutoIntelligentModel *model = [TIoTAutoIntelligentModel yy_modelWithJSON:delayTineDic];
            [weakSelf.actionArray addObject:model];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

        };
        
        [weakSelf.navigationController pushViewController:delayTimeVC animated:YES];
        [weakSelf removeBottomCustomActionSheetView];
    };
    //选择手动
    ChooseFunctionBlock manualBlock = ^(TIoTCustomSheetView *view){
        [weakSelf removeBottomCustomActionSheetView];
        
        TIoTAutoAddManualIntelliListVC *addManualIntellVC = [[TIoTAutoAddManualIntelliListVC alloc]init];
        addManualIntellVC.paramDic = weakSelf.paramDic;
        addManualIntellVC.addManualSceneBlock = ^(NSArray<TIoTAutoIntelligentModel *> *manualSceneArray) {
            
            for (TIoTAutoIntelligentModel *model in manualSceneArray) {
                [weakSelf.actionArray addObject:model];
            }
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        };
        [weakSelf.navigationController pushViewController:addManualIntellVC animated:YES];
    };
    //发送通知
    ChooseFunctionBlock noticeBlock = ^(TIoTCustomSheetView *view){
        TIoTAutoNoticeVC *noticeVC = [[TIoTAutoNoticeVC alloc]init];
        noticeVC.addNoticeBlock = ^(NSArray<TIoTAutoIntelligentModel *> *noticeArray) {
            for (TIoTAutoIntelligentModel *model in noticeArray) {
                [weakSelf.actionArray addObject:model];
            }
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        };
        [weakSelf.navigationController pushViewController:noticeVC animated:YES];
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


//MARK: 移除当前添加条件sheet

- (void)removeBottomCustomConditionSheetView {
    if (self.customSheet) {
        [self.customSheet removeFromSuperview];
    }
}

//MARK: 移除当前添加任务sheet
 
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
            
            if (self.conditionArray.count == 0 || self.actionArray.count == 0) {
                [MBProgressHUD showMessage:NSLocalizedString(@"error_add_condition_action", @"请添加任务和条件") icon:@""];
            }else {
                //MARK:组装好条件、任务、生效时间段 的请求参数 model，跳转到完善页面，添加场景背景URL和名称
                
                NSMutableDictionary *autoDic = [NSMutableDictionary new];
                [autoDic setValue:@(1) forKey:@"Status"];
                [autoDic setValue:@(weakSelf.selectedConditonNum) forKey:@"MatchType"];
                [autoDic setValue:[weakSelf.conditionArray yy_modelToJSONObject] forKey:@"Conditions"];
                [autoDic setValue:[weakSelf.actionArray yy_modelToJSONObject] forKey:@"Actions"];
                [autoDic setValue:weakSelf.paramDic[@"FamilyId"] forKey:@"FamilyId"];
                
                [autoDic setValue:weakSelf.effectDayIDString?:@"" forKey:@"EffectiveDays"];
                [autoDic setValue:weakSelf.effectBeginTimeString?:@"" forKey:@"EffectiveBeginTime"];
                [autoDic setValue:weakSelf.effectEndTimeString?:@"" forKey:@"EffectiveEndTime"];
                
                TIoTComplementIntelligentVC *complementVC = [[TIoTComplementIntelligentVC alloc]init];
                complementVC.autoParamDic = autoDic;
                complementVC.isAuto = YES;
                [weakSelf.navigationController pushViewController:complementVC animated:YES];
                if (weakSelf.customSheet) {
                    [weakSelf.customSheet removeFromSuperview];
                }
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
