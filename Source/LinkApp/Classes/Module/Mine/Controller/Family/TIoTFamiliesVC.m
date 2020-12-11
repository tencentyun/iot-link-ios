//
//  WCFamiliesVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTFamiliesVC.h"
#import "TIoTHelpCell.h"
#import "TIoTNavigationController.h"
#import "TIoTFamilyInfoVC.h"
#import "UIButton+LQRelayout.h"

static NSString *cellId = @"rbrb";

@interface TIoTFamiliesVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *families;

@end

@implementation TIoTFamiliesVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [HXYNotice addUpdateFamilyListListener:self reaction:@selector(getFamilyList)];
    
    [self setupUI];
    
    [self getFamilyList];
}

- (void)setupUI
{
    self.title = NSLocalizedString(@"family_manager", @"家庭管理");
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self.tableView registerClass:[TIoTHelpCell class] forCellReuseIdentifier:cellId];
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.rowHeight = 48;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 24, kScreenWidth - 40, 40);
    [btn setTitle:NSLocalizedString(@"add_family", @"添加家庭")  forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setImage:[UIImage imageNamed:@"share_device"] forState:UIControlStateNormal];
    [btn relayoutButton:XDPButtonLayoutStyleLeft];
    [btn addTarget:self action:@selector(toAddFamily) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 20;
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
    
}

- (void)toAddFamily
{
    UIViewController *vc = [NSClassFromString(@"TIoTAddFamilyVC") new];
//    WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController pushViewController:vc animated:YES];
//    [self presentViewController:nav animated:YES completion:^{
//
//    }];
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.families.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIoTHelpCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.name = self.families[indexPath.row][@"FamilyName"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIoTFamilyInfoVC *vc = [[TIoTFamilyInfoVC alloc] init];
    vc.familyInfo = self.families[indexPath.row];
    vc.familyCount = self.families.count;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -

- (void)getFamilyList
{
    [[TIoTRequestObject shared] post:AppGetFamilyList Param:@{} success:^(id responseObject) {
        if ([responseObject[@"FamilyList"] isKindOfClass:[NSArray class]]) {
            [self.families removeAllObjects];
            [self.families addObjectsFromArray:responseObject[@"FamilyList"]];
            [self.tableView reloadData];
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
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
