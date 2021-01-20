//
//  TIoTPlayListVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTPlayListVC.h"
#import "TIoTPlayListCell.h"
#import "TIoTPlayMovieVC.h"

@interface TIoTPlayListVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation TIoTPlayListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpUI];
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTPlayListCell * cell = [TIoTPlayListCell cellWithTableView:tableView];
    cell.deviceNameString = self.dataArray[indexPath.row];
    cell.playLeftBlock = ^{
        TIoTPlayMovieVC *video = [[TIoTPlayMovieVC alloc] init];
        video.modalPresentationStyle = UIModalPresentationFullScreen;
        video.videoUrl = @"http://zhibo.hkstv.tv/livestream/mutfysrq.flv";
        [self presentViewController:video animated:NO completion:nil];
    };
    
    cell.playMiddBlock = ^{
        
    };
    
    cell.playRightBlock = ^{
        
    };
    return cell;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 110;
    }
    return _tableView;
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"sp01_32820237_1",@"sp01_32820237_2",@"sp01_32820237_3"];
    }
    return  _dataArray;
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
