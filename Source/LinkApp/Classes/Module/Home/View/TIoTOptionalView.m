//
//  WCOptionalView.m
//  TenextCloud
//
//  Created by Wp on 2020/1/16.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTOptionalView.h"
#import "TIoTChoseValueTableViewCell.h"
#import "FamilyModel.h"

@interface TIoTOptionalView()<UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) NSMutableArray *dataArr;


@property (nonatomic,assign) CGFloat currentHeight;
@end
@implementation TIoTOptionalView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = kRGBAColor(0, 0, 0, 0.7);
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    [self addGestureRecognizer:singleFingerOne];
    
    
    self.whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, -[TIoTUIProxy shareUIProxy].statusHeight - 200, kScreenWidth, [TIoTUIProxy shareUIProxy].statusHeight + 200)];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteView];
//    [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.mas_equalTo(0);
//        self.bottomLayout = make.bottom.equalTo(self.mas_top).offset(0);
//        self.heightLayout = make.height.mas_equalTo(300 + [WCUIProxy shareUIProxy].statusHeight);
//    }];
    
    
    [self.whiteView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.whiteView);
        make.top.mas_equalTo(0);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kLineColor;
    [_whiteView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom);
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(1);
        
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:NSLocalizedString(@"family_manager", @"家庭管理") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [_whiteView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom);
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
    
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.whiteView]) {
        return NO;
    }
    return YES;
}

- (void)show{
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.whiteView.frame = CGRectMake(0, 0, kScreenWidth, self.currentHeight);
    }];
    
}

- (void)hide{
    [UIView animateWithDuration:0.2 animations:^{
        self.whiteView.frame = CGRectMake(0, -self.currentHeight, kScreenWidth, self.currentHeight);
    } completion:^(BOOL finished) {
        
    }];
    [self removeFromSuperview];
    
}

- (void)done
{
    [self hide];
    if (self.doneAction) {
        self.doneAction();
    }
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTChoseValueTableViewCell *cell = [TIoTChoseValueTableViewCell cellWithTableView:tableView];
    
    FamilyModel *model = self.dataArr[indexPath.row];
    BOOL iS = [model.FamilyId isEqualToString:self.currentValue];
    [cell setTitle:model.FamilyName andSelect:iS];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self selectAt:indexPath];
}

- (void)selectAt:(NSIndexPath *)indexPath{
    
    [self hide];
    if (indexPath) {
        FamilyModel *model = self.dataArr[indexPath.row];
        self.currentValue = model.FamilyId;
        
        if (self.selected) {
            self.selected(indexPath.row);
        }
    }
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = kBgColor;
        _tableView.rowHeight = 60;
        _tableView.separatorColor = kRGBColor(242, 244, 245);
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)setTitles:(NSArray *)titles
{
    _titles = titles;
    
    CGFloat maxHeight = kScreenHeight - 200;
    CGFloat height = [TIoTUIProxy shareUIProxy].statusHeight + titles.count * 60 + 60;
    if (height > maxHeight) {
        height = maxHeight;
    }
    self.currentHeight = height;
    CGRect rect = self.whiteView.frame;
    rect.size.height = height;
    self.whiteView.frame = rect;
    
    [self.dataArr addObjectsFromArray:titles];
    [self.tableView reloadData];
}


@end
