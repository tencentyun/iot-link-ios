//
//  WCDiscoverProductView.m
//  TenextCloud
//
//  Created by Sun on 2020/5/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTDiscoverProductView.h"
#import "TIoTProductTableViewCell.h"

@interface TIoTDiscoverProductView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *productArr;

@end

@implementation TIoTDiscoverProductView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.status = DiscoverDeviceStatusDiscovering;
    }
    return self;
}

- (void)setupDiscoveringUI{
    
    self.backgroundColor = kBgColor;
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.font = [UIFont wcPfRegularFontOfSize:16];
    tipLab.textColor = [UIColor blackColor];
    tipLab.text = NSLocalizedString(@"scanning_device", @"正在扫描附近设备");
    [self addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(16.55);
        make.centerY.equalTo(self).offset(-0.75);
    }];
    
    UIImageView *loadView = [[UIImageView alloc] init];
    loadView.image = [UIImage imageNamed:@"new_add_loading"];
    // 旋转动画
    CABasicAnimation *animation = [CABasicAnimation
                                   animationWithKeyPath: @"transform" ];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    animation.toValue = [NSValue valueWithCATransform3D:
                         CATransform3DMakeRotation(M_PI + 0.01, 0.0, 0.0, -1.0) ];
    animation.duration = 0.5;
    
    animation.cumulative = YES;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    
    // 添加动画
    [loadView.layer addAnimation:animation forKey:nil];
    [self addSubview:loadView];
    [loadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tipLab);
        make.right.equalTo(tipLab.mas_left).offset(-10.2);
        make.width.height.mas_equalTo(23.1);
    }];
    
    UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [helpBtn setImage:[UIImage imageNamed:@"new_add_help"] forState:UIControlStateNormal];
    [helpBtn addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:helpBtn];
    [helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(6.5);
        make.width.height.mas_equalTo(34);
    }];
    
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanBtn setImage:[UIImage imageNamed:@"new_add_scan"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:scanBtn];
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(helpBtn.mas_left).offset(-10);
        make.top.width.height.equalTo(helpBtn);
    }];
    
}

- (void)setupDiscoveredProductUI{
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addTableHeaderView];
}

- (void)addTableHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45.5)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.font = [UIFont wcPfRegularFontOfSize:16];
    tipLab.textColor = [UIColor blackColor];
    tipLab.text = NSLocalizedString(@"scanned_devices",  @"已发现如下设备");
    [headerView addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(15.5);
        make.centerY.equalTo(headerView);
    }];
    
    UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [helpBtn setImage:[UIImage imageNamed:@"new_add_help"] forState:UIControlStateNormal];
    [helpBtn addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:helpBtn];
    [helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerView).offset(-10);
        make.top.equalTo(headerView).offset(6);
        make.width.height.mas_equalTo(34);
    }];
    
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanBtn setImage:[UIImage imageNamed:@"new_add_scan"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:scanBtn];
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(helpBtn.mas_left).offset(-10);
        make.top.width.height.equalTo(helpBtn);
    }];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)setupNotFoundProductUI{
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.font = [UIFont wcPfRegularFontOfSize:16];
    tipLab.textColor = [UIColor blackColor];
    tipLab.text = NSLocalizedString(@"current_bluetooth_disabled", @"当前蓝牙适配器不可用");
    [self addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(16.8);
        make.centerY.equalTo(self).offset(-3.25);
    }];
    
    UIImageView *loadView = [[UIImageView alloc] init];
    loadView.image = [UIImage imageNamed:@"new_add_warn"];
    [self addSubview:loadView];
    [loadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tipLab);
        make.right.equalTo(tipLab.mas_left).offset(-9.8);
        make.width.height.mas_equalTo(23.5);
    }];

    UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [helpBtn setImage:[UIImage imageNamed:@"new_add_help"] forState:UIControlStateNormal];
    [helpBtn addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:helpBtn];
    [helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(6.5);
        make.width.height.mas_equalTo(34);
    }];

    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanBtn setImage:[UIImage imageNamed:@"new_add_scan"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:scanBtn];
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(helpBtn.mas_left).offset(-10);
        make.top.width.height.equalTo(helpBtn);
    }];

    UIButton *retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [retryBtn setTitle:NSLocalizedString(@"scanning_retry", @"重试") forState:UIControlStateNormal];
    [retryBtn setTitleColor:kRGBColor(0, 110, 255) forState:UIControlStateNormal];
    retryBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [retryBtn addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:retryBtn];
    [retryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLab.mas_bottom);
        make.centerX.equalTo(self).offset(-0.75);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(34);
    }];
}

#pragma mark - event
- (void)help{
    WCLog(@"帮助");
    if (self.helpAction) {
        self.helpAction();
    }
}

- (void)scan{
    WCLog(@"扫码");
    if (self.scanAction) {
        self.scanAction();
    }
}

- (void)retry{
    WCLog(@"重试");
    if (self.retryAction) {
        self.retryAction();
    }
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;//self.productArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTProductTableViewCell *cell = [TIoTProductTableViewCell cellWithTableView:tableView];
    cell.connectEvent = ^{
        
    };
//    cell.dic = self.productArr[indexPath.row];
    return cell;
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 54;
        _tableView.sectionHeaderHeight = 45.5;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (void)setStatus:(DiscoverDeviceStatus)status {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (status == DiscoverDeviceStatusDiscovering) {
        [self setupDiscoveringUI];
    } else if (status == DiscoverDeviceStatusDiscovered) {
        [self setupDiscoveredProductUI];
    } else {
        [self setupNotFoundProductUI];
    }
}

@end
