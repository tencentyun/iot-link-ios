//
//  TIoTAutoAddManualIntelliListVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoAddManualIntelliListVC.h"
#import "TIoTAutoAddManualIntellListCell.h"
#import "TIoTIntelligentBottomActionView.h"
#import "UILabel+TIoTExtension.h"
#import "UIButton+LQRelayout.h"

@interface TIoTAutoAddManualIntelliListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *selectedAllButton;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;
@property (nonatomic, assign) BOOL isFullSelected;
@end

@implementation TIoTAutoAddManualIntelliListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isFullSelected = NO;
    [self setUISubviews];
}

- (void)setUISubviews {

    self.title = NSLocalizedString(@"auto_choice_manual_intelligent", @"选择手动智能");
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    CGFloat KTopPadding = 16;
    
    CGFloat kBottomHeight = 90;
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(kBottomHeight);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(KTopPadding);
        }else {
            make.top.equalTo(self.view.mas_bottom).offset(64*kScreenAllHeightScale + KTopPadding);
        }
    }];
    
    
}

#pragma mark - UITableViewDataDelegate UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAutoAddManualIntellListCell *cell = [TIoTAutoAddManualIntellListCell cellWithTableView:tableView];
    cell.manualNameString = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAutoAddManualIntellListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.isChoosed == YES) {
        cell.isChoosed = NO;
    }else {
        cell.isChoosed = YES;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

#pragma mark - event
- (void)chooseAll:(UIButton *)button {
    
    NSLog(@"--!!--!!!%ld",button.state);
      
    if (self.isFullSelected == NO) {
        for (int i = 0; i<self.dataArray.count; i++) {
            TIoTAutoAddManualIntellListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.isChoosed = YES;
        }
        //取消全选
        [self.selectedAllButton setTitle:NSLocalizedString(@"auto_all_cancel_selected", @"取消全选") forState:UIControlStateNormal];
    }else {
        for (int i = 0; i<self.dataArray.count; i++) {
            TIoTAutoAddManualIntellListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.isChoosed = NO;
        }
        //全选
        [self.selectedAllButton setTitle:NSLocalizedString(@"auto_all_selected", @"全选") forState:UIControlStateNormal];
    }
    self.isFullSelected = !self.isFullSelected;
    


}

#pragma mark - lazy loading

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.tableHeaderView = self.headerView;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UIView *)headerView{
    if (!_headerView) {
        
        CGFloat kHeight = 50; //header高度
        CGFloat kPadding = 16; //左右边距
        
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kHeight)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *headerLabel = [[UILabel alloc]init];
        [headerLabel setLabelFormateTitle:NSLocalizedString(@"intelligent_manual", @"手动智能") font:[UIFont wcPfSemiboldFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
        [_headerView addSubview:headerLabel];
        [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headerView.mas_left).offset(kPadding);
            make.centerY.equalTo(_headerView.mas_centerY);
        }];

        self.selectedAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.selectedAllButton setButtonFormateWithTitlt:NSLocalizedString(@"auto_all_selected", @"全选") titleColorHexString:kIntelligentMainHexColor font:[UIFont wcPfRegularFontOfSize:14]];
        
        [self.selectedAllButton addTarget:self action:@selector(chooseAll:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:self.selectedAllButton];
        [self.selectedAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_headerView.mas_right).offset(-kPadding);
        }];
        
    }
    return _headerView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        __weak typeof(self)weakSelf = self;
        [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"confirm", @"确定")]];
        
        _bottomView.firstBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        
        _bottomView.secondBlock = ^{
#warning 确定所选后 返回
//            [weakSelf judgechoiceTime];
            
        };
        
    }
    return _bottomView;
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
