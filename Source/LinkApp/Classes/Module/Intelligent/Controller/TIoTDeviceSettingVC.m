//
//  TIoTDeviceSettingVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTDeviceSettingVC.h"
#import "TIoTDeviceDetailTableViewCell.h"
#import "TIoTIntelligentBottomActionView.h"
#import "TIoTAddManualIntelligentVC.h"
#import "TIoTChooseClickValueView.h"
#import "TIoTChooseSliderValueView.h"

@interface TIoTDeviceSettingVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;      //task 操作自定义view
@property (nonatomic, strong) TIoTChooseClickValueView *clickValueView;         //enum和bool 点击选择view
@property (nonatomic, strong) TIoTChooseSliderValueView *sliderValueView;       //int和float 滑动选择view
@end

@implementation TIoTDeviceSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.title = @"testtest";
    
    CGFloat kBottomViewHeight = 90;
    
    [self.view addSubview: self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-kBottomViewHeight);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
}

#pragma mark - UITableViewDelegate And UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTDeviceDetailTableViewCell *cell = [TIoTDeviceDetailTableViewCell cellWithTableView:tableView];
    cell.dic = [self dataArr][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#warning  enum和bool都是开关这种样式，int和float都是亮度这种样式
    
// MARK: - 测试 点击选择 滑动选择
    
//    [[UIApplication sharedApplication].delegate.window addSubview:self.clickValueView];
//    [self.clickValueView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo([UIApplication sharedApplication].delegate.window);
//        make.bottom.equalTo(self.bottomView.mas_top);
//    }];
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.sliderValueView];
    [self.sliderValueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo([UIApplication sharedApplication].delegate.window);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    
}

#pragma mark - event

#pragma mark - lazy loading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 48;
    }
    return _tableView;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        __weak typeof(self)weakSelf = self;
            [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"save", @"保存")]];
            
            _bottomView.firstBlock = ^{
                if (weakSelf.clickValueView) {
                    [weakSelf.clickValueView removeFromSuperview];
                }
                if (weakSelf.sliderValueView) {
                    [weakSelf.sliderValueView removeFromSuperview];
                }
                
//                [weakSelf.bottomView removeFromSuperview];
//                [weakSelf.navigationController popViewControllerAnimated:YES];
#warning 返回前先释放当期加载view
            };
            
            _bottomView.secondBlock = ^{
                if (weakSelf.clickValueView) {
                    [weakSelf.clickValueView removeFromSuperview];
                }
                if (weakSelf.sliderValueView) {
                    [weakSelf.sliderValueView removeFromSuperview];
                }
#warning 保存然后刷新手动添加智能tableView
                
                TIoTAddManualIntelligentVC *addManualTask = [[TIoTAddManualIntelligentVC alloc]init];
                [weakSelf.navigationController pushViewController:addManualTask animated:YES];
            };
            
        
        
    }
    return _bottomView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_share", @"设备Test"),@"value":NSLocalizedString(@"unset", @"未设置"),@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_share", @"设备Test"),@"value":NSLocalizedString(@"unset", @"未设置"),@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_share", @"设备Test"),@"value":NSLocalizedString(@"unset", @"未设置"),@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_share", @"设备Test"),@"value":NSLocalizedString(@"unset", @"未设置"),@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"device_share", @"设备Test"),@"value":NSLocalizedString(@"unset", @"未设置"),@"needArrow":@"1"}]];
    }
    return _dataArr;
}

- (TIoTChooseClickValueView *)clickValueView {
    if (!_clickValueView) {
        _clickValueView = [[TIoTChooseClickValueView alloc]init];
    }
    return _clickValueView;
}

- (TIoTChooseSliderValueView *)sliderValueView {
    if (!_sliderValueView) {
        _sliderValueView = [[TIoTChooseSliderValueView alloc]init];
    }
    return _sliderValueView;
}

@end
