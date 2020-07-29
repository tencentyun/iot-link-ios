//
//  TIoTWIFIListView.m
//  LinkApp
//
//  Created by Sun on 2020/7/29.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTWIFIListView.h"
#import "TIoTWIFITableViewCell.h"

@interface TIoTWIFIListView () <UITableViewDelegate, UITableViewDataSource>

/// 背景视图
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIButton *refreshButton;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSArray *wifiArray;

@end

@implementation TIoTWIFIListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.wifiArray = @[@"tcloud1", @"tcloud2", @"tcloud3", @"tcloud4", @"tcloud5"];
        [self setupUI];
        self.backgroundColor = [UIColor colorWithWhite:.0f alpha:0.6f];
    }
    return self;
}

- (void)setupUI{
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(294);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.textColor = [UIColor blackColor];
    tipLabel.font = [UIFont wcPfRegularFontOfSize:14];
    tipLabel.backgroundColor = [UIColor whiteColor];
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
    [self.bgView addSubview:self.refreshButton];
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.height.equalTo(tipLabel);
        make.width.mas_equalTo(68);
    }];
    
//    self.tableView = [[UITableView alloc] init];
//    self.tableView.backgroundColor = [UIColor clearColor];
//    self.tableView.rowHeight = 56;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    [self.bgView addSubview:self.tableView];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(tipLabel.mas_bottom);
//        make.left.right.equalTo(self.bgView);
//        make.height.mas_equalTo(166);
//    }];
    
    
    UIView *unGrantedView = [[UIView alloc] init];
    unGrantedView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:unGrantedView];
    [unGrantedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLabel.mas_bottom);
        make.left.right.equalTo(self.bgView);
        make.height.mas_equalTo(166);
    }];
    
    UIButton *accessWifiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [accessWifiButton setImage:[UIImage imageNamed:@"new_distri_info"] forState:UIControlStateNormal];
    [accessWifiButton setTitle:@"点击获取WiFi列表" forState:UIControlStateNormal];
    [accessWifiButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    accessWifiButton.titleLabel.font = [UIFont wcPfMediumFontOfSize:17];
    [accessWifiButton addTarget:self action:@selector(accessWifiClick:) forControlEvents:UIControlEventTouchUpInside];
    [unGrantedView addSubview:accessWifiButton];
    [accessWifiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(unGrantedView).offset(27);
        make.centerX.equalTo(unGrantedView);
        make.width.mas_equalTo(272);
        make.height.mas_equalTo(24);
    }];
    
    UILabel *describeLabel = [[UILabel alloc] init];
    describeLabel.textColor = [UIColor blackColor];
    describeLabel.font = [UIFont wcPfRegularFontOfSize:17];
    describeLabel.textAlignment = NSTextAlignmentCenter;
    describeLabel.text = @"iOS用户进入到无线局域网页面等待\nWiFi列表刷新后返回APP.";
    describeLabel.numberOfLines = 0;
    [unGrantedView addSubview:describeLabel];
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
}

//- (UIView *)setupPermissionNotGrantedUI {
//}

#pragma mark eventResponse

- (void)refreshClick:(UIButton *)sender {
    
}

- (void)accessWifiClick:(UIButton *)sender {
    
}

- (void)cancelClick:(UIButton *)sender {
    [self removeFromSuperview];
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.wifiArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTWIFITableViewCell *cell = [TIoTWIFITableViewCell cellWithTableView:tableView];
//    cell.dic = self.categoryArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
