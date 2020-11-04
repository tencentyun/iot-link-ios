//
//  TIoTAddManualIntelligentVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAddManualIntelligentVC.h"
#import "TIoTCustomSheetView.h"
#import "TIoTChooseDelayTimeVC.h"
#import "TIoTChooseIntelligentDeviceVC.h"
#import "TIoTIntelligentCustomCell.h"
#import "TIoTIntelligentBottomActionView.h"
#import "TIoTChooseDelayTimeVC.h"
#import "TIoTComplementIntelligentVC.h"

@interface TIoTAddManualIntelligentVC ()<UITableViewDelegate,UITableViewDataSource>
@property  (nonatomic, strong) UIImageView *noManualTaskImageView;
@property (nonatomic, strong) UILabel *noManualTaskTipLabel;
@property (nonatomic, strong) UIButton *addManualTaskButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *customHeaderView;
@property (nonatomic, strong) TIoTIntelligentBottomActionView * nextButtonView;
@property (nonatomic, strong) TIoTCustomSheetView *customSheet;
@end

@implementation TIoTAddManualIntelligentVC

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadTaskList];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {

    self.title = NSLocalizedString(@"addManualTask", @"添加手动智能");
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self addEmptyIntelligentDeviceTipView];
    
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


- (void)addEmptyIntelligentDeviceTipView {
    [self.view addSubview:self.noManualTaskImageView];
    [self.noManualTaskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            CGFloat kHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
            make.centerY.equalTo(self.view.mas_centerY).offset(-kHeight);
        } else {
            // Fallback on earlier versions
        }
        make.left.equalTo(self.view).offset(60);
        make.right.equalTo(self.view).offset(-60);
        make.height.mas_equalTo(160);
    }];
    
    [self.view addSubview:self.noManualTaskTipLabel];
    [self.noManualTaskTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noManualTaskImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    [self.view addSubview:self.addManualTaskButton];
    [self.addManualTaskButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noManualTaskTipLabel.mas_bottom).offset(20);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(36);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDelegate And TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTIntelligentCustomCell *intelligentCell = [TIoTIntelligentCustomCell cellWithTableView:tableView];
    return intelligentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TIoTChooseDelayTimeVC *chooseDelayTimeVC = [[TIoTChooseDelayTimeVC alloc]init];
    chooseDelayTimeVC.isEditing = YES;
    [self.navigationController pushViewController:chooseDelayTimeVC animated:YES];
}

#pragma mark - event
- (void)loadTaskList {
    
}

- (void)addManualTask {
    __weak typeof(self)weakSelf = self;
    self.customSheet.chooseIntelligentDeviceBlock = ^{
        TIoTChooseIntelligentDeviceVC *chooseDeviceVC = [[TIoTChooseIntelligentDeviceVC alloc]init];
        if (weakSelf.customSheet) {
            [weakSelf.customSheet removeFromSuperview];
        }
        [weakSelf.navigationController pushViewController:chooseDeviceVC animated:YES];
    };
    self.customSheet.chooseDelayTimerBlock = ^{
        TIoTChooseDelayTimeVC *delayTimeVC = [[TIoTChooseDelayTimeVC alloc]init];
        delayTimeVC.isEditing = NO;
        if (weakSelf.customSheet) {
            [weakSelf.customSheet removeFromSuperview];
        }
        [weakSelf.navigationController pushViewController:delayTimeVC animated:YES];
    };
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.customSheet];
    [self.customSheet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([UIApplication sharedApplication].delegate.window);
        make.leading.right.bottom.equalTo(weakSelf.view);
    }];
}

#pragma mark - lazy loading
- (UIImageView *)noManualTaskImageView {
    if (!_noManualTaskImageView) {
        _noManualTaskImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_noTask"]];
    }
    return _noManualTaskImageView;
}

- (UILabel *)noManualTaskTipLabel {
    if (!_noManualTaskTipLabel) {
        _noManualTaskTipLabel = [[UILabel alloc]init];
        _noManualTaskTipLabel.text = NSLocalizedString(@"current_noManualTask", @"暂无手动任务");
        _noManualTaskTipLabel.font = [UIFont wcPfRegularFontOfSize:14];
        _noManualTaskTipLabel.textColor= [UIColor colorWithHexString:@"#6C7078"];
        _noManualTaskTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noManualTaskTipLabel;
}

- (UIButton *)addManualTaskButton {
    if (!_addManualTaskButton) {
        _addManualTaskButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addManualTaskButton.layer.borderWidth = 1;
        _addManualTaskButton.layer.borderColor = [UIColor colorWithHexString:@"#0066FF"].CGColor;
        _addManualTaskButton.layer.cornerRadius = 18;
        [_addManualTaskButton setTitle:NSLocalizedString(@"addTast", @"添加任务") forState:UIControlStateNormal];
        [_addManualTaskButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        _addManualTaskButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_addManualTaskButton addTarget:self action:@selector(addManualTask) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addManualTaskButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 96;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        _tableView.tableHeaderView = self.customHeaderView;
    }
    return _tableView;
}

- (UIView *)customHeaderView {
    if (!_customHeaderView) {
        CGFloat kHeaderViewHeight = 40;
        _customHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kHeaderViewHeight)];
        _customHeaderView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        
        
        UIView *headerContentView = [[UIView alloc]init];
        headerContentView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        [_customHeaderView addSubview:headerContentView];
        [headerContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(_customHeaderView);
        }];
        
        CGFloat kPadding = 16;
        UILabel *headerTitle = [[UILabel alloc]init];
        headerTitle.text = NSLocalizedString(@"execute_Task", @"执行以下任务");
        headerTitle.font = [UIFont wcPfRegularFontOfSize:14];
        headerTitle.textColor = [UIColor colorWithHexString:kTemperatureHexColor];
        [headerContentView addSubview:headerTitle];
        [headerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerContentView.mas_left).offset(kPadding);
            make.centerY.equalTo(headerContentView);
        }];
        
        CGFloat kAddImageWidthAndHeight = 22;
        UIButton *addManualButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addManualButton.layer.cornerRadius = kAddImageWidthAndHeight/2;
        [addManualButton addTarget:self action:@selector(addManualTask) forControlEvents:UIControlEventTouchUpInside];
        [addManualButton setImage:[UIImage imageNamed:@"addManual_Intelligent"] forState:UIControlStateNormal];
        [headerContentView addSubview:addManualButton];
        [addManualButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kAddImageWidthAndHeight);
            make.width.mas_equalTo(kAddImageWidthAndHeight);
            make.right.equalTo(headerContentView.mas_right).offset(-kPadding);
            make.centerY.equalTo(headerContentView);
        }];
    }
    return _customHeaderView;
}

- (TIoTIntelligentBottomActionView *)nextButtonView {
    if (!_nextButtonView) {
        _nextButtonView = [[TIoTIntelligentBottomActionView alloc]init];
        _nextButtonView.backgroundColor = [UIColor whiteColor];
        [_nextButtonView bottomViewType:IntelligentBottomViewTypeSingle withTitleArray:@[NSLocalizedString(@"next", @"下一步")]];
        __weak typeof(self)weakSelf = self;
        _nextButtonView.confirmBlock = ^{
            if (weakSelf.customSheet) {
                [weakSelf.customSheet removeFromSuperview];
            }
            TIoTComplementIntelligentVC *complementVC = [[TIoTComplementIntelligentVC alloc]init];
            [weakSelf.navigationController pushViewController:complementVC animated:YES];
        };
    }
    return _nextButtonView;
}

- (TIoTCustomSheetView *)customSheet {
    if (!_customSheet) {
        _customSheet = [[TIoTCustomSheetView alloc]init];
    }
    return _customSheet;
}
@end
