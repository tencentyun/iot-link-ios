//
//  WCAddTimerVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTAddTimerVC.h"
#import "TIoTRepeatVC.h"
#import "TIoTTimerCell.h"
#import "TIoTChoseValueView.h"
#import "TIoTSlideView.h"
#import "NSString+Extension.h"

static NSString *cellId = @"rv23244";
@interface TIoTAddTimerVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UIDatePicker *picker;


@property (nonatomic,strong) NSMutableArray *dataArr;

@property (nonatomic,strong) NSString *timerName;//定时名称
@property (nonatomic,strong) NSString *repeatData;//重复数据
@property (nonatomic,strong) NSMutableDictionary *publishData;//定时任务的下发数据

@end

@implementation TIoTAddTimerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"add_timer", @"添加定时");
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TIoTTimerCell" bundle:nil] forCellReuseIdentifier:cellId];
    
    [self configData];
    [self addTableHeaderView];
    [self addTableFooterView];
}

- (void)configData
{
    self.repeatData = @"0000000";//重复状态，仅一次
    
    NSString *timeName = @"";
    NSString *repeatContent = NSLocalizedString(@"only_one_time", @"仅一次");
    NSDictionary *infos;
    if (self.timerInfo) {
        
        timeName = self.timerInfo[@"TimerName"];
        infos = [NSString jsonToObject:self.timerInfo[@"Data"]];
        
        BOOL repeat = [self.timerInfo[@"Repeat"] boolValue];
        if (repeat) {
            self.repeatData = self.timerInfo[@"Days"];
        }
        else
        {
            self.repeatData = @"0000000";
        }
        repeatContent = [self getShowResultByDays:self.repeatData];
        self.timerName = self.timerInfo[@"TimerName"];
        [self.publishData addEntriesFromDictionary:infos];
        
        
        
        NSString *TimePoint = self.timerInfo[@"TimePoint"];
        
        NSDateFormatter *fomatter = [[NSDateFormatter alloc] init];
        NSString *timezoneString = self.actions[0][@"Region"];
        fomatter.timeZone = [NSTimeZone timeZoneWithName:timezoneString];
        [fomatter setDateFormat:@"HH:mm"];
        NSDate *date = [fomatter dateFromString:TimePoint];
        self.picker.date = date;
    }
    
    
    NSMutableArray *firstSection = [NSMutableArray array];
    [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"name":NSLocalizedString(@"timing_name", @"名称设置") ,@"content":timeName,@"isAdd":@"0"}]];
    [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"name":NSLocalizedString(@"repeat", @"重复"),@"content":repeatContent,@"isAdd":@"0"}]];
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
//                        acCon = [NSString stringWithFormat:@"%@%@",key,pro[@"define"][@"unit"]];
                        
                        //国际化版本 温度转换
                        if ([pro[@"id"]isEqualToString:@"Temperature"]) {
                            NSDictionary *userconfig = pro[@"Userconfig"];
                            acCon = [NSString judepTemperatureWithUserConfig:userconfig[@"TemperatureUnit"] templeUnit:[NSString stringWithFormat:@"%@%@",key,pro[@"define"][@"unit"]]];;
                        }else {
                            acCon = [NSString stringWithFormat:@"%@%@",key,pro[@"define"][@"unit"]];
                        }
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
    [btn setTitle:NSLocalizedString(@"save", @"保存") forState:UIControlStateNormal];
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
    
    NSString *timePoint = [NSString convertTimestampToTime:@([self.picker.date timeIntervalSince1970]) byDateFormat:@"HH:mm"];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:self.productId forKey:@"ProductId"];
    [param setValue:self.deviceName forKey:@"DeviceName"];
    [param setValue:self.timerName forKey:@"TimerName"];
    [param setValue:timePoint forKey:@"TimePoint"];
    if ([self.repeatData integerValue] > 0) {
        [param setValue:@(1) forKey:@"Repeat"];
        [param setValue:self.repeatData forKey:@"Days"];
    }
    else
    {
        [param setValue:@(0) forKey:@"Repeat"];
        [param setValue:@"1111111" forKey:@"Days"];
    }
    [param setValue:[NSString objectToJson:self.publishData] forKey:@"Data"];
    
    [[TIoTRequestObject shared] post:AppCreateTimer Param:param success:^(id responseObject) {
        
        [HXYNotice addUpdateTimerListPost];
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
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
    
    NSString *timePoint = [NSString convertTimestampToTime:@([self.picker.date timeIntervalSince1970]) byDateFormat:@"HH:mm"];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:self.productId forKey:@"ProductId"];
    [param setValue:self.deviceName forKey:@"DeviceName"];
    [param setValue:self.timerName forKey:@"TimerName"];
    [param setValue:self.timerInfo[@"TimerId"] forKey:@"TimerId"];
    [param setValue:timePoint forKey:@"TimePoint"];
    if ([self.repeatData integerValue] > 0) {
        [param setValue:@(1) forKey:@"Repeat"];
        [param setValue:self.repeatData forKey:@"Days"];
    }
    else
    {
        [param setValue:@(0) forKey:@"Repeat"];
        [param setValue:@"1111111" forKey:@"Days"];
    }
    [param setValue:[NSString objectToJson:self.publishData] forKey:@"Data"];
    
    [[TIoTRequestObject shared] post:AppModifyTimer Param:param success:^(id responseObject) {
        [HXYNotice addUpdateTimerListPost];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
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
    TIoTTimerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
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
        lab.text = NSLocalizedString(@"device_action", @"设备动作");
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
                
                TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
                [av alertWithTitle:NSLocalizedString(@"timing_name", @"名称设置")  message:NSLocalizedString(@"less10characters", @"10字以内") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"confirm", @"确定")];
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
                TIoTRepeatVC *vc = [TIoTRepeatVC new];
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
            TIoTChoseValueView *choseView = [[TIoTChoseValueView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
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
            TIoTSlideView *slideView = [[TIoTSlideView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            slideView.isAction = YES;
            slideView.deleteTap = ^{
                [self.publishData removeObjectForKey:pro[@"id"]];
                pro[@"content"] = @"";
                pro[@"isAdd"] = @"1";
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
            slideView.showValue = self.publishData[pro[@"id"]];
//            slideView.dic = pro;
            
            //国际化版本 温度转换
            NSMutableDictionary *tempUnitDic = pro[@"define"];
            if ([pro[@"id"]isEqualToString:@"Temperature"]) {
                NSDictionary *userconfig = pro[@"Userconfig"];
                [tempUnitDic setValue:[NSString changeTemperatureValue:tempUnitDic[@"max"] userConfig:userconfig[@"TemperatureUnit"]] forKey:@"max"];
                [tempUnitDic setValue:[NSString changeTemperatureValue:tempUnitDic[@"min"] userConfig:userconfig[@"TemperatureUnit"]] forKey:@"min"];
                [tempUnitDic setValue:[NSString changeTemperatureValue:tempUnitDic[@"start"] userConfig:userconfig[@"TemperatureUnit"]] forKey:@"start"];
                [tempUnitDic setValue:[NSString judepTemperatureWithUserConfig:userconfig[@"TemperatureUnit"] templeUnit:tempUnitDic[@"unit"]] forKey:@"unit"];
            }
            [pro setValue:tempUnitDic forKey:@"define"];
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
        if (self.actions) {
            NSDateFormatter *fomatter = [[NSDateFormatter alloc] init];
            NSString *timezoneString = self.actions[0][@"Region"];
            fomatter.timeZone = [NSTimeZone timeZoneWithName:timezoneString];
            [fomatter setDateFormat: @"HH:mm"];
            NSString *timeStamp = [NSString getNowTimeStingWithTimeZone:timezoneString formatter:@"HH:mm"];
            NSDate *date = [fomatter dateFromString:timeStamp];
            _picker.date = date;
            [_picker setDate:date animated:NO];
        }
        
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
        con = NSLocalizedString(@"weekend", @"周末");
    }
    else if ([repeats[1] boolValue] && [repeats[2] boolValue] && [repeats[3] boolValue] && [repeats[4] boolValue] && [repeats[5] boolValue] && [repeats[6] boolValue] == NO && [repeats[0] boolValue] == NO) {
        con = NSLocalizedString(@"work_day", @"工作日") ;
    }
    else if ([repeats[1] boolValue] && [repeats[2] boolValue] && [repeats[3] boolValue] && [repeats[4] boolValue] && [repeats[5] boolValue] && [repeats[6] boolValue] && [repeats[0] boolValue]) {
        con = NSLocalizedString(@"everyday", @"每天");
    }
    else
    {
        for (unsigned int i = 0; i < repeats.count; i ++) {
            if ([repeats[i] boolValue]) {
                NSString *weakday = @"";
                switch (i) {
                    case 0:
                        weakday = NSLocalizedString(@"sunday", @"周日");
                        break;
                    case 1:
                        weakday = NSLocalizedString(@"monday", @"周一") ;
                        break;
                    case 2:
                        weakday = NSLocalizedString(@"tuesday", @"周二");
                        break;
                    case 3:
                        weakday = NSLocalizedString(@"wednesday", @"周三");
                        break;
                    case 4:
                        weakday = NSLocalizedString(@"thursday", @"周四");
                        break;
                    case 5:
                        weakday = NSLocalizedString(@"friday", @"周五");
                        break;
                    case 6:
                        weakday = NSLocalizedString(@"saturday", @"周六");
                        break;
                        
                    default:
                        break;
                }
                
                con = [NSString stringWithFormat:@"%@ %@",con,weakday];
            }
        }
    }
    
    if (con.length == 0) {
        con = NSLocalizedString(@"only_one_time", @"仅一次");
    }
    return con;
}

- (NSString *)getShowResultByDays:(NSString *)days
{
    const char *repeats = [days UTF8String];
    
    NSString *con = @"";
    
    if ((BOOL)(repeats[1] - '0') == NO && (BOOL)(repeats[2] - '0') == NO && (BOOL)(repeats[3] - '0') == NO && (BOOL)(repeats[4] - '0') == NO && (BOOL)(repeats[5] - '0') == NO && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con = NSLocalizedString(@"weekend", @"周末");
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') == NO && (BOOL)(repeats[0] - '0') == NO) {
        con = NSLocalizedString(@"work_day", @"工作日");
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con = NSLocalizedString(@"everyday", @"每天");
    }
    else
    {
        
        for (unsigned int i = 0; i < 7; i ++) {
            if ((BOOL)(repeats[i] - '0')) {
                NSString *weakday = @"";
                switch (i) {
                    case 0:
                        weakday = NSLocalizedString(@"sunday", @"周日");
                        break;
                    case 1:
                        weakday = NSLocalizedString(@"monday", @"周一");
                        break;
                    case 2:
                        weakday = NSLocalizedString(@"tuesday", @"周二");
                        break;
                    case 3:
                        weakday = NSLocalizedString(@"wednesday", @"周三");
                        break;
                    case 4:
                        weakday = NSLocalizedString(@"thursday", @"周四");
                        break;
                    case 5:
                        weakday = NSLocalizedString(@"friday", @"周五");
                        break;
                    case 6:
                        weakday = NSLocalizedString(@"saturday", @"周六");
                        break;

                    default:
                        break;
                }

                con = [NSString stringWithFormat:@"%@ %@",con,weakday];
            }
        }
    }
    
    if (con.length == 0) {
        con = NSLocalizedString(@"only_one_time", @"仅一次");
    }
    
    return con;
}

@end
