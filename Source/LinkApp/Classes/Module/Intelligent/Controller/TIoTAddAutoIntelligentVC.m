//
//  TIoTAddAutoIntelligentVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAddAutoIntelligentVC.h"
#import "TIoTIntelligentBottomActionView.h"
#import "TIoTAutoIntelligentSectionTitleCell.h"
#import "TIoTAutoIntelligentConditionCell.h"
#import "TIoTIntelligentCustomCell.h"
#import "TIoTDeviceDetailTableViewCell.h"

@interface TIoTAddAutoIntelligentVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) TIoTIntelligentBottomActionView * nextButtonView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *conditionArray;
@property (nonatomic, strong) NSMutableArray *actionArray;
@end

@implementation TIoTAddAutoIntelligentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.title = NSLocalizedString(@"addAutoTask", @"添加自动智能");
    
    
    CGFloat kBottomViewHeight = 90;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale);
        }
        make.bottom.equalTo(self.view.mas_bottom).offset(-kBottomViewHeight);
    }];

    [self.view addSubview:self.nextButtonView];
    [self.nextButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
}


#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.conditionArray.count == 0) {
            return 2;
        }else {
            return 1 + self.conditionArray.count;
        }
    }else if (section == 1 ){
        if (self.actionArray.count == 0) {
            return 2;;
        }else {
            return self.actionArray.count;
        }
    }else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            TIoTAutoIntelligentSectionTitleCell *cell = [TIoTAutoIntelligentSectionTitleCell cellWithTableView:tableView];
            cell.conditionTitleString = NSLocalizedString(@"autoIntelligent_meet_condition", @"满足以下所有条件");
            return cell;
        }else {
            TIoTIntelligentCustomCell *cell = [TIoTIntelligentCustomCell cellWithTableView:tableView];
            if (self.conditionArray.count > 0) {
                cell.isHideBlankAddView = YES;
            }else {
                cell.isHideBlankAddView = NO;
                cell.blankAddTipString = NSLocalizedString(@"autoIntelligeng_addCondition", @"添加条件");
            }
            return cell;
        }
        
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            TIoTAutoIntelligentSectionTitleCell *cell = [TIoTAutoIntelligentSectionTitleCell cellWithTableView:tableView];
            cell.conditionTitleString = NSLocalizedString(@"execute_Task", @"执行以下任务");
            cell.isHideChoiceConditionButton = YES;
            return cell;
        }else {
            TIoTIntelligentCustomCell *cell = [TIoTIntelligentCustomCell cellWithTableView:tableView];
            if (self.actionArray.count > 0) {
                cell.isHideBlankAddView = YES;
            }else {
                cell.isHideBlankAddView = NO;
                cell.blankAddTipString = NSLocalizedString(@"autoIntelligeng_task", @"添加任务");
            }
            return cell;
        }
    }else {
        TIoTDeviceDetailTableViewCell *cell = [TIoTDeviceDetailTableViewCell cellWithTableView:tableView];
        cell.isAddTimePriod = YES;
        cell.timePriodNumFont = [UIFont wcPfRegularFontOfSize:14];
        cell.dic = @{@"title":NSLocalizedString(@"auto_effective_time_period", @"生效时间段"),@"value":@"显示选择时间段",@"needArrow":@"1"};
        return cell;
    }
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat kFirstRowHeight = 38;
    CGFloat kRowHeight = 96;
    CGFloat kTimeSegmentHeight = 64;
    
    if (indexPath.section == 2) {
        return kTimeSegmentHeight;
    }else {
        if (indexPath.row == 0) {
            return kFirstRowHeight;
        }else {
            return kRowHeight;
        }
    }
}

#pragma mark - lazy loading

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    }
    return _tableView;
}

#pragma mark - lazy loading
- (NSMutableArray *)conditionArray {
    if (!_conditionArray) {
        _conditionArray = [NSMutableArray array];
    }
    return _conditionArray;
}

- (NSMutableArray *)actionArray {
    if (!_actionArray) {
        _actionArray = [NSMutableArray array];
    }
    return _actionArray;
}

- (TIoTIntelligentBottomActionView *)nextButtonView {
    if (!_nextButtonView) {
        _nextButtonView = [[TIoTIntelligentBottomActionView alloc]init];
        _nextButtonView.backgroundColor = [UIColor whiteColor];
        [_nextButtonView bottomViewType:IntelligentBottomViewTypeSingle withTitleArray:@[NSLocalizedString(@"next", @"下一步")]];
        __weak typeof(self)weakSelf = self;
        _nextButtonView.confirmBlock = ^{
#warning 跳转前需要先移除弹框
            
        };
    }
    return _nextButtonView;
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
