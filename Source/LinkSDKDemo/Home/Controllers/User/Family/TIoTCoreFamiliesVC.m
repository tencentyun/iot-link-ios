//
//  WCFamiliesVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCFamiliesVC.h"
#import "WCFamilyInfoVC.h"

static NSString *cellId = @"rbrb";

@interface WCFamiliesVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *families;

@end

@implementation WCFamiliesVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    [self getFamilyList];
}

- (void)setupUI
{
    self.title = @"家庭管理";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 60, kScreenWidth - 40, 48);
    [btn setTitle:@"添加家庭" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:kMainColor];
    [btn addTarget:self action:@selector(toAddFamily) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
    
}

- (void)toAddFamily
{
    UIViewController *vc = [NSClassFromString(@"WCAddFamilyVC") new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.families.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.text = self.families[indexPath.row][@"FamilyName"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WCFamilyInfoVC *vc = [[WCFamilyInfoVC alloc] init];
    vc.familyInfo = self.families[indexPath.row];
    vc.familyCount = self.families.count;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - req

- (void)getFamilyList
{
    [[QCFamilySet shared] getFamilyListWithOffset:0 limit:0 success:^(id  _Nonnull responseObject) {
        [self.families removeAllObjects];
        [self.families addObjectsFromArray:responseObject[@"FamilyList"]];
        [self.tableView reloadData];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
    
}


#pragma mark - getter

- (NSMutableArray *)families
{
    if (!_families) {
        _families = [NSMutableArray array];
    }
    return _families;
}

@end
