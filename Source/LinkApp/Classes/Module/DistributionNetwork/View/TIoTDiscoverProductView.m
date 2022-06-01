//
//  WCDiscoverProductView.m
//  TenextCloud
//
//

#import "TIoTDiscoverProductView.h"
#import "TIoTProductTableViewCell.h"

@interface TIoTDiscoverProductView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *productArr;
@property (nonatomic, strong) UIView *tableFooterView;
@property (nonatomic, strong) UIButton *discoverHelpBtn;
@property (nonatomic, strong) UIButton *discoverScanBtn;
@property (nonatomic, strong) UIButton *discoverHeaderHelpBtn;
@property (nonatomic, strong) UIButton *discoverHeaderScanBtn;
@property (nonatomic, strong) UIButton *notFoundHelpBtn;
@property (nonatomic, strong) UIButton *notFoundScanBtn;
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
    
    self.discoverHelpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.discoverHelpBtn setImage:[UIImage imageNamed:@"new_add_help"] forState:UIControlStateNormal];
    [self.discoverHelpBtn addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.discoverHelpBtn];
    [self.discoverHelpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(6.5);
        make.width.height.mas_equalTo(34);
    }];
    
    self.discoverScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.discoverScanBtn setImage:[UIImage imageNamed:@"new_add_scan"] forState:UIControlStateNormal];
    [self.discoverScanBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.discoverScanBtn];
    [self.discoverScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.discoverHelpBtn.mas_left).offset(-10);
        make.top.width.height.equalTo(self.discoverHelpBtn);
    }];
}

- (void)setupDiscoveredProductUI{
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addTableHeaderView];
}

- (void)changeTableFooterView:(UIView *)view {
    self.tableFooterView = view;
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
    
    self.discoverHeaderHelpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.discoverHeaderHelpBtn setImage:[UIImage imageNamed:@"new_add_help"] forState:UIControlStateNormal];
    [self.discoverHeaderHelpBtn addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.discoverHeaderHelpBtn];
    [self.discoverHeaderHelpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerView).offset(-10);
        make.top.equalTo(headerView).offset(6);
        make.width.height.mas_equalTo(34);
    }];
    
    self.discoverHeaderScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.discoverHeaderScanBtn setImage:[UIImage imageNamed:@"new_add_scan"] forState:UIControlStateNormal];
    [self.discoverHeaderScanBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.discoverHeaderScanBtn];
    [self.discoverHeaderScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.discoverHeaderHelpBtn.mas_left).offset(-10);
        make.top.width.height.equalTo(self.discoverHeaderHelpBtn);
    }];
    
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = self.tableFooterView;
}

- (void)setupNotFoundProductUI{
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.font = [UIFont wcPfRegularFontOfSize:14];
    tipLab.textColor = [UIColor blackColor];
    tipLab.numberOfLines = 0;
    tipLab.text = NSLocalizedString(@"current_bluetooth_disabled", @"当前蓝牙适配器不可用");
    [self addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(16.8);
        make.centerY.equalTo(self).offset(-3.25);
        make.left.equalTo(self.mas_left).offset(72);
        make.right.equalTo(self.mas_right).offset(-40);
    }];
    
    UIImageView *loadView = [[UIImageView alloc] init];
    loadView.image = [UIImage imageNamed:@"new_add_warn"];
    [self addSubview:loadView];
    [loadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tipLab);
        make.right.equalTo(tipLab.mas_left).offset(-9.8);
        make.width.height.mas_equalTo(23.5);
    }];

    self.notFoundHelpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.notFoundHelpBtn setImage:[UIImage imageNamed:@"new_add_help"] forState:UIControlStateNormal];
    [self.notFoundHelpBtn addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.notFoundHelpBtn];
    [self.notFoundHelpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(6.5);
        make.width.height.mas_equalTo(34);
    }];

    self.notFoundScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.notFoundScanBtn setImage:[UIImage imageNamed:@"new_add_scan"] forState:UIControlStateNormal];
    [self.notFoundScanBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.notFoundScanBtn];
    [self.notFoundScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.notFoundHelpBtn.mas_left).offset(-10);
        make.top.width.height.equalTo(self.notFoundHelpBtn);
    }];

    UIButton *retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [retryBtn setTitle:NSLocalizedString(@"scanning_retry", @"重试") forState:UIControlStateNormal];
    [retryBtn setTitleColor:[UIColor colorWithHexString:kAddDeviceSignHexColor] forState:UIControlStateNormal];
    retryBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:12];
    [retryBtn addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:retryBtn];
    [retryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLab.mas_bottom);
//        make.centerX.equalTo(self).offset(-0.75);
        CGFloat offsetX = -14;
        if (!LanguageIsEnglish) {
            offsetX = -16;
        }
        make.left.equalTo(tipLab.mas_left).offset(offsetX);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(34);
    }];
}

#pragma mark - event
- (void)help{
    DDLogVerbose(@"帮助");
    if (self.helpAction) {
        self.helpAction();
    }
}

- (void)scan{
    DDLogVerbose(@"扫码");
    if (self.scanAction) {
        self.scanAction();
    }
}

- (void)retry{
    DDLogVerbose(@"重试");
    if (self.retryAction) {
        self.retryAction();
    }
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;//self.productArr.count;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

- (void)hideScanAction {
    self.discoverScanBtn.hidden = YES;
    self.discoverHeaderScanBtn.hidden = YES;
    self.notFoundScanBtn.hidden = YES;
    
}

- (void)hideHelpAction {
    self.discoverHelpBtn.hidden = YES;
    self.discoverHeaderHelpBtn.hidden = YES;
    self.notFoundHelpBtn.hidden = YES;
}
@end
