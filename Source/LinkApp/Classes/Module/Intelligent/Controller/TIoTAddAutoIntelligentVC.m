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

#import "TIoTSettingIntelligentCell.h"
#import "TIoTSettingIntelligentImageVC.h"
#import "TIoTSettingIntelligentNameVC.h"

static NSInteger  const limit = 10;

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

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITableView *complementTableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSString *sceneImageUrl;
@property (nonatomic, strong) NSString  *sceneNameString;

@property (nonatomic, strong) NSDictionary *sceneDataDic;

@property (nonatomic, strong) NSMutableArray *allDeviceArray; //查询所有设备的数组
@property (nonatomic, assign) NSInteger offset; //逐步累积 每次返回设备的个数
@property (nonatomic, assign) NSInteger totalNumber;//设备总个数

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
    
    if (self.isSceneDetail == YES) {
            [self loadAutoSceneDetailData];
        }
}

- (void)loadAutoSceneDetailData {
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    NSDictionary *dic = @{@"AutomationId":self.autoSceneInfoDic[@"AutomationId"]?:@""};
    
    [[TIoTRequestObject shared] post:AppDescribeAutomation Param:dic success:^(id responseObject) {
        self.sceneDataDic = [[NSDictionary alloc]initWithDictionary:responseObject[@"Data"]?:@{}];
        self.sceneImageUrl = self.sceneDataDic[@"Icon"]?:@"";
        self.sceneNameString = self.sceneDataDic[@"Name"]?:@"";
        NSNumber *matchNumber = self.sceneDataDic[@"MatchType"];
        self.selectedConditonNum = matchNumber.intValue?:0;
        
        self.effectDayIDString = self.sceneDataDic[@"EffectiveDays"];
        self.effectBeginTimeString = self.sceneDataDic[@"EffectiveBeginTime"];
        self.effectEndTimeString = self.sceneDataDic[@"EffectiveEndTime"];
        
        [self.conditionArray removeAllObjects];
        [self.actionArray removeAllObjects];
        
        //获取用户所有设备，用于筛选哪些设备被删除
        self.offset = 0;
        [self.allDeviceArray removeAllObjects];
        
        //获取所有添加列表
        [[TIoTRequestObject shared] post:AppGetFamilyDeviceList Param:@{@"FamilyId":[TIoTCoreUserManage shared].familyId,@"RoomId":@"",@"Offset":@(0),@"Limit":@(1000)} success:^(id responseObject) {
            NSArray *devicePageList = [NSArray arrayWithArray:responseObject[@"DeviceList"]];
            self.offset += devicePageList.count;
            [self.allDeviceArray addObjectsFromArray:devicePageList];
           
            NSMutableArray *condTempArray = [NSMutableArray arrayWithArray:self.sceneDataDic[@"Conditions"]?:@[]]; //condition 操作数组
            NSMutableArray *actiTempArray = [NSMutableArray arrayWithArray:self.sceneDataDic[@"Actions"]?:@[]];  //action 操作数组
            
            NSArray *condArray = [NSArray arrayWithArray:self.sceneDataDic[@"Conditions"]?:@[]]; //保存原始condition 数组
            NSArray *actiArray = [NSArray arrayWithArray:self.sceneDataDic[@"Actions"]?:@[]]; //保存原始action 数组
            
            NSMutableArray *deviceProductIDArray = [NSMutableArray array]; //保存设备列表中所有productid
            
            for (int i = 0; i<self.allDeviceArray.count; i++) {
                NSDictionary *dic = self.allDeviceArray[i];
                [deviceProductIDArray addObject:dic[@"ProductId"]];
            }
            
            //去除condition 中删除的设备
            for (int j = 0; j<condArray.count; j++) {
                NSDictionary *condDic = condArray[j];
                if ([condDic[@"CondType"] intValue] == 0) {
                    if (![deviceProductIDArray containsObject:condDic[@"ProductId"]]) {
                        [condTempArray removeObject:condDic];
                    }
                }

            }
            
            //去除action 中删除的设备
            for (int k = 0; k<actiArray.count; k++) {
                NSDictionary *actiDic = actiArray[k];
                if ([actiDic[@"ActionType"] intValue] == 0) {
                    if (![deviceProductIDArray containsObject:actiDic[@"ProductId"]]) {
                        [actiTempArray removeObject:actiDic];
                    }
                }
            }
            
    //MARK:条件
    //        NSArray *conditionTempArray = self.sceneDataDic[@"Conditions"]?:@[];
            NSArray *conditionTempArray = [condTempArray copy];
            for (int j = 0;j<conditionTempArray.count;j++) {
                
                NSDictionary *dic = [NSDictionary dictionaryWithDictionary:conditionTempArray[j]];
                TIoTAutoIntelligentModel *model = [TIoTAutoIntelligentModel yy_modelWithJSON:dic];

                model.type = [NSString stringWithFormat:@"%ld",(long)model.CondType];

                NSString *productIDString = model.Property.ProductId?:@"";

                if (model.CondType == 0) {
                    //MARK:设备状态
                    
                    [[TIoTRequestObject shared] post:AppGetProducts Param:@{@"ProductIds":@[productIDString]} success:^(id responseObject) {
                        
                        NSArray *tmpArr = responseObject[@"Products"];
                        if (tmpArr.count > 0) {
                            NSString *DataTemplate = tmpArr.firstObject[@"DataTemplate"];
                //            NSDictionary *DataTemplateDic = [NSString jsonToObject:DataTemplate];
                            TIoTDataTemplateModel *product = [TIoTDataTemplateModel yy_modelWithJSON:DataTemplate];
                //            TIoTProductConfigModel *configModel = [TIoTProductConfigModel yy_modelWithJSON:config];
                            NSLog(@"--!!!-%@",product);
                            
                            for (int i = 0; i <product.properties.count; i++) {
                                TIoTPropertiesModel *propertieModel = product.properties[i];
                                if ([propertieModel.id isEqualToString:model.Property.PropertyId]) {
                                    
                                    NSString *valueString = @"";
                                    if ([propertieModel.define.type isEqualToString:@"enum"] || [propertieModel.define.type isEqualToString:@"bool"]) {
                                        NSString *keyString = [NSString stringWithFormat:@"%d",model.Property.Value.intValue];
                                        valueString = [propertieModel.define.mapping objectForKey:keyString];
                                    }else if ([propertieModel.define.type isEqualToString:@"int"] || [propertieModel.define.type isEqualToString:@"float"]){
                                        
                                        if ([propertieModel.define.type isEqualToString:@"int"]) {
                                            valueString = [NSString stringWithFormat:@"%d%@",model.Property.Value.intValue,propertieModel.define.unit];
                                        }else if ([propertieModel.define.type isEqualToString:@"float"]) {
                                            valueString = [NSString stringWithFormat:@"%.1f%@",model.Property.Value.floatValue,propertieModel.define.unit];
                                        }
                                         
                                    }
                                    
                                    model.Property.conditionTitle = propertieModel.name;
                                    model.Property.conditionContentString = valueString;
                                    model.propertyModel = propertieModel;
                                
                                    [self.conditionArray addObject:model];
                                    [self.complementTableView reloadData];
                                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                                }
                                
                            }
                        }
                    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

                    }];
                    
                }else if ([model.type isEqualToString:@"1"]){
                    //MARK:定时
                    if ([model.Timer.Days isEqualToString:@"0000000"]) {
                        model.Timer.timerKindSring = NSLocalizedString(@"auto_repeatTiming_once", @"执行一次");
                        model.Timer.choiceRepeatTimeNumner = 0;
                    }else if ([model.Timer.Days isEqualToString:@"1111111"]) {
                        model.Timer.timerKindSring = NSLocalizedString(@"everyday", @"每天");
                        model.Timer.choiceRepeatTimeNumner = 1;
                    }else if ([model.Timer.Days isEqualToString:@"0111110"]) {
                        model.Timer.timerKindSring = NSLocalizedString(@"work_day", @"工作日");
                        model.Timer.choiceRepeatTimeNumner = 2;
                    }else if ([model.Timer.Days isEqualToString:@"1000001"]) {
                        model.Timer.timerKindSring = NSLocalizedString(@"weekend", @"周末");
                        model.Timer.choiceRepeatTimeNumner = 3;
                    }else {
                        model.Timer.timerKindSring = NSLocalizedString(@"auto_repeatTiming_custom", @"自定义");
                        model.Timer.choiceRepeatTimeNumner = 4;
                    }
                         
                    [self.conditionArray addObject:model];
                }
            }
            
    //MARK:任务
    //        NSArray *actionTempArray = self.sceneDataDic[@"Actions"]?:@[];
            NSArray *actionTempArray = [actiTempArray copy];
            for (NSDictionary *dic in actionTempArray) {
                TIoTAutoIntelligentModel *model = [TIoTAutoIntelligentModel yy_modelWithJSON:dic];
                model.type = [NSString stringWithFormat:@"%ld",model.ActionType+2];
                NSString *productIDString = model.ProductId?:@"";
                
                NSString * dataString= model.Data;
                NSDictionary *dataDic = [NSString jsonToObject:dataString];
                NSString *keyString = dataDic.allKeys[0]; //只有一个键值对
                NSNumber *number = dataDic[keyString];
                if (model.ActionType == 0) {
                    //MARK:设备动作
                    [[TIoTRequestObject shared] post:AppGetProducts Param:@{@"ProductIds":@[productIDString]} success:^(id responseObject) {
                        
                        NSArray *tmpArr = responseObject[@"Products"];
                        if (tmpArr.count > 0) {
                            NSString *DataTemplate = tmpArr.firstObject[@"DataTemplate"];
                //            NSDictionary *DataTemplateDic = [NSString jsonToObject:DataTemplate];
                            TIoTDataTemplateModel *product = [TIoTDataTemplateModel yy_modelWithJSON:DataTemplate];
                //            TIoTProductConfigModel *configModel = [TIoTProductConfigModel yy_modelWithJSON:config];
                            NSLog(@"--!!!-%@",product);
                            
                            for (int i = 0; i <product.properties.count; i++) {
                                TIoTPropertiesModel *propertieModel = product.properties[i];
                                if ([propertieModel.id isEqualToString:keyString]) {
                                    
                                    
                                    NSString *valueString = @"";
                                    if ([propertieModel.define.type isEqualToString:@"enum"] || [propertieModel.define.type isEqualToString:@"bool"]) {
                                        
                                        NSString *keyString = [NSString stringWithFormat:@"%d",number.intValue];
                                        valueString = [propertieModel.define.mapping objectForKey:keyString];
                                    }else if ([propertieModel.define.type isEqualToString:@"int"] || [propertieModel.define.type isEqualToString:@"float"]){
                                        
                                        if ([propertieModel.define.type isEqualToString:@"int"]) {
                                            valueString = [NSString stringWithFormat:@"%d%@",number.intValue,propertieModel.define.unit];
                                        }else if ([propertieModel.define.type isEqualToString:@"float"]) {
                                            valueString = [NSString stringWithFormat:@"%.1f%@",number.floatValue,propertieModel.define.unit];
                                        }
                                         
                                    }
                                    
                                    model.propertName = propertieModel.name;
                                    model.dataValueString = valueString;
                                    model.propertyModel = propertieModel;
                                
                                    [self.actionArray addObject:model];
                                    
                                    [self.complementTableView reloadData];
                                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                                }
                                
                            }
                        }
                    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

                    }];
                    
                    
                }else if (model.ActionType == 1) {
                    //MARK:延时
                    //时间data为整数
                    
                    NSInteger hourNum = model.Data.intValue / (60*60);
                    NSInteger minutNum = (model.Data.intValue % (60*60))/60;
                    
                    NSString *timestr = @"";
                    if (hourNum == 0) {
                        timestr = [NSString stringWithFormat:@"%ld%@%@",(long)minutNum,NSLocalizedString(@"unit_m", @"分钟"),NSLocalizedString(@"delay_time_later", @"后")];
                    }
                    if (minutNum == 0) {
                        timestr = [NSString stringWithFormat:@"%ld%@%@",(long)hourNum,NSLocalizedString(@"unit_h", @"小时"),NSLocalizedString(@"delay_time_later", @"后")];
                    }
                    
                    NSString *timeFormatStr = @"";
                    if (hourNum<10) {
                        if (minutNum<10) {
                            timeFormatStr = [NSString stringWithFormat:@"0%ld:0%ld",(long)hourNum,(long)minutNum];
                        }else {
                            timeFormatStr = [NSString stringWithFormat:@"0%ld:%ld",(long)hourNum,(long)minutNum];
                        }
                    }else {
                        if (minutNum<10) {
                            timeFormatStr = [NSString stringWithFormat:@"%ld:0%ld",(long)hourNum,(long)minutNum];
                        }else {
                            timeFormatStr = [NSString stringWithFormat:@"%ld:%ld",(long)hourNum,(long)minutNum];
                        }
                    }
                    
                    model.delayTime = timestr ;   //本地添加 延时时间 加汉字
                    model.delayTimeFormat = timeFormatStr; //本地添加 延时时间 00:00
                    
                    [self.actionArray addObject:model];
                }else if (model.ActionType == 2) {
                    //MARK:场景
                    model.sceneName = model.DeviceName; //本地添加 场景名称
                    [self.actionArray addObject:model];
                }else if (model.ActionType == 3) {
                    //MARK:通知
                    NSNumber *number = self.sceneDataDic[@"Status"];
                    model.isSwitchTuron = number.intValue; //本地添加 通知开关 1 开 0 关
                    [self.actionArray addObject:model];
                }
                
            }
            
            [self.dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"setting_Intelligent_Image", @"智能图片"),@"value":NSLocalizedString(@"unset", @"未设置"),@"image":self.sceneImageUrl,@"needArrow":@"1"}]];
            [self.dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"setting_Intelligent_Name", @"智能名称"),@"value":self.sceneNameString,@"needArrow":@"1"}]];
            
            [self.complementTableView reloadData];
            [self.tableView reloadData];
            
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            
        }];
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

//MARK:设置UI
- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    if (self.isSceneDetail == YES) {
            self.title = NSLocalizedString(@"intelligent_auto", @"自动智能");
        }else {
            self.title = NSLocalizedString(@"addAutoTask", @"添加自动智能");
        }
        
        CGFloat KItemHeight = 48;
        
        CGFloat kTopSpace = 15; //tableview 距离导航栏高度
        [self.view addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(KItemHeight *2);
            if (@available (iOS 11.0, *)) {
                if (self.isSceneDetail == YES) {
                    make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kTopSpace);
                }else {
                    make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                }
            }else {
                make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale + kTopSpace);
            }
        }];
        
        [self.topView addSubview:self.complementTableView];
        [self.complementTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.topView);
        }];
    
    
    CGFloat kBottomViewHeight = 90;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (self.isSceneDetail == YES) {
            make.top.equalTo(self.topView.mas_bottom);
        }else {
            self.topView.hidden = YES;
            if (@available (iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kTopSpace);
            }else {
                make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale + kTopSpace);
            }
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
    if (tableView == self.tableView) {
           return 3;
       }else {
           return 1;
       }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView) {
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
    }else {
        return self.dataArr.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
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
                    __weak typeof(self)Weakself = self;
                    cell.deleteIntelligentItemBlock = ^{
                        [Weakself.conditionArray removeObjectAtIndex:indexPath.row - 1];
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                        if (Weakself.conditionArray.count == 0) {
//                            Weakself.tableView.hidden = YES;
//                            Weakself.nextButtonView.hidden = YES;
                        }
                    };
                    
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
                    __weak typeof(self)Weakself = self;
                    cell.deleteIntelligentItemBlock = ^{
                        [Weakself.actionArray removeObjectAtIndex:indexPath.row - 1];
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                        if (Weakself.conditionArray.count == 0) {
//                            Weakself.tableView.hidden = YES;
//                            Weakself.nextButtonView.hidden = YES;
                        }
                    };
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
            NSString *timeText = [NSString stringWithFormat:@"（%@-%@）",self.effectBeginTimeString,self.effectEndTimeString];
            if ([self.effectBeginTimeString isEqualToString:@"00:00"]&&[self.effectEndTimeString isEqualToString:@"23:59"]) {
                timeText = NSLocalizedString(@"auto_effect_allDay", @"全天");
            }
            cell.dic = @{@"title":NSLocalizedString(@"auto_effective_time_period", @"生效时间段"),@"value": timeText,@"needArrow":@"1"};
            return cell;
        }
    }else {
        //MARK:顶部场景图片和名称
        TIoTSettingIntelligentCell *cell = [TIoTSettingIntelligentCell cellWithTableView:tableView];
        cell.dic = [self dataArr][indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
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
                if (indexPath.row == 0) {
                    [self addConditionEnter];
                }else {
                    TIoTAutoIntelligentModel *autoModel = self.conditionArray[indexPath.row - 1];
                    if ([autoModel.type isEqualToString:@"0"]) {
                        NSLog(@"00");
                        
                        TIoTDeviceSettingVC *editSettingVC = [[TIoTDeviceSettingVC alloc]init];
                        editSettingVC.isEdited = YES;
                        editSettingVC.isAutoActionType = NO;
                        editSettingVC.enterType = IntelligentEnterTypeAuto;
                        editSettingVC.editedModel = autoModel.propertyModel;
                        editSettingVC.editActionIndex = indexPath.row - 1;
                        editSettingVC.valueString = autoModel.Property.conditionContentString?:@"";
                        editSettingVC.model = autoModel;
                        [self.navigationController pushViewController:editSettingVC animated:YES];
                        
                    }else if ([autoModel.type isEqualToString:@"1"])  {
                        
                        __weak typeof(self)weakSelf = self;
                        TIoTAutoIntelligentTimingVC *timingVC = [[TIoTAutoIntelligentTimingVC alloc]init];
                        timingVC.isEdit = YES;
                        timingVC.editModel = autoModel;
                        timingVC.autoIntelAddTimerBlock = ^(TIoTAutoIntelligentModel * _Nonnull timerModel) {
                            
                            [weakSelf.conditionArray replaceObjectAtIndex:indexPath.row - 1 withObject:timerModel];
                            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                            
                        };
                        [self.navigationController pushViewController:timingVC animated:YES];
                    }
                }
                
                
            }
            
        }else if (indexPath.section == 1) {
            if (self.actionArray.count == 0) {
                if (indexPath.row == 1) {
                    [self addActionEnter];
                }
            }else {
    //MARK: 进入对应条件编辑页面(任务 type 2 设备控制，3 延时，4 选择手动，5 发送通知)
                if (indexPath.row == 0) {
                    [self addActionEnter];
                }else {
                    TIoTAutoIntelligentModel *autoModel = self.actionArray[indexPath.row - 1];
                    if ([autoModel.type isEqualToString:@"2"]) {
                        NSLog(@"222");
                        
                        TIoTDeviceSettingVC *editSettingVC = [[TIoTDeviceSettingVC alloc]init];
                        editSettingVC.isEdited = YES;
                        editSettingVC.isAutoActionType = YES;
                        editSettingVC.enterType = IntelligentEnterTypeAuto;
                        editSettingVC.editedModel = autoModel.propertyModel;
                        editSettingVC.editActionIndex = indexPath.row - 1;
                        editSettingVC.valueString = autoModel.dataValueString?:@"";
                        editSettingVC.model = autoModel;
                        [self.navigationController pushViewController:editSettingVC animated:YES];
                        
                    }else if ([autoModel.type isEqualToString:@"3"])  {
                        NSLog(@"33");
                        
                        TIoTChooseDelayTimeVC *delayTimeVC = [[TIoTChooseDelayTimeVC alloc]init];
                        delayTimeVC.isEditing = YES;
                        delayTimeVC.delegate = self;
                        delayTimeVC.autoDelayDateString = autoModel.delayTimeFormat;
                        delayTimeVC.autoEditedDelayIndex = indexPath.row - 1;
                        [self.navigationController pushViewController:delayTimeVC animated:YES];
                        
                    }else if ([autoModel.type isEqualToString:@"4"]) {
                        NSLog(@"44");
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
                        NSLog(@"55");
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
                        [self.navigationController pushViewController:noticeVC animated:YES];
                    }
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
            
            NSInteger indexRepeatNum = 0;
            if ([self.effectDayIDString isEqualToString:@"1000001"]) {
                indexRepeatNum = 2; //周末
                
            }else if ([self.effectDayIDString isEqualToString:@"1111111"]) {
                indexRepeatNum = 0;//每天
               
            }else if ([self.effectDayIDString isEqualToString:@"0111110"]) {
                indexRepeatNum = 1;//工作日
                
            }else {
                indexRepeatNum = 3;
                //自定义
            }
            NSString *timeStr = [NSString stringWithFormat:@"%@-%@",self.effectBeginTimeString,self.effectEndTimeString];
            NSString *repeatTypeStr = [NSString stringWithFormat:@"%ld",(long)indexRepeatNum];
            timePeriodView.defaultRepeatTimeNum = indexRepeatNum;
            timePeriodView.effectTimeDic = [NSMutableDictionary dictionaryWithDictionary: @{@"customTime":timeStr,@"repeatType":repeatTypeStr}];
            [[UIApplication sharedApplication].delegate.window addSubview:timePeriodView];
            [timePeriodView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo([UIApplication sharedApplication].delegate.window);
            }];
        }
    }else {
        //MARK:顶部 场景图片和名称
                if (indexPath.row == 0) {
                    TIoTSettingIntelligentImageVC *settingImageVC = [[TIoTSettingIntelligentImageVC alloc]init];
                    settingImageVC.selectedIntelligentImageBlock = ^(NSString * _Nonnull imageUrl) {
                        NSMutableDictionary *dic  = self.dataArr[0];
                        [dic setValue:imageUrl forKey:@"image"];
                        self.sceneImageUrl = imageUrl;
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        [self.complementTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    };
                    [self.navigationController pushViewController:settingImageVC animated:YES];
                    
                }else if (indexPath.row == 1) {
                    TIoTSettingIntelligentNameVC *settingNameVC = [[TIoTSettingIntelligentNameVC alloc]init];
                    settingNameVC.saveIntelligentNameBlock = ^(NSString * _Nonnull name) {
                        NSMutableDictionary *dic  = self.dataArr[1];
                        [dic setValue:name forKey:@"value"];
                        self.sceneNameString = name;
                        
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        [self.complementTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    };
                    [self.navigationController pushViewController:settingNameVC animated:YES];
                }
    }
    
    
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
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
    }else {
        return 48;
    }
}

- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
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
        [self.conditionArray removeObjectAtIndex:indexPath.row - 1];
        if (self.conditionArray.count == 0) {
            TIoTIntelligentCustomCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.isHideBlankAddView = NO;
            cell.blankAddTipString = NSLocalizedString(@"autoIntelligeng_addCondition", @"添加条件");
        }
    }else {
        [self.actionArray removeObjectAtIndex:indexPath.row - 1];
        if (self.actionArray.count == 0) {
            TIoTIntelligentCustomCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.isHideBlankAddView = NO;
            cell.blankAddTipString = NSLocalizedString(@"autoIntelligeng_addCondition", @"添加条件");
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - 定时编辑完回调代理
//MARK:编辑完定时后，刷新任务列表
- (void)changeDelayTimeString:(NSString *)timeString hour:(NSString *)hourString minuteString:(NSString *)min withAutoDelayIndex:(NSInteger)autoDelayIndex{
    
    NSCharacterSet* hourCharacterSet =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    int hourNumber =[[hourString stringByTrimmingCharactersInSet:hourCharacterSet] intValue];
    
    NSCharacterSet* minutCharacterSet =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    int minutNumber =[[min stringByTrimmingCharactersInSet:minutCharacterSet] intValue];
    NSString *timeStr = [NSString stringWithFormat:@"%d",hourNumber*60*60 + minutNumber*60];
    
    TIoTAutoIntelligentModel *model = self.actionArray[autoDelayIndex];
    model.Data = timeStr;
    model.delayTime = timeString;
    model.delayTimeFormat = [NSString stringWithFormat:@"%d:%d",hourNumber,minutNumber];
    
    [self.actionArray replaceObjectAtIndex:autoDelayIndex withObject:model];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
}


#pragma mark - event

//MARK:添加设备状态条件（model数组）后，刷新list
- (void)refreshAutoIntelligentList:(BOOL)isAction modifyModel:(TIoTAutoIntelligentModel *)modifiedModel originIndex:(NSInteger)indexrow isEdit:(BOOL )isEdit {
    
    if (isAction == YES) {//任务
            
            if (isEdit == YES) {
                if (modifiedModel != nil) {
                    [self.actionArray replaceObjectAtIndex:indexrow withObject:modifiedModel];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                }
                
            }else {

                for (TIoTAutoIntelligentModel *model in self.autoDeviceStatusArray) {
                    [self.actionArray addObject:model];
                }
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            }
        }else { //条件
            
            if (isEdit == YES) {
                if (modifiedModel != nil) {
                    [self.conditionArray replaceObjectAtIndex:indexrow withObject:modifiedModel];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                }
            }else {
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
        _tableView.allowsMultipleSelection = NO;
        _tableView.allowsSelectionDuringEditing = NO;
        _tableView.allowsMultipleSelectionDuringEditing = NO;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    }
    return _tableView;
}


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
        if (self.isSceneDetail == YES) {
            [_nextButtonView bottomViewType:IntelligentBottomViewTypeSingle withTitleArray:@[NSLocalizedString(@"save", @"保存")]];
            __weak typeof(self)weakSelf = self;
            _nextButtonView.confirmBlock = ^{
                //MARK:请求修改手动场景接口
                [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
                
                NSMutableArray *actionArray = [NSMutableArray array];
                for (TIoTAutoIntelligentModel *model in weakSelf.actionArray) {
                    [actionArray addObject:[model yy_modelToJSONObject]];
                }
                NSMutableArray *conditionArray = [NSMutableArray array];
                for (TIoTAutoIntelligentModel *model in weakSelf.conditionArray) {
                    [conditionArray addObject:[model yy_modelToJSONObject]];
                }
                
                NSDictionary *paramDic = @{@"Actions":actionArray,
                                           @"Conditions":conditionArray,
                                           @"AutomationId":weakSelf.autoSceneInfoDic[@"AutomationId"]?:@"",
                                           @"Icon":weakSelf.sceneImageUrl?:@"",
                                           @"Name":weakSelf.sceneNameString?:@"",
                                           @"Status":weakSelf.autoSceneInfoDic[@"Status"]?:@"",
                                           @"MatchType":@(weakSelf.selectedConditonNum)};
                [[TIoTRequestObject shared] post:AppModifyAutomation Param:paramDic success:^(id responseObject) {
                    [MBProgressHUD dismissInView:weakSelf.view];
                    [MBProgressHUD showMessage:NSLocalizedString(@"modify_intelligent_success", @"修改智能成功") icon:@""];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
                    
                }];
            };
            
        }else {
            [_nextButtonView bottomViewType:IntelligentBottomViewTypeSingle withTitleArray:@[NSLocalizedString(@"next", @"下一步")]];
            __weak typeof(self)weakSelf = self;
            _nextButtonView.confirmBlock = ^{
                
                if (self.conditionArray.count == 0 || self.actionArray.count == 0) {
                    [MBProgressHUD showMessage:NSLocalizedString(@"error_add_condition_action", @"请添加任务和条件") icon:@""];
                }else {
                    //MARK:组装好条件、任务、生效时间段 的请求参数 model，跳转到完善页面，添加场景背景URL和名称
                    
                    NSInteger statusInt = 0;
                    for (TIoTAutoIntelligentModel *model in weakSelf.actionArray) {
                        if (model.ActionType == 4) {
                            statusInt = 1;
                        }
                    }
                    
                    NSMutableDictionary *autoDic = [NSMutableDictionary new];
                    [autoDic setValue:@(statusInt) forKey:@"Status"];
                    [autoDic setValue:@(weakSelf.selectedConditonNum) forKey:@"MatchType"];
                    [autoDic setValue:[weakSelf.conditionArray yy_modelToJSONObject]?:@"" forKey:@"Conditions"];
                    [autoDic setValue:[weakSelf.actionArray yy_modelToJSONObject]?:@"" forKey:@"Actions"];
                    [autoDic setValue:weakSelf.paramDic[@"FamilyId"]?:@"" forKey:@"FamilyId"];
                    
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

    }
    return _nextButtonView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;;
}

- (UITableView *)complementTableView {
    if (!_complementTableView) {
        _complementTableView = [[UITableView alloc]init];
        _complementTableView.delegate = self;
        _complementTableView.dataSource = self;
        _complementTableView.backgroundColor = [UIColor whiteColor];
        _complementTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _complementTableView.rowHeight = 48;
    }
    return _complementTableView;
}


- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)allDeviceArray {
    if (!_allDeviceArray) {
        _allDeviceArray = [NSMutableArray array];
    }
    return _allDeviceArray;
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
