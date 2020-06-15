//
//  WCRepeatVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCRepeatVC.h"

static NSString *cellId = @"ededf";
@interface WCRepeatVC ()

@property (nonatomic,strong) NSArray *week;
@property (nonatomic,strong) NSMutableArray *weekSelect;

@end

@implementation WCRepeatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"重复";
    [self configData];
    self.tableView.rowHeight = 60;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    [self addTableFooterView];
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
    [btn addTarget:self action:@selector(saveRepeatData) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4;
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
}

- (void)saveRepeatData
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.repeatResult) {
        self.repeatResult([self.weekSelect copy]);
    }
}

- (void)configData
{
    if (self.days) {
        const char *repeats = [self.days UTF8String];
        
        for (int i = 0; i < 7; i ++) {
            int a = repeats[i] - '0';
            self.weekSelect[i] = [NSString stringWithFormat:@"%i",a];
        }
    }
    
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.week.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    for (UIView *sub in cell.contentView.subviews) {
        [sub removeFromSuperview];
    }
    
    cell.textLabel.text = self.week[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.weekSelect[indexPath.row] integerValue] == 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 59, [UIScreen mainScreen].bounds.size.width - 40, 1)];
    line.backgroundColor = kRGBColor(245, 245, 245);
    [cell.contentView addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.weekSelect[indexPath.row] integerValue] == 1) {
        [self.weekSelect replaceObjectAtIndex:indexPath.row withObject:@"0"];
    }
    else
    {
        [self.weekSelect replaceObjectAtIndex:indexPath.row withObject:@"1"];
    }
    [tableView reloadData];
}


#pragma mark -

- (NSArray *)week
{
    if (!_week) {
        _week = @[@"每周日",@"每周一",@"每周二",@"每周三",@"每周四",@"每周五",@"每周六"];
    }
    return _week;
}

- (NSMutableArray *)weekSelect
{
    if (!_weekSelect) {
        _weekSelect = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
    }
    return _weekSelect;
}

@end
