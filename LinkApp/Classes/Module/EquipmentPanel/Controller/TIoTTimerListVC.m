//
//  WCCloudTimingViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTTimerListVC.h"
#import "TIoTAddTimerVC.h"
#import "TIoTTimerListCell.h"


static NSString *cellId = @"ub67989";
@interface TIoTTimerListVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic,strong) NSMutableArray *timers;
@property (nonatomic) UInt32 offset;//数据条数偏移量

@end

@implementation TIoTTimerListVC

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [HXYNotice addUpdateTimerListListener:self reaction:@selector(getTimerList)];
    
    [self setupUI];
    [self getTimerList];
}

#pragma mark privateMethods
- (void)setupUI{
    self.title = @"云端定时";
    self.view.backgroundColor = kBgColor;
    self.fd_interactivePopDisabled = YES;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    
    [self addTableFooterView];
}

- (void)addTableFooterView
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 60, kScreenWidth - 40, 48);
    [btn setTitle:@"添加定时" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:kMainColor];
    [btn addTarget:self action:@selector(addTimer:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4;
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
}

- (void)toAddTimer{
    
    TIoTAddTimerVC *vc = [[TIoTAddTimerVC alloc] init];
    vc.productId = self.productId;
    vc.deviceName = self.deviceName;
    vc.actions = self.actions;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)refreshUI:(NSInteger)count{
    
    if (count == 0) {
        
        [MBProgressHUD dismissInView:self.view];
        
        [self.tableView showEmpty:@"添加定时" desc:@"暂无定时,点击任意处进行添加" image:[UIImage imageNamed:@"noTimer"] block:^{
            [self toAddTimer];
        }];
        
        [self.tableView reloadData];
    }
    else{
        [self.tableView hideStatus];
        [self.tableView reloadData];
    }
}

#pragma mark - req

- (void)getTimerList
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.productId forKey:@"ProductId"];
    [dic setValue:self.deviceName forKey:@"DeviceName"];
    [dic setValue:@(self.offset) forKey:@"Offset"];
    [dic setValue:@(50) forKey:@"Limit"];
    
    [[TIoTRequestObject shared] post:AppGetTimerList Param:dic success:^(id responseObject) {
        
        [self.timers removeAllObjects];
        [self.timers addObjectsFromArray:responseObject[@"TimerList"]];
        [self refreshUI:[responseObject[@"Total"] integerValue]];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)deleteTimer:(NSString *)timerId andIndex:(NSInteger)row
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.productId forKey:@"ProductId"];
    [dic setValue:self.deviceName forKey:@"DeviceName"];
    [dic setValue:timerId forKey:@"TimerId"];
    
    [[TIoTRequestObject shared] post:AppDeleteTimer Param:dic success:^(id responseObject) {
        [self.timers removeObjectAtIndex:row];
        [self refreshUI:self.timers.count];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}


#pragma mark - event

- (void)addTimer:(id)sender{
    [self toAddTimer];
}

#pragma mark TableViewDelegate && TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.timers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TIoTTimerListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    [cell setInfo:self.timers[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTAddTimerVC *vc = [[TIoTAddTimerVC alloc] init];
    vc.productId = self.productId;
    vc.deviceName = self.deviceName;
    vc.actions = self.actions;
    vc.timerInfo = self.timers[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *timerId = self.timers[indexPath.row][@"TimerId"];
        [self deleteTimer:timerId andIndex:indexPath.row];
    }
}

// 修改编辑按钮文字

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
//        _tableView.backgroundColor = kRGBColor(243, 243, 243);
        _tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        _tableView.rowHeight = 80;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerNib:[UINib nibWithNibName:@"TIoTTimerListCell" bundle:nil] forCellReuseIdentifier:cellId];
    }
    
    return _tableView;
}

- (NSMutableArray *)timers
{
    if (!_timers) {
        _timers = [NSMutableArray array];
    }
    return _timers;
}

@end
