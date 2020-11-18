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
#import "UILabel+TIoTExtension.h"

#import "TIoTSettingIntelligentCell.h"
#import "TIoTSettingIntelligentImageVC.h"
#import "TIoTSettingIntelligentNameVC.h"
#import "TIoTAppEnvironment.h"
#import "TIoTAppConfig.h"

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

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITableView *complementTableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSString *sceneImageUrl;
@property (nonatomic, strong) NSString  *sceneNameString;
@end

@implementation TIoTAddManualIntelligentVC

- (void)nav_customBack {

    if (self.dataArray.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        
        TIoTIntelligentVC *vc = [self findViewController:NSStringFromClass([TIoTIntelligentVC class])];
        
        if (vc) {
            
            [self.navigationController popToViewController:vc animated:YES];
            self.navigationController.tabBarController.tabBar.hidden = NO;
        }else{
            // 没找到需要返回的控制器的处理方式
//            [self.navigationController popViewControllerAnimated:YES];

        }
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)refreshData {
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    
    if (self.isSceneDetail == YES) {
        [self loadManualSceneList];
        self.nextButtonView.hidden = NO;
    }
}

//MARK:传入的手动场景（智能主页传入）
- (void)loadManualSceneList {

    [self.dataArray removeAllObjects];
    [self.dataArr removeAllObjects];
    
    NSMutableArray *manualSceneArray = [NSMutableArray arrayWithArray:self.sceneManualDic[@"Actions"]?:@[]];
    for (int i = 0; i<manualSceneArray.count; i++) {

        NSDictionary *tempDic = [NSDictionary dictionaryWithDictionary:manualSceneArray[i]];
        NSNumber *actionTypeNum = tempDic[@"ActionType"]?:0;
        
        if ( actionTypeNum.intValue == 0) { //设备
            TIoTPropertiesModel *model = [TIoTPropertiesModel yy_modelWithJSON:tempDic];
            [self.dataArray addObject:model];
        }else if (actionTypeNum.intValue == 1){ //延时
            NSNumber *timeSecond = tempDic[@"Data"]?:0;
            NSInteger hourNum = timeSecond.intValue / (60*60);
            NSInteger minutNum = (timeSecond.intValue % (60*60))/60;
            
            NSString *timestr = @"";
            if (hourNum == 0) {
                timestr = [NSString stringWithFormat:@"%ld%@%@",(long)minutNum,NSLocalizedString(@"unit_m", @"分钟"),NSLocalizedString(@"delay_time_later", @"后")];
            }
            if (minutNum == 0) {
                timestr = [NSString stringWithFormat:@"%ld%@%@",(long)hourNum,NSLocalizedString(@"unit_h", @"小时"),NSLocalizedString(@"delay_time_later", @"后")];
            }
            
            [self.dataArray addObject:timestr];
        }
    }
    
    if (self.dataArray.count == 0) {
        self.tableView.hidden = YES;
    }else {
        self.tableView.hidden = NO;
    }
    
    self.sceneImageUrl = self.sceneManualDic[@"SceneIcon"]?:@"";
    self.sceneNameString = self.sceneManualDic[@"SceneName"]?:@"";
    [self.dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"setting_Intelligent_Image", @"智能图片"),@"value":NSLocalizedString(@"unset", @"未设置"),@"image":self.sceneImageUrl,@"needArrow":@"1"}]];
    [self.dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"setting_Intelligent_Name", @"智能名称"),@"value":self.sceneNameString,@"needArrow":@"1"}]];
    
    [self.tableView reloadData];
}

- (void)setupUI {
    
    if (self.isSceneDetail == YES) {
        self.title = NSLocalizedString(@"intelligent_manual", @"手动智能");
    }else {
        self.title = NSLocalizedString(@"addManualTask", @"添加手动智能");
    }
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self addEmptyIntelligentDeviceTipView];
    
    CGFloat KItemHeight = 48;
    
    CGFloat kTopSpace = KItemHeight *2 +15; //tableview 距离导航栏高度
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(100);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale);
        }
    }];
    
    [self.topView addSubview:self.complementTableView];
    [self.complementTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.topView);
    }];
    
    
    CGFloat kBottomViewHeight = 90;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            
            if (self.isSceneDetail == YES) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kTopSpace);
            }else {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            }
            
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
            
            if (self.isEdited == YES) {
                if (self.valueStringIndexPath < self.valueArray.count) {
                    [self.valueArray replaceObjectAtIndex:self.valueStringIndexPath withObject:self.valueString?:@""];
                }
            }else {
//                for (TIoTPropertiesModel *model in self.taskArray) {
//                    [self.dataArray insertObject:model atIndex:0];
//                }
                self.dataArray = self.taskArray;
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
            if (self.isEdited == YES) {
                if (self.valueStringIndexPath < self.valueArray.count) {
                    [self.valueArray replaceObjectAtIndex:self.valueStringIndexPath withObject:self.valueString?:@""];
                }
            }else {
                [self.dataArray addObject:self.delayTimeString];
            }
            
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

#pragma mark - 顶部view 方法 选择场景图片 或 设置名称
- (void)chooseIntelImage {
    
}

- (void)chooseIntelName {
    
}

#pragma mark - UITableViewDelegate And TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.dataArray.count;
    }else {
        return self.dataArr.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
        TIoTIntelligentCustomCell *intelligentCell = [TIoTIntelligentCustomCell cellWithTableView:tableView];
        id object = self.dataArray[indexPath.row];
        if ([object isKindOfClass:[NSString class]]) {
            intelligentCell.delayTimeString = self.dataArray[indexPath.row];
        }else  {
            intelligentCell.model = self.dataArray[indexPath.row];
            intelligentCell.subTitleString = self.valueArray[indexPath.row];
            intelligentCell.productModel = self.productModel;
        }
        return intelligentCell;
    }else {
        TIoTSettingIntelligentCell *cell = [TIoTSettingIntelligentCell cellWithTableView:tableView];
        cell.dic = [self dataArr][indexPath.row];
        return cell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
#warning 后期添加判断类型 暂时先如下处理
    
    if (tableView == self.tableView) {
        id object = self.dataArray[indexPath.row];
        if ([object isKindOfClass:[NSString class]]) {
            TIoTChooseDelayTimeVC *chooseDelayTimeVC = [[TIoTChooseDelayTimeVC alloc]init];
            chooseDelayTimeVC.isEditing = YES;
            chooseDelayTimeVC.delegate = self;
            self.selectedDelayIndex = indexPath.row;
            [self.navigationController pushViewController:chooseDelayTimeVC animated:YES];
        }else  {
            TIoTDeviceSettingVC *deviceSettingVC = [[TIoTDeviceSettingVC alloc]init];
            deviceSettingVC.isEdited = YES;
            deviceSettingVC.editedModel = self.dataArray[indexPath.row];
            deviceSettingVC.productModel = self.productModel;
            deviceSettingVC.valueString = self.valueArray[indexPath.row];
            deviceSettingVC.editActionIndex = indexPath.row;
            deviceSettingVC.valueOriginArray = [self.valueArray mutableCopy];
            deviceSettingVC.actionOriginArray = [self.dataArray mutableCopy];
            [self.navigationController pushViewController:deviceSettingVC animated:YES];
        }
    }else {
        if (indexPath.row == 0) {
            TIoTSettingIntelligentImageVC *settingImageVC = [[TIoTSettingIntelligentImageVC alloc]init];
            settingImageVC.selectedIntelligentImageBlock = ^(NSString * _Nonnull imageUrl) {
                NSMutableDictionary *dic  = self.dataArr[0];
                [dic setValue:imageUrl forKey:@"image"];
                self.sceneImageUrl = imageUrl;
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.complementTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:settingImageVC animated:YES];
            
        }else if (indexPath.row == 1) {
            TIoTSettingIntelligentNameVC *settingNameVC = [[TIoTSettingIntelligentNameVC alloc]init];
            settingNameVC.saveIntelligentNameBlock = ^(NSString * _Nonnull name) {
                NSMutableDictionary *dic  = self.dataArr[1];
                [dic setValue:name forKey:@"value"];
                self.sceneNameString = name;
                
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                [self.complementTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:settingNameVC animated:YES];
        }
        
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
- (void)changeDelayTimeString:(NSString *)timeString hour:(NSString *)hourString minuteString:(NSString *)min withAutoDelayIndex:(NSInteger)autoDelayIndex{
    [self.dataArray replaceObjectAtIndex:self.selectedDelayIndex withObject:timeString];
    [self.delayTimeStringArray replaceObjectAtIndex:self.selectedDelayIndex withObject:[NSString stringWithFormat:@"%@:%@",hourString,min]];
    NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:self.selectedDelayIndex inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[selectedPath] withRowAnimation:UITableViewRowAnimationNone];
    
    self.isEdited = YES;
#warning 刷新
    
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
    [self.customSheet sheetViewTopTitleFirstTitle:NSLocalizedString(@"manualIntelligent_deviceControl", @"设备控制") secondTitle:NSLocalizedString(@"manualIntelligent_delay", @"延时")];
    
    self.customSheet.chooseIntelligentFirstBlock = ^{
        TIoTChooseIntelligentDeviceVC *chooseDeviceVC = [[TIoTChooseIntelligentDeviceVC alloc]init];
        if (weakSelf.customSheet) {
            [weakSelf.customSheet removeFromSuperview];
            
        }
        chooseDeviceVC.actionOriginArray = [weakSelf.dataArray mutableCopy];
        if (weakSelf.valueArray == nil) {
            weakSelf.valueArray = [NSMutableArray array];
        }
        chooseDeviceVC.valueOriginArray =  [weakSelf.valueArray mutableCopy];
        chooseDeviceVC.enterType = DeviceChoiceEnterTypeManual;
        [weakSelf.navigationController pushViewController:chooseDeviceVC animated:YES];
    };
    self.customSheet.chooseIntelligentSecondBlock = ^{
        TIoTChooseDelayTimeVC *delayTimeVC = [[TIoTChooseDelayTimeVC alloc]init];
        delayTimeVC.isEditing = NO;
        if (weakSelf.customSheet) {
            [weakSelf.customSheet removeFromSuperview];
        }

        delayTimeVC.addDelayTimeBlcok = ^(NSString * _Nonnull timeString, NSString * _Nonnull hourStr, NSString * _Nonnull minu) {
            if (weakSelf.valueArray == nil) {
                weakSelf.valueArray = [NSMutableArray array];
            }
            weakSelf.actionType = IntelligentActioinTypeDelay;
            [weakSelf.dataArray insertObject:timeString atIndex:0];
            [weakSelf.delayTimeStringArray addObject:[NSString stringWithFormat:@"%@:%@",hourStr,minu]];
            [weakSelf.valueArray insertObject:[NSString stringWithFormat:@"%@:%@",hourStr,minu] atIndex:0];
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
        
        if (self.isSceneDetail == YES) {
            [_nextButtonView bottomViewType:IntelligentBottomViewTypeSingle withTitleArray:@[NSLocalizedString(@"save", @"保存")]];
            //MARK:请求修改手动场景接口
            [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
            
            NSDictionary *paramDic = @{@"Actions":self.sceneManualDic[@"Actions"],@"SceneId":self.sceneManualDic[@"SceneId"],@"SceneName":self.sceneNameString,@"SceneIcon":self.sceneImageUrl};
            [[TIoTRequestObject shared] post:AppModifyScene Param:paramDic success:^(id responseObject) {
                [MBProgressHUD dismissInView:self.view];
                [self.navigationController popViewControllerAnimated:YES];
            } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
                
            }];
            
        }else {
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
                complementVC.dataArray = weakSelf.dataArray;
                [weakSelf.navigationController pushViewController:complementVC animated:YES];
            };
        }
        
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

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;;
}

- (UITableView *)complementTableView {
    if (!_complementTableView) {
        _complementTableView = [[UITableView alloc]init];
        _complementTableView.delegate = self;
        _complementTableView.dataSource = self;
        _complementTableView.backgroundColor = [UIColor whiteColor];
        _complementTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _complementTableView.rowHeight = 48;
    }
    return _complementTableView;
}


- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
