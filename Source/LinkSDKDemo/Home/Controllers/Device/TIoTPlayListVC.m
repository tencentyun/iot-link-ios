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
#import "TIoTCloudStorageVC.h"
#import "TIoTCoreAppEnvironment.h"
#import "TIoTCoreDeviceSet.h"
#import "TIoTCoreXP2PBridge.h"

#import "TIoTExploreDeviceListModel.h"
#import "TIoTVideoDeviceListModel.h"
#import "TIoTExploreOrVideoDeviceModel.h"

#import <YYModel.h>

@interface TIoTPlayListVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation TIoTPlayListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpUI];
    
    //Video 设备列表
//    [self requestVideoList];
    
    //explore 设备列表
//#ifdef DEBUG
    [self requestExploreList];
//#endif
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
}

#pragma mark - request

/// video 设备列表
- (void)requestVideoList {
        [[TIoTCoreDeviceSet shared] getVideoDeviceListLimit:99 offset:0 productId:[TIoTCoreAppEnvironment shareEnvironment].cloudProductId returnModel:YES success:^(id  _Nonnull responseObject) {
            TIoTVideoDeviceListModel *model = [TIoTVideoDeviceListModel yy_modelWithJSON:responseObject];
            
            [self.dataArray removeAllObjects];
            self.dataArray = [NSMutableArray arrayWithArray:model.Data];
            [self.tableView reloadData];
    
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
    
        }];
}


/// explore 设备列表
- (void)requestExploreList {
        [[TIoTCoreDeviceSet shared] getExploreDeviceListLimit:99 offset:0 productId:[TIoTCoreAppEnvironment shareEnvironment].cloudProductId success:^(id  _Nonnull responseObject) {
    
            TIoTExploreDeviceListModel *model = [TIoTExploreDeviceListModel yy_modelWithJSON:responseObject];
            
            [self.dataArray removeAllObjects];
            self.dataArray = [NSMutableArray arrayWithArray:model.Devices];
            [self.tableView reloadData];
    
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
    
        }];
}

#pragma mark - tableViewDelegate tableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTPlayListCell * cell = [TIoTPlayListCell cellWithTableView:tableView];
    
    TIoTExploreOrVideoDeviceModel *model = self.dataArray[indexPath.row];
    cell.deviceNameString = model.DeviceName;
    
    NSString *nameNameString = cell.deviceNameString?:@"";
    
    cell.playRealTimeMonitoringBlock = ^{

        [[TIoTCoreXP2PBridge sharedInstance] startAppWith:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretId sec_key:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretKey pro_id:[TIoTCoreAppEnvironment shareEnvironment].cloudProductId dev_name:nameNameString];

            NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv]?:@"";
            TIoTPlayMovieVC *video = [[TIoTPlayMovieVC alloc] init];
            video.modalPresentationStyle = UIModalPresentationFullScreen;
            video.playType = TIotPLayTypeLive;
            video.videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
            [self presentViewController:video animated:NO completion:nil];
    };
    
    cell.playLocalPlaybackBlock = ^{

        [[TIoTCoreXP2PBridge sharedInstance] startAppWith:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretId sec_key:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretKey pro_id:[TIoTCoreAppEnvironment shareEnvironment].cloudProductId dev_name:nameNameString];

            NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv]?:@"";
            TIoTPlayMovieVC *video = [[TIoTPlayMovieVC alloc] init];
            video.playType = TIotPLayTypePlayback;
            video.modalPresentationStyle = UIModalPresentationFullScreen;
            video.videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=playback",urlString];
            [self presentViewController:video animated:NO completion:nil];
    };
    
    cell.playCloudStorageBlock = ^{
        TIoTCloudStorageVC *cloudStorage = [[TIoTCloudStorageVC alloc]init];
        [self.navigationController pushViewController:cloudStorage animated:YES];
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

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<4; i++) {
            TIoTExploreOrVideoDeviceModel *model = [TIoTExploreOrVideoDeviceModel new];
            model.DeviceName = [NSString stringWithFormat:@"sp01_32820237_%d",i+1];
            [_dataArray addObject:model];
        }
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
