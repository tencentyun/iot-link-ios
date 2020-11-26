//
//  TIoTChooseClickValueView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTChooseClickValueView.h"
#import "UIView+XDPExtension.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTChooseClickValueCell.h"
#import "TIoTIntelligentBottomActionView.h"

@interface TIoTChooseClickValueView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *viewTitle;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong)  NSString *value;
@end

@implementation TIoTChooseClickValueView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViewUI];
    }
    return self;
}

- (void)setupSubViewUI {
    CGFloat kBottomViewHeight = 56;
    CGFloat kViewHeight = 236 + kBottomViewHeight;
    CGFloat kTopViewHeight = 48;
    
    [self addSubview:self.backMaskView];
    [self.backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    [self.backMaskView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.backMaskView);
        make.height.mas_equalTo(kViewHeight);
    }];
    
    [self changeViewRectConnerWithView:self.contentView withRect:CGRectMake(0, 0, kScreenWidth, kViewHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    
    [self.contentView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.height.mas_equalTo(kTopViewHeight);
    }];

    self.viewTitle = [[UILabel alloc]init];
    [self.viewTitle setLabelFormateTitle:@"" font:[UIFont wcPfMediumFontOfSize:16] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.topView addSubview:self.viewTitle];
    [self.viewTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.topView);
    }];
    
    UIView *slideLine = [[UIView alloc]init];
    slideLine.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];
    [self.contentView addSubview:slideLine];
    [slideLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    [self.contentView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(slideLine.mas_bottom).offset(20);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kBottomViewHeight);
    }];
    
    [self.contentView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.backMaskView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.backMaskView);
        make.bottom.equalTo(self.contentView.mas_top);
    }];

    
}

#pragma mark - event

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
}


#pragma mark - UITableViewDelegate And UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTChooseClickValueCell *cell = [TIoTChooseClickValueCell cellWithTableView:tableView];
    cell.titleString = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        self.value = self.dataArr[indexPath.row]?:@"";
}

#pragma mark - lazy loading

- (UIView *)backMaskView {
    if (!_backMaskView) {
        _backMaskView = [[UIView alloc]init];
        _backMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    }
    return _backMaskView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 54;
    } 
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
        NSArray *keyResult = [self.model.define.mapping.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        for (int i = 0; i<keyResult.count; i++) {
            NSString *keyString = keyResult[i];
            NSString *valueString = self.model.define.mapping[keyString]?:@"";
            [_dataArr addObject:valueString];
        }
        
    }
    return _dataArr;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        __weak typeof(self)weakSelf = self;
        
        [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"save", @"保存")]];
        
        _bottomView.firstBlock = ^{
            
            [weakSelf dismissView];
        };
        
        _bottomView.secondBlock = ^{
            if (weakSelf.chooseTaskValueBlock) {
                NSString *valueString = weakSelf.value ?:@"";
                weakSelf.chooseTaskValueBlock(valueString,weakSelf.model);
            }
            
            [weakSelf dismissView];
        };
        
    }
    return _bottomView;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.viewTitle.text = self.model.name ?:@"";
}


@end
