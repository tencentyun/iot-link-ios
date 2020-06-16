//
//  WCAddTimerVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCAddTimerVC.h"
#import "WCRepeatVC.h"
#import "WCTimerCell.h"
#import "WCSlideView.h"
#import "WCAlertView.h"
#import "SelectView.h"
#import <QCFoundation/NSString+Extension.h>

static NSString *cellId = @"rv23244";
@interface WCAddTimerVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UIDatePicker *picker;


@property (nonatomic,strong) NSMutableArray *dataArr;

@property (nonatomic,strong) NSString *timerName;//定时名称
@property (nonatomic,strong) NSString *repeatData;//重复数据
@property (nonatomic,strong) NSMutableDictionary *publishData;//定时任务的下发数据

@end

@implementation WCAddTimerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加定时";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WCTimerCell" bundle:nil] forCellReuseIdentifier:cellId];
    
    [self configData];
    [self addTableHeaderView];
    [self addTableFooterView];
}

- (void)configData
{
    NSString *timeName = @"";
    NSString *repeatContent = @"";
    NSDictionary *infos;
    if (self.timerInfo) {
        
        timeName = self.timerInfo[@"TimerName"];
        repeatContent = [self getShowResultByDays:self.timerInfo[@"Days"]];
        infos = [NSString jsonToObject:self.timerInfo[@"Data"]];
        
        self.timerName = self.timerInfo[@"TimerName"];
        self.repeatData = self.timerInfo[@"Days"];
        [self.publishData addEntriesFromDictionary:infos];
        
        
        
        NSString *TimePoint = self.timerInfo[@"TimePoint"];
        
        NSDateFormatter *fomatter = [[NSDateFormatter alloc] init];
        [fomatter setDateFormat:@"HH:mm"];
        NSDate *date = [fomatter dateFromString:TimePoint];
        self.picker.date = date;
    }
    
    
    NSMutableArray *firstSection = [NSMutableArray array];
    [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"name":@"名称设置",@"content":timeName,@"isAdd":@"0"}]];
    [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"name":@"重复",@"content":repeatContent,@"isAdd":@"0"}]];
    [self.dataArr addObject:firstSection];
    
    if (self.actions) {
        
        NSMutableArray *secondSection = [NSMutableArray array];
        for (NSDictionary *pro in self.actions) {
            
            NSString *acCon = @"";
            if (infos) {
                NSString *key = infos[pro[@"id"]];
                if (key) {
                    
                    if ([@"bool" isEqualToString:pro[@"define"][@"type"]] || [@"enum" isEqualToString:pro[@"define"][@"type"]]) {
                        NSDictionary *mapping = pro[@"define"][@"mapping"];
                        acCon = mapping[[NSString stringWithFormat:@"%@",key]];
                    }
                    else if ([@"int" isEqualToString:pro[@"define"][@"type"]] || [@"float" isEqualToString:pro[@"define"][@"type"]])
                    {
                        acCon = [NSString stringWithFormat:@"%@%@",key,pro[@"define"][@"unit"]];
                    }
                }
            }
            
            [secondSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"name":pro[@"name"],@"content":acCon,@"isAdd":acCon.length > 0 ? @"0" : @"1",@"id":pro[@"id"],@"define":pro[@"define"]}]];
        }
        
        [self.dataArr addObject:secondSection];
    }
    
    [self.tableView reloadData];
}


- (void)addTableHeaderView
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 214)];
    header.backgroundColor = kRGBColor(242, 242, 242);
    [header addSubview:self.picker];
    
    self.tableView.tableHeaderView = header;
}

- (void)addTableFooterView
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 60, kScreenWidth - 40, 48);
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:kMainColor];
    [btn addTarget:self action:@selector(toAddOrUpdateTimer) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4;
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
}


#pragma mark - action

- (void)toAddOrUpdateTimer
{
    if (self.timerInfo) {
        [self updateTimer];
    }
    else
    {
        [self createTimer];
    }
}

#pragma mark - requset

- (void)createTimer
{
    
    if (!self.timerName) {
        [MBProgressHUD showMessage:@"请输入定时名称" icon:@""];
        return;
    }
    
    if (!self.repeatData) {
        [MBProgressHUD showMessage:@"请选择重复天数" icon:@""];
        return;
    }
    
    if (self.publishData.count == 0) {
        [MBProgressHUD showMessage:@"请选择设备动作" icon:@""];
        return;
    }
    
    
    [[QCDeviceSet shared] createTimerWithProductId:self.productId deviceName:self.deviceName timerName:self.timerName days:self.repeatData timePoint:self.picker.date repeat:1 data:self.publishData success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:@"成功"];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        [MBProgressHUD showError:reason];
    }];
}

- (void)updateTimer
{
    if (!self.timerName) {
        [MBProgressHUD showMessage:@"请输入定时名称" icon:@""];
        return;
    }
    
    if (!self.repeatData) {
        [MBProgressHUD showMessage:@"请选择重复天数" icon:@""];
        return;
    }
    
    if (self.publishData.count == 0) {
        [MBProgressHUD showMessage:@"请选择设备动作" icon:@""];
        return;
    }
    
    
    [[QCDeviceSet shared] modifyTimerWithTimerId:self.timerInfo[@"TimerId"] productId:self.productId deviceName:self.deviceName timerName:self.timerName days:self.repeatData timePoint:self.picker.date repeat:1 data:self.publishData success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:@"修改成功"];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}


#pragma mark - table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArr[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WCTimerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    [cell setActionInfo:self.dataArr[indexPath.section][indexPath.row]];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 14;
    }
    return 14 + 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 14)];
    view.backgroundColor = kRGBColor(242, 242, 242);
    
    if (section > 0) {
        UIView *action = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 48)];
        action.backgroundColor = [UIColor whiteColor];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth - 40, 20)];
        lab.text = @"设备动作";
        [action addSubview:lab];
        [view addSubview:action];
    }
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                NSMutableDictionary *dic = self.dataArr[0][0];
                
                WCAlertView *av = [[WCAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
                [av alertWithTitle:@"名称设置" message:@"10字以内" cancleTitlt:@"取消" doneTitle:@"确定"];
                av.maxLength = 10;
                av.defaultText = dic[@"content"];
                av.doneAction = ^(NSString * _Nonnull text) {
                    if (text.length > 0) {
                        self.timerName = text;
                        [dic setValue:text forKey:@"content"];
                        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                };
                [av showInView:[UIApplication sharedApplication].keyWindow];
            }
                break;
            case 1:
            {
                WCRepeatVC *vc = [WCRepeatVC new];
                vc.days = self.repeatData;
                vc.repeatResult = ^(NSArray *repeats) {
                    
                    self.repeatData = [repeats componentsJoinedByString:@""];
                    NSMutableDictionary *dic = self.dataArr[0][1];
                    [dic setValue:[self getShowResultForRepeat:repeats] forKey:@"content"];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    
                    
                };
                
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        NSMutableDictionary *pro = self.dataArr[indexPath.section][indexPath.row];
        if ([@"bool" isEqualToString:pro[@"define"][@"type"]] || [@"enum" isEqualToString:pro[@"define"][@"type"]]) {
            SelectView *choseView = [[SelectView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            choseView.isAction = YES;
            choseView.deleteTap = ^{
                [self.publishData removeObjectForKey:pro[@"id"]];
                pro[@"content"] = @"";
                pro[@"isAdd"] = @"1";
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
            choseView.showValue = self.publishData[pro[@"id"]];
            choseView.dic = pro;
            choseView.updateData = ^(NSDictionary * _Nonnull dataDic) {
                NSLog(@"%@",dataDic);
                [self.publishData addEntriesFromDictionary:dataDic];
                
                NSString *key = [NSString stringWithFormat:@"%@",dataDic.allValues.firstObject];
                NSDictionary *mapping = pro[@"define"][@"mapping"];
                pro[@"content"] = mapping[key];
                pro[@"isAdd"] = @"0";
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
            [choseView show];
        }
        else if ([@"int" isEqualToString:pro[@"define"][@"type"]] || [@"float" isEqualToString:pro[@"define"][@"type"]])
        {
            WCSlideView *slideView = [[WCSlideView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            slideView.isAction = YES;
            slideView.deleteTap = ^{
                [self.publishData removeObjectForKey:pro[@"id"]];
                pro[@"content"] = @"";
                pro[@"isAdd"] = @"1";
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
            slideView.showValue = self.publishData[pro[@"id"]];
            slideView.dic = pro;
            slideView.updateData = ^(NSDictionary * _Nonnull dataDic) {
                
                [self.publishData addEntriesFromDictionary:dataDic];
                
                NSString *key = [NSString stringWithFormat:@"%@",dataDic.allValues.firstObject];
                NSString *unit = pro[@"define"][@"unit"];
                pro[@"content"] = [NSString stringWithFormat:@"%@%@",key,unit];
                pro[@"isAdd"] = @"0";
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
            [slideView show];
        }
    }
}


#pragma mark - getter

- (UIDatePicker *)picker
{
    if (!_picker) {
        _picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 200)];
        _picker.datePickerMode = UIDatePickerModeTime;
        _picker.backgroundColor = [UIColor whiteColor];
    }
    return _picker;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    
    return _dataArr;
}

- (NSMutableDictionary *)publishData
{
    if (!_publishData) {
        _publishData = [NSMutableDictionary dictionary];
    }
    return _publishData;
}

#pragma mark - other

- (NSString *)getShowResultForRepeat:(NSArray *)repeats
{
    NSString *con = @"";
    
    if ([repeats[1] boolValue] == NO && [repeats[2] boolValue] == NO && [repeats[3] boolValue] == NO && [repeats[4] boolValue] == NO && [repeats[5] boolValue] == NO && [repeats[6] boolValue] && [repeats[0] boolValue]) {
        con = @"周末";
    }
    else if ([repeats[1] boolValue] && [repeats[2] boolValue] && [repeats[3] boolValue] && [repeats[4] boolValue] && [repeats[5] boolValue] && [repeats[6] boolValue] == NO && [repeats[0] boolValue] == NO) {
        con = @"工作日";
    }
    else if ([repeats[1] boolValue] && [repeats[2] boolValue] && [repeats[3] boolValue] && [repeats[4] boolValue] && [repeats[5] boolValue] && [repeats[6] boolValue] && [repeats[0] boolValue]) {
        con = @"每天";
    }
    else
    {
        for (unsigned int i = 0; i < repeats.count; i ++) {
            if ([repeats[i] boolValue]) {
                NSString *weakday = @"";
                switch (i) {
                    case 0:
                        weakday = @"周日";
                        break;
                    case 1:
                        weakday = @"周一";
                        break;
                    case 2:
                        weakday = @"周二";
                        break;
                    case 3:
                        weakday = @"周三";
                        break;
                    case 4:
                        weakday = @"周四";
                        break;
                    case 5:
                        weakday = @"周五";
                        break;
                    case 6:
                        weakday = @"周六";
                        break;
                        
                    default:
                        break;
                }
                
                con = [NSString stringWithFormat:@"%@ %@",con,weakday];
            }
        }
    }
    
    return con;
}

- (NSString *)getShowResultByDays:(NSString *)days
{
    const char *repeats = [days UTF8String];
    
    NSString *con = @"";
    
    if ((BOOL)(repeats[1] - '0') == NO && (BOOL)(repeats[2] - '0') == NO && (BOOL)(repeats[3] - '0') == NO && (BOOL)(repeats[4] - '0') == NO && (BOOL)(repeats[5] - '0') == NO && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con = @"周末";
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') == NO && (BOOL)(repeats[0] - '0') == NO) {
        con = @"工作日";
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con = @"每天";
    }
    else
    {
        
        for (unsigned int i = 0; i < 7; i ++) {
            if ((BOOL)(repeats[i] - '0')) {
                NSString *weakday = @"";
                switch (i) {
                    case 0:
                        weakday = @"周日";
                        break;
                    case 1:
                        weakday = @"周一";
                        break;
                    case 2:
                        weakday = @"周二";
                        break;
                    case 3:
                        weakday = @"周三";
                        break;
                    case 4:
                        weakday = @"周四";
                        break;
                    case 5:
                        weakday = @"周五";
                        break;
                    case 6:
                        weakday = @"周六";
                        break;

                    default:
                        break;
                }

                con = [NSString stringWithFormat:@"%@ %@",con,weakday];
            }
        }
    }
    
    return con;
}

@end
