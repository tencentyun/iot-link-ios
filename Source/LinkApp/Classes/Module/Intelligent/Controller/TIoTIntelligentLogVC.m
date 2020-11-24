//
//  TIoTIntelligentLogVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentLogVC.h"
#import "TIoTIntelligentLogCell.h"

@interface TIoTIntelligentLogVC ()<UITableViewDelegate,UITableViewDataSource>
@property  (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *noIntelligentLogTipLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *logDataArray;
@property (nonatomic, assign) NSInteger selectedRowHeight;
@property (nonatomic, strong) NSIndexPath *clickIndexPath;
@end

@implementation TIoTIntelligentLogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViewsUI];
}

- (void)setupViewsUI {
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self addEmptyIntelligentLogTipView];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale);
        }
    }];
}

#pragma mark - event

- (void)addEmptyIntelligentLogTipView {
    [self.view addSubview:self.emptyImageView];
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            CGFloat kHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top+10;
            make.centerY.equalTo(self.view.mas_centerY).offset(-kHeight);
        } else {
            // Fallback on earlier versions
        }
        make.left.equalTo(self.view).offset(60);
        make.right.equalTo(self.view).offset(-60);
        make.height.mas_equalTo(160);
    }];
    
    [self.view addSubview:self.noIntelligentLogTipLabel];
    [self.noIntelligentLogTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emptyImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark -UITableViewDelegate And UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTIntelligentLogCell *cell = [TIoTIntelligentLogCell cellWithTableView:tableView];
    cell.selectedIndex = indexPath;
    
//    __weak typeof(self)WeakSelf = self;
    
    cell.logDetailBlock = ^(BOOL isShow, NSIndexPath * _Nullable selectedIndex) {
        if (isShow == YES) {
//            self.tableView.rowHeight = 72 + 35;
            self.selectedRowHeight = 72 + 35;
        }else {
//            self.tableView.rowHeight = 72;
            self.selectedRowHeight = 72;
        }
        self.clickIndexPath = [NSIndexPath indexPathForRow:selectedIndex.row inSection:selectedIndex.section];
        NSLog(@"----%ld---%ld",(long)self.clickIndexPath.row,(long)self.clickIndexPath.section);
        [self.tableView reloadRowsAtIndexPaths:@[selectedIndex] withRowAnimation:UITableViewRowAnimationNone];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row == self.clickIndexPath.row) && (indexPath.section == self.clickIndexPath.section)) {
        return  self.selectedRowHeight;
    }else {
        return 72;
    }
    
}

#pragma mark - lazy loading

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 72;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_noTask"]];
    }
    return _emptyImageView;
}


- (UILabel *)noIntelligentLogTipLabel {
    if (!_noIntelligentLogTipLabel) {
        _noIntelligentLogTipLabel = [[UILabel alloc]init];
        _noIntelligentLogTipLabel.text = NSLocalizedString(@"current_no_log", @"当前暂无日志");
        _noIntelligentLogTipLabel.font = [UIFont wcPfRegularFontOfSize:14];
        _noIntelligentLogTipLabel.textColor= [UIColor colorWithHexString:@"#6C7078"];
        _noIntelligentLogTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noIntelligentLogTipLabel;
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
