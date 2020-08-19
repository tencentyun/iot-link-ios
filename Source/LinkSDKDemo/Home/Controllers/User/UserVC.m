//
//  UserVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/4.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "UserVC.h"
#import "UserInfoVC.h"

#import <ifaddrs.h>
#import <sys/socket.h>
#import <arpa/inet.h>

@interface UserVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic,strong) NSArray *titles;

@property (nonatomic,copy) NSMutableDictionary *tp2;

@end

@implementation UserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"poi"];
    self.table.tableFooterView = [UIView new];
}

#pragma mark -


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poi" forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row][@"name"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIViewController *vc = [[NSClassFromString(self.titles[indexPath.row][@"vc"]) alloc] init];
    vc.title = self.titles[indexPath.row][@"name"];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - getter

- (NSArray *)titles
{
    if (!_titles) {
        _titles = @[@{@"name":@"个人信息",@"vc":@"UserInfoVC"},
                    @{@"name":@"家庭管理",@"vc":@"TIoTCoreFamiliesVC"},
                    @{@"name":@"消息通知",@"vc":@"MessageVC"},
                    @{@"name":@"意见反馈",@"vc":@"FeedbackVC"}];
    }
    return _titles;
}


@end
