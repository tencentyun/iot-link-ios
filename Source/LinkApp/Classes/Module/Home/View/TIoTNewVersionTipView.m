//
//  TIoTNewVersionTipView.m
//  LinkApp
//
//  Created by Sun on 2020/8/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTNewVersionTipView.h"

@interface TIoTNewVersionTipView () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

/// 背景视图
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UITableView *tableView;
/// 版本提示数据
@property (nonatomic, strong) NSArray *contentsArray;

@property (nonatomic, assign) CGFloat totalContentHeight;
/// 版本更新数据
@property (nonatomic, strong) NSDictionary *versionInfo;

@property (nonatomic, strong) UITapGestureRecognizer *deepTap;

@end

@implementation TIoTNewVersionTipView

- (instancetype)initWithVersionInfo:(NSDictionary *)versionInfo {
    
    self = [super init];
    if (self) {
        _versionInfo = versionInfo;
        [self addGestureRecognizer:self.deepTap];
        self.userInteractionEnabled = YES;
        [self setupUIWithVersionInfo:versionInfo];
        self.backgroundColor = [UIColor colorWithWhite:.0f alpha:0.6f];
    }
    return self;
}

- (void)setupUIWithVersionInfo:(NSDictionary *)versionInfo {
    [self combinationDataDic];
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.cornerRadius = 4.0f;
    self.bgView.layer.masksToBounds = YES;
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.equalTo(self).offset(47.5 * kScreenAllWidthScale);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont wcPfBoldFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [versionInfo objectForKey:@"Title"];
    [self.bgView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(20);
        make.centerX.equalTo(self.bgView);
        make.height.mas_equalTo(64);
    }];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.bgView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self.bgView).offset(20);
        make.centerX.equalTo(self.bgView);
        if (self.totalContentHeight  == 0) {
            make.height.mas_greaterThanOrEqualTo(30);
        } else if (self.totalContentHeight < 158) {
            make.height.mas_equalTo(self.totalContentHeight);
        } else {
            make.height.mas_lessThanOrEqualTo(158);
        }
    }];
    
    UIView *paramView = [[UIView alloc] init];
    paramView.backgroundColor = kRGBColor(242, 242, 242);
    [self.bgView addSubview:paramView];
    [paramView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(10);
        make.left.equalTo(self.bgView).offset(20);
        make.centerX.equalTo(self.bgView);
        make.height.mas_equalTo(84);
    }];
    
    UILabel *versionNumLabel = [[UILabel alloc] init];
    versionNumLabel.textColor = kRGBColor(136, 136, 136);
    versionNumLabel.font = [UIFont wcPfRegularFontOfSize:14];
    versionNumLabel.text = [NSString stringWithFormat:@"版本号：V%@", [versionInfo objectForKey:@"AppVersion"]];
    [paramView addSubview:versionNumLabel];
    [versionNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(paramView).offset(9);
        make.left.equalTo(paramView).offset(12);
    }];
    
    UILabel *packageSizeLabel = [[UILabel alloc] init];
    packageSizeLabel.textColor = kRGBColor(136, 136, 136);
    packageSizeLabel.font = [UIFont wcPfRegularFontOfSize:14];
    packageSizeLabel.text = [NSString stringWithFormat:@"安装包大小：%.2fM", [[versionInfo objectForKey:@"PackageSize"] floatValue]];
    [paramView addSubview:packageSizeLabel];
    [packageSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(versionNumLabel.mas_bottom).offset(4);
        make.left.equalTo(versionNumLabel);
    }];
    
    UILabel *releaseTimeLabel = [[UILabel alloc] init];
    releaseTimeLabel.textColor = kRGBColor(136, 136, 136);
    releaseTimeLabel.font = [UIFont wcPfRegularFontOfSize:14];
    releaseTimeLabel.text = [NSString stringWithFormat:@"发布时间：%@", [NSString convertTimestampToTime:versionInfo[@"ReleaseTime"] byDateFormat:@"yyyy/MM/dd"]];
    [paramView addSubview:releaseTimeLabel];
    [releaseTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(packageSizeLabel.mas_bottom).offset(4);
        make.left.equalTo(versionNumLabel);
    }];
    
    UIView *line1View = [[UIView alloc] init];
    line1View.backgroundColor = kRGBColor(229, 229, 229);
    [self.bgView addSubview:line1View];
    [line1View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView);
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(paramView.mas_bottom).offset(30);
        make.height.mas_equalTo(0.5);
    }];
    
    UIView *line2View = [[UIView alloc] init];
    line2View.backgroundColor = kRGBColor(229, 229, 229);
    [self.bgView addSubview:line2View];
    [line2View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1View.mas_bottom);
        make.centerX.equalTo(self.bgView);
        make.width.mas_equalTo(0.5);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *nextTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextTimeButton setTitle:@"下次再说" forState:UIControlStateNormal];
    [nextTimeButton setTitleColor:kRGBColor(136, 136, 136) forState:UIControlStateNormal];
    nextTimeButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:18];
    [nextTimeButton addTarget:self action:@selector(nextTimeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:nextTimeButton];
    [nextTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1View.mas_bottom);
        make.left.equalTo(self.bgView);
        make.right.equalTo(line2View.mas_left);
        make.height.equalTo(line2View);
    }];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:@"立即升级" forState:UIControlStateNormal];
    [confirmButton setTitleColor:kMainColor forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:18];
    [confirmButton addTarget:self action:@selector(confirmClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:confirmButton];
    if ([[versionInfo objectForKey:@"UpgradeType"] integerValue] == 1) {//强制升级
        line2View.hidden = YES;
        nextTimeButton.hidden = YES;
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1View.mas_bottom);
            make.left.right.equalTo(self.bgView);
            make.height.mas_equalTo(50);
            make.bottom.equalTo(self.bgView);
        }];
        self.deepTap.enabled = NO;
    } else {
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1View.mas_bottom);
            make.right.equalTo(self.bgView);
            make.left.equalTo(line2View.mas_right);
            make.height.equalTo(line2View);
            make.bottom.equalTo(self.bgView);
        }];
    }
}

#pragma mark eventResponse

- (void)nextTimeClick:(UIButton *)sender {
    [self removeFromSuperview];
}

- (void)confirmClick:(UIButton *)sender {
    if ([[_versionInfo objectForKey:@"UpgradeType"] integerValue] == 1) {//强制升级
    } else {
        [self removeFromSuperview];
    }
    NSString *url = [_versionInfo objectForKey:@"DownloadURL"];
    if (url && url.length) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        return;
    }
    NSInteger channel = [[_versionInfo objectForKey:@"Channel"] integerValue];
    if (channel == 1) { //如果是channel来源是APP Store
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/cn/app/id1517576629?mt=8"]];
    } else if (channel == 0) { //如果是channel来源是testFlight
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://testflight.apple.com/join/QBK6YYqw"]];
    }
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
    return _contentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"TIoTNewVersionTipCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic = _contentsArray[indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"text"];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont wcPfRegularFontOfSize:14];
    cell.textLabel.textColor = kRGBColor(136, 136, 136);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _contentsArray[indexPath.row];
    CGFloat textHeight = [[dic objectForKey:@"rowHeight"] floatValue];
    return textHeight;
}

#pragma mark setter or getter

- (void)combinationDataDic {
    NSString *content = [_versionInfo objectForKey:@"Content"];
    NSArray *arr = [content componentsSeparatedByString:@"\n"];
    NSMutableArray *mArr = [NSMutableArray array];
    CGFloat totalContentHeight = 0;
    for (NSString *text in arr) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:text forKey:@"text"];
        CGFloat textHeight = [text boundingRectWithSize:CGSizeMake(kScreenWidth - 95 * kScreenAllWidthScale - 40, kScreenHeight)
           options:NSStringDrawingUsesLineFragmentOrigin
        attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}
           context:nil].size.height;
        [dic setValue:@(textHeight + 18) forKey:@"rowHeight"];
        [mArr addObject:[dic copy]];
        totalContentHeight = totalContentHeight + (textHeight + 18);
    }
    _contentsArray = [NSArray arrayWithArray:mArr];
    _totalContentHeight = totalContentHeight;
}

- (UITapGestureRecognizer *)deepTap {
    if (!_deepTap) {
        _deepTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveTapClick:)];
        _deepTap.delegate = self;
    }
    return _deepTap;
}

@end
