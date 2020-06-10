//
//  WCAddActionView.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCAddActionView.h"
#import "WCAddActionTableViewCell.h"
#import "WCActionTypeTableViewCell.h"

@interface WCAddActionView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *actionTableView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *sureBtn;

@end

@implementation WCAddActionView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)dealloc{
    [HXYNotice removeListener:self];
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    [HXYNotice addActionDownListener:self reaction:@selector(addActionDown:)];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn.backgroundColor = [UIColor greenColor];
    [self addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.bottom.equalTo(self).offset(-kXDPiPhoneBottomSafeAreaHeight);
        make.width.mas_equalTo(kScreenWidth/2);
        make.height.mas_equalTo(50);
    }];
    
    self.sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sureBtn setTitle:@"确认" forState:UIControlStateNormal];
    [self.sureBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    self.sureBtn.backgroundColor = [UIColor blueColor];
    [self addSubview:self.sureBtn];
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.bottom.equalTo(self).offset(-kXDPiPhoneBottomSafeAreaHeight);
        make.width.mas_equalTo(kScreenWidth/2);
        make.height.mas_equalTo(50);
    }];
    
    [self addSubview:self.actionTableView];
    [self.actionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.equalTo(self.backBtn.mas_top);
    }];
    
    [self addTableFooterView];
}

- (void)addTableFooterView{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 70)];
    
    UIButton *addActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addActionBtn setTitle:@"添加动作" forState:UIControlStateNormal];
    [addActionBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [addActionBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:addActionBtn];
    [addActionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(footerView);
        make.top.equalTo(footerView).offset(10);
        make.height.mas_equalTo(50);
    }];
    
    self.actionTableView.tableFooterView = footerView;
}

#pragma mark eventResponse
- (void)sureClick:(id)sender{
    [self removeFromSuperview];
}

- (void)backClick:(id)sender{
    [self removeFromSuperview];
}

- (void)addAction:(id)sender{
    WCActionTypeView *typeView = [[WCActionTypeView alloc] init];
    [self addSubview:typeView];
    [typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(kScreenWidth);
        make.left.equalTo(self.mas_right);
    }];
    
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        [typeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(kScreenWidth);
            make.left.equalTo(self);
        }];
        [self layoutIfNeeded];
    }];
}

- (void)addActionDown:(id)sender{
    [self.subviews.lastObject removeFromSuperview];
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WCAddActionTableViewCell *cell = [WCAddActionTableViewCell cellWithTableView:tableView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WCActionStatusView *statusView = [[WCActionStatusView alloc] init];
    [self addSubview:statusView];
    [statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(kScreenWidth);
        make.left.equalTo(self.mas_right);
    }];
    
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        [statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(kScreenWidth);
            make.left.equalTo(self);
        }];
        [self layoutIfNeeded];
    }];
}

#pragma mark setter or getter
- (UITableView *)actionTableView{
    if (_actionTableView == nil) {
        _actionTableView = [[UITableView alloc] init];
        _actionTableView.rowHeight = 50;
        _actionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _actionTableView.delegate = self;
        _actionTableView.dataSource = self;
    }
    
    return _actionTableView;
}

@end






@interface WCActionTypeView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, copy) NSArray *dataArr;
@end

@implementation WCActionTypeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn.backgroundColor = [UIColor greenColor];
    [self addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.bottom.equalTo(self).offset(-kXDPiPhoneBottomSafeAreaHeight);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(50);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.equalTo(self.backBtn.mas_top);
    }];
}

#pragma mark eventResponse
- (void)backClick:(id)sender{
    [self removeFromSuperview];
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WCActionTypeTableViewCell *cell = [WCActionTypeTableViewCell cellWithTableView:tableView];
    cell.nameStr = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WCActionStatusView *statusView = [[WCActionStatusView alloc] init];
    [self addSubview:statusView];
    [statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(kScreenWidth);
        make.left.equalTo(self.mas_right);
    }];
    
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        [statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(kScreenWidth);
            make.left.equalTo(self);
        }];
        [self layoutIfNeeded];
    }];
 }

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.rowHeight = 50;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (NSArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = @[@"开关",@"亮度",@"颜色"];
    }
    return _dataArr;
}

@end




@interface WCActionStatusView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, copy) NSArray *dataArr;
@end

@implementation WCActionStatusView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn.backgroundColor = [UIColor greenColor];
    [self addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.bottom.equalTo(self).offset(-kXDPiPhoneBottomSafeAreaHeight);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(50);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.equalTo(self.backBtn.mas_top);
    }];
}

#pragma mark eventResponse
- (void)backClick:(id)sender{
    [self removeFromSuperview];
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WCActionTypeTableViewCell *cell = [WCActionTypeTableViewCell cellWithTableView:tableView];
    cell.nameStr = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [HXYNotice addActionDownPost];
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.rowHeight = 50;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (NSArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = @[@"关闭",@"开启"];
    }
    return _dataArr;
}

@end
