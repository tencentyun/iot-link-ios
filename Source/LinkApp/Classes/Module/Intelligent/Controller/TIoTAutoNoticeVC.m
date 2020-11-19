//
//  TIoTAutoNoticeVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoNoticeVC.h"
#import "TIoTIntelligentBottomActionView.h"
#import "TIoTAutoNoticeCell.h"
#import "TIoTAutoIntelligentModel.h"

@interface TIoTAutoNoticeVC ()<UITableViewDelegate,UITableViewDataSource,TIoTAutoNoticeCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;
@property (nonatomic, strong) NSMutableArray *choiceNoticeArray;
@end

@implementation TIoTAutoNoticeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUISubviews];
}

- (void)setUISubviews {
    self.title = NSLocalizedString(@"auto_choice_notice", @"选择通知类型");
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
    TIoTAutoNoticeCell *cell = [TIoTAutoNoticeCell cellWithTableView:tableView];
    cell.delegate = self;
    if (self.isEdit == YES) {
        cell.isOn = self.editModel.isSwitchTuron;
    }
    return cell;
}


#pragma mark - TIoTAutoNoticeCell Delegate

- (void)switchChange:(UISwitch *_Nullable)senderSwitch {
    if ([senderSwitch isOn]) {
        NSLog(@"turn on");
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]init];
        [tempDic setValue:@(3) forKey:@"ActionType"];
        [tempDic setValue:NSLocalizedString(@"auto_notice_center", @"消息中心") forKey:@"Data"];
        [tempDic setValue:@"5" forKey:@"type"];
        [tempDic setValue:@(1) forKey:@"isSwitchTuron"];
        TIoTAutoIntelligentModel *model = [TIoTAutoIntelligentModel yy_modelWithJSON:tempDic];
        if (self.choiceNoticeArray.count != 0) {
            if (![self.choiceNoticeArray containsObject:model]) {
                [self.choiceNoticeArray addObject:model];
            }
        }else {
            [self.choiceNoticeArray addObject:model];
        }
        
    }else {
        NSLog(@"turn off");
        if (self.choiceNoticeArray.count != 0) {
            [self.choiceNoticeArray removeAllObjects];
        }
    }
}

#pragma mark - lazy loading

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithArray:@[@(1)]];
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

            if (self.isEdit == YES) {
                if (weakSelf.deleteNoticeBlcok) {
                    weakSelf.deleteNoticeBlcok(weakSelf.choiceNoticeArray);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else {
                if (weakSelf.choiceNoticeArray.count == 0) {
                    [MBProgressHUD showMessage:NSLocalizedString(@"auto_atleast_choice_notice_type", @"至少选择一种通知类型") icon:@""];
                }else {
                    if (weakSelf.addNoticeBlock) {
                        weakSelf.addNoticeBlock(weakSelf.choiceNoticeArray);
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
            
            
        };
        
    }
    return _bottomView;
}

- (NSMutableArray *)choiceNoticeArray {
    if (!_choiceNoticeArray) {
        _choiceNoticeArray = [NSMutableArray array];
    }
    return _choiceNoticeArray;
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
