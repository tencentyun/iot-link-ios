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
#import "TIoTComplementIntelligentVC.h"
#import "TIoTIntelligentVC.h"
#import "TIoTDeviceSettingVC.h"

@interface TIoTAddManualIntelligentVC ()<UITableViewDelegate,UITableViewDataSource,TIoTChooseDelayTimeVCDelegate>
@property  (nonatomic, strong) UIImageView *noManualTaskImageView;
@property (nonatomic, strong) UILabel *noManualTaskTipLabel;
@property (nonatomic, strong) UIButton *addManualTaskButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *customHeaderView;
@property (nonatomic, strong) TIoTIntelligentBottomActionView * nextButtonView;
@property (nonatomic, strong) TIoTCustomSheetView *customSheet;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger selectedDelayIndex;
@property (nonatomic, strong) NSMutableArray *delayTimeStringArray;
@end

@implementation TIoTAddManualIntelligentVC

- (void)nav_customBack {

    if (self.dataArray.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        TIoTAddManualIntelligentVC *vc = [self findViewController:NSStringFromClass([TIoTAddManualIntelligentVC class])];
        if (vc) {
            // 找到需要返回的控制器的处理方式
            [self.navigationController popToViewController:vc animated:YES];
        }else{
            // 没找到需要返回的控制器的处理方式

        }
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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
 
    [self loadData];
}

- (void)loadData {

#warning 不同类型需要继续添加
    if (self.actionType == IntelligentActioinTypeManual) {
        if (self.taskArray.count != 0 || self.taskArray != nil) {
            self.tableView.hidden = NO;
            self.nextButtonView.hidden = NO;
            for (TIoTPropertiesModel *model in self.taskArray) {
                [self.dataArray insertObject:model atIndex:0];
            }
            [self.tableView reloadData];
        }else {
            if (self.dataArray.count == 0) {
                self.tableView.hidden = YES;
                self.nextButtonView.hidden = YES;
            }else {
                [self.tableView reloadData];
            }
        }
    }else if (self.actionType == IntelligentActioinTypeDelay){
        if (![NSString isNullOrNilWithObject:self.delayTimeString]) {
            self.tableView.hidden = NO;
            self.nextButtonView.hidden = NO;
            [self.dataArray addObject:self.delayTimeString];
            [self.tableView reloadData];
        }else {
            if (self.dataArray.count == 0) {
                self.tableView.hidden = YES;
                self.nextButtonView.hidden = YES;
            }else {
                self.tableView.hidden = NO;
                self.nextButtonView.hidden = NO;
                [self.tableView reloadData];
            }
        }
    }
    
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
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTIntelligentCustomCell *intelligentCell = [TIoTIntelligentCustomCell cellWithTableView:tableView];
    if (self.actionType == IntelligentActioinTypeManual) {
        intelligentCell.model = self.dataArray[indexPath.row];
        intelligentCell.subTitleString = self.valueArray[indexPath.row];
        intelligentCell.productModel = self.productModel;
    }else if (self.actionType == IntelligentActioinTypeDelay) {
        intelligentCell.delayTimeString = self.dataArray[indexPath.row];
    }
    
    return intelligentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
#warning 后期添加判断类型 暂时先如下处理
    if (self.actionType == IntelligentActioinTypeManual) {
        TIoTDeviceSettingVC *deviceSettingVC = [[TIoTDeviceSettingVC alloc]init];
        deviceSettingVC.isEdited = YES;
        deviceSettingVC.editedModel = self.dataArray[indexPath.row];
        deviceSettingVC.productModel = self.productModel;
        deviceSettingVC.valueString = self.valueArray[indexPath.row];
        [self.navigationController pushViewController:deviceSettingVC animated:YES];
    }else if (self.actionType == IntelligentActioinTypeDelay) {
        TIoTChooseDelayTimeVC *chooseDelayTimeVC = [[TIoTChooseDelayTimeVC alloc]init];
        chooseDelayTimeVC.isEditing = YES;
        chooseDelayTimeVC.delegate = self;
        self.selectedDelayIndex = indexPath.row;
        [self.navigationController pushViewController:chooseDelayTimeVC animated:YES];
    }
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
        //只要实现这个方法，就实现了默认滑动删
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            // 删除数据
            [self deleteSelectIndexPath:indexPath];
        }
}

//MAEK: 删除按钮文案
//-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//          return @"删除";
//}

- (void)deleteSelectIndexPath:(NSIndexPath *)indexPath {
    [self.dataArray removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
    if (self.dataArray.count == 0) {
        self.tableView.hidden = YES;
        self.nextButtonView.hidden = YES;
        
    }
}

//- (void)_rightBarButtonItemDidClicked:(UIButton *)sender
//{
//        sender.selected = !sender.isSelected;
//        if (sender.isSelected) {
//
//            // 这个是fix掉:当你左滑删除的时候，再点击右上角编辑按钮， cell上的删除按钮不会消失掉的bug。且必须放在 设置tableView.editing = YES;的前面。
//            [self.tableView reloadData];
//
//            // 取消
//            [self.tableView setEditing:YES animated:NO];
//        }else{
//            // 编辑
//            [self.tableView setEditing:NO animated:NO];
//        }
//}

#pragma mark - TIoTChooseDelayTimeVCDelegate
- (void)changeDelayTimeString:(NSString *)timeString {
    [self.dataArray replaceObjectAtIndex:self.selectedDelayIndex withObject:timeString];
    [self.delayTimeStringArray replaceObjectAtIndex:self.selectedDelayIndex withObject:timeString];
    
    NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:self.selectedDelayIndex inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[selectedPath] withRowAnimation:UITableViewRowAnimationNone];
    
}


#pragma mark - event

- (id)findViewController:(NSString*)className{
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:NSClassFromString(className)]) {
            return viewController;
        }
    }
    return nil;
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
        delayTimeVC.addDelayTimeBlcok = ^(NSString * _Nonnull timeString) {
            weakSelf.actionType = IntelligentActioinTypeDelay;
            [weakSelf.dataArray addObject:timeString];
            [weakSelf.delayTimeStringArray addObject:timeString];
            [weakSelf loadData];
        };
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
        _tableView.allowsMultipleSelection = NO;
        _tableView.allowsSelectionDuringEditing = NO;
        _tableView.allowsMultipleSelectionDuringEditing = NO;
//        [_tableView setEditing:YES animated:NO];
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
            complementVC.productModel = weakSelf.productModel;
            complementVC.actionArray = weakSelf.taskArray;
            complementVC.valueArray = weakSelf.valueArray;
            if (weakSelf.actionType == IntelligentActioinTypeManual) {
                complementVC.sceneActioinType = SceneActioinTypeManual;
            }else if (weakSelf.actionType == IntelligentActioinTypeDelay) {
                complementVC.sceneActioinType = SceneActioinTypeDelay;
            }else if (weakSelf.actionType == IntelligentActioinTypeNotice) {
                complementVC.sceneActioinType = SceneActioinTypeNotice;
            }else if (weakSelf.actionType == IntelligentActioinTypeTimer) {
                complementVC.sceneActioinType = SceneActioinTypeTimer;
            }
            complementVC.delayTimeArray = weakSelf.delayTimeStringArray;
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

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (NSMutableArray *)delayTimeStringArray {
    if (!_delayTimeStringArray) {
        _delayTimeStringArray = [NSMutableArray array];
    }
    return _delayTimeStringArray;
}
@end
