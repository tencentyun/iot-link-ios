//
//  TIoTWIFIListView.m
//  LinkApp
//
//  Created by Sun on 2020/7/29.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTWIFIListView.h"
#import "TIoTWIFITableViewCell.h"

@interface TIoTWIFIListView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

/// 背景视图
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIButton *refreshButton;

@property (nonatomic, strong) UITableView *tableView;
///未获取到WIFI列表视图
@property (nonatomic, strong) UIView *unGrantedView;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UITapGestureRecognizer *deepTap;

@end

@implementation TIoTWIFIListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addGestureRecognizer:self.deepTap];
        self.userInteractionEnabled = YES;
        _wifiListArray = @[@"tcloud1", @"tcloud2", @"tcloud3", @"tcloud4", @"tcloud5"];
        [self setupUI];
        self.backgroundColor = [UIColor colorWithWhite:.0f alpha:0.6f];
    }
    return self;
}

- (void)setupUI{
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.cornerRadius = 15.0f;
    self.bgView.layer.masksToBounds = YES;
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(294);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.textColor = [UIColor blackColor];
    tipLabel.font = [UIFont wcPfRegularFontOfSize:14];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"建议使用2.4G WiFi";
    [self.bgView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.bgView);
        make.height.mas_equalTo(64);
    }];
    
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
    [self.refreshButton setTitleColor:kMainColor forState:UIControlStateNormal];
    self.refreshButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
    [self.refreshButton addTarget:self action:@selector(refreshClick:) forControlEvents:UIControlEventTouchUpInside];
    self.refreshButton.hidden = YES;
    [self.bgView addSubview:self.refreshButton];
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.height.equalTo(tipLabel);
        make.width.mas_equalTo(68);
    }];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 56;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    [self.bgView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLabel.mas_bottom);
        make.left.right.equalTo(self.bgView);
        make.height.mas_equalTo(166);
    }];
    
    self.unGrantedView = [[UIView alloc] init];
    self.unGrantedView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:self.unGrantedView];
    [self.unGrantedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLabel.mas_bottom);
        make.left.right.equalTo(self.bgView);
        make.height.mas_equalTo(166);
    }];
    
    UIButton *accessWifiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [accessWifiButton setImage:[UIImage imageNamed:@"new_distri_info"] forState:UIControlStateNormal];
    [accessWifiButton setTitle:@"点击获取WiFi列表" forState:UIControlStateNormal];
    [accessWifiButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -5, 0.0, 0.0)];
    [accessWifiButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    accessWifiButton.titleLabel.font = [UIFont wcPfMediumFontOfSize:17];
    [accessWifiButton addTarget:self action:@selector(accessWifiClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.unGrantedView addSubview:accessWifiButton];
    [accessWifiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.unGrantedView).offset(27);
        make.centerX.equalTo(self.unGrantedView);
        make.width.mas_equalTo(272);
        make.height.mas_equalTo(24);
    }];

    UILabel *describeLabel = [[UILabel alloc] init];
    describeLabel.textColor = [UIColor blackColor];
    describeLabel.font = [UIFont wcPfRegularFontOfSize:17];
    describeLabel.textAlignment = NSTextAlignmentCenter;
    describeLabel.text = @"iOS用户进入到无线局域网页面等待\nWiFi列表刷新后返回APP.";
    describeLabel.numberOfLines = 0;
    [self.unGrantedView addSubview:describeLabel];
    [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accessWifiButton.mas_bottom).offset(16);
        make.left.width.equalTo(accessWifiButton);
        make.height.mas_equalTo(72);
    }];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [self.cancelButton addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.bgView);
        make.height.mas_equalTo(56);
    }];
    
    UIView *grayView = [[UIView alloc] init];
    grayView.backgroundColor = kRGBColor(219, 219, 219);
    [self.bgView addSubview:grayView];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.cancelButton.mas_top);
        make.left.right.equalTo(self.bgView);
        make.height.mas_equalTo(8);
    }];
}

//- (UIView *)setupPermissionNotGrantedUI {
//}

#pragma mark eventResponse

- (void)refreshClick:(UIButton *)sender {
    if (self.refreshAction) {
        self.refreshAction();
    }
}

- (void)accessWifiClick:(UIButton *)sender {
    if (self.accessWifiAction) {
        self.accessWifiAction();
    }
}

- (void)cancelClick:(UIButton *)sender {
    [self removeFromSuperview];
}

- (void)didReceiveTapClick:(UITapGestureRecognizer *)tap {
    [self removeFromSuperview];
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([touch.view isDescendantOfView:self.bgView]){
        return NO;
    }
    return YES;
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.wifiListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTWIFITableViewCell *cell = [TIoTWIFITableViewCell cellWithTableView:tableView];
//    cell.dic = self.categoryArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark setter or getter

- (void)setWifiListArray:(NSArray *)wifiListArray {
    _wifiListArray = wifiListArray;
    [self.tableView reloadData];
    self.tableView.hidden = !_wifiListArray.count;
    self.refreshButton.hidden = !_wifiListArray.count;
    self.unGrantedView.hidden = _wifiListArray.count;
}

- (UITapGestureRecognizer *)deepTap {
    if (!_deepTap) {
        _deepTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveTapClick:)];
        _deepTap.delegate = self;
    }
    return _deepTap;
}

@end
