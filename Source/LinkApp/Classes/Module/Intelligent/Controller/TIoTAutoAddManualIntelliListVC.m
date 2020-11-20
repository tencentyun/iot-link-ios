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

@property (nonatomic, strong) NSMutableArray *choicedArray;
@property (nonatomic, assign) NSInteger isEditNum;
@end

@implementation TIoTAutoAddManualIntelliListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isFullSelected = NO;
    [self setUISubviews];
    
    [self loadData];
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

- (void)loadData {
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] post:AppGetSceneList Param:self.paramDic success:^(id responseObject) {
        
        NSMutableArray *sceneArray = [NSMutableArray arrayWithArray:responseObject[@"SceneList"]?:@[]];
        self.isEditNum = 0;
        for (int i = 0; i <sceneArray.count ; i++) {
            NSDictionary *sceneDic = sceneArray[i];
            
            NSArray *actionsArray = sceneDic[@"Actions"]?:@[];
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
            
            for (int j = 0; j < actionsArray.count; j++) {
                NSDictionary *actionDic = actionsArray[j];
                if (actionDic[@"ActionType"] != nil) {
                    [tempDic setValue:@(2) forKey:@"ActionType"];
                }
                if (actionDic[@"DeviceName"] != nil) {
                    [tempDic setValue:actionDic[@"DeviceName"] forKey:@"DeviceName"];
                }
                if (actionDic[@"ProductId"] != nil) {
                    [tempDic setValue:actionDic[@"ProductId"] forKey:@"ProductId"];
                }
                if (actionDic[@"Data"] != nil) {
                    [tempDic setValue:sceneDic[@"SceneId"] forKey:@"Data"];
                }
                if ( actionDic[@"AliasName"] != nil) {
                    [tempDic setValue:actionDic[@"AliasName"] forKey:@"AliasName"];
                }
                if (actionDic[@"IconUrl"] != nil) {
                    [tempDic setValue:actionDic[@"IconUrl"] forKey:@"IconUrl"];
                }
                
            }
            
            if (self.isEdit == YES) {
                if ([self.editModel.Data isEqualToString:sceneDic[@"SceneId"]]) {
                    self.isEditNum = i;
                }
            }
            
            if (sceneDic[@"SceneName"] != nil) {
                [tempDic setValue:sceneDic[@"SceneName"] forKey:@"sceneName"];
                [tempDic setValue:sceneDic[@"SceneName"] forKey:@"DeviceName"]; //不能这样处理，投机做法，暂时这样
            }
            
            [tempDic setValue:@"4" forKey:@"type"];
            
            TIoTAutoIntelligentModel *model = [TIoTAutoIntelligentModel yy_modelWithJSON:tempDic];
            
            [self.dataArray addObject:model];
            
        }
        
        [self.tableView reloadData];

    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

#pragma mark - UITableViewDataDelegate UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAutoAddManualIntellListCell *cell = [TIoTAutoAddManualIntellListCell cellWithTableView:tableView];
    TIoTAutoIntelligentModel *model = self.dataArray[indexPath.row];
    cell.manualNameString = model.sceneName;
    if (self.isEdit == YES) {
        cell.isEditType = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAutoAddManualIntellListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.isEdit == YES) {
        
        if (self.choicedArray.count != 0 ) {
            [self.choicedArray removeAllObjects];
            if (![self.choicedArray containsObject:self.dataArray[indexPath.row]]) {
                [self.choicedArray addObject:self.dataArray[indexPath.row]];
            }
        }else {
            [self.choicedArray addObject:self.dataArray[indexPath.row]];
        }
    }else {
        if (cell.isChoosed == YES) {
            cell.isChoosed = NO;
            if (self.choicedArray.count != 0 ) {
                [self.choicedArray removeObject:self.dataArray[indexPath.row]];
            }
            
        }else {
            cell.isChoosed = YES;
            if (self.choicedArray.count != 0) {
                if (![self.choicedArray containsObject:self.dataArray[indexPath.row]]) {
                    [self.choicedArray addObject:self.dataArray[indexPath.row]];
                }
            }else {
                [self.choicedArray addObject:self.dataArray[indexPath.row]];
            }
            
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

#pragma mark - event
- (void)chooseAll:(UIButton *)button {
      
    if (self.isFullSelected == NO) {
        for (int i = 0; i<self.dataArray.count; i++) {
            TIoTAutoAddManualIntellListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.isChoosed = YES;
        }
        //取消全选
        [self.selectedAllButton setTitle:NSLocalizedString(@"auto_all_cancel_selected", @"取消全选") forState:UIControlStateNormal];
        
        if (self.choicedArray.count == 0) {
            self.choicedArray = [self.dataArray mutableCopy];
        }else {
            [self.choicedArray removeAllObjects];
            self.choicedArray = [self.dataArray mutableCopy];
        }
        
        
    }else {
        for (int i = 0; i<self.dataArray.count; i++) {
            TIoTAutoAddManualIntellListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.isChoosed = NO;
        }
        //全选
        [self.selectedAllButton setTitle:NSLocalizedString(@"auto_all_selected", @"全选") forState:UIControlStateNormal];
        
        [self.choicedArray removeAllObjects];
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
        
        if (self.isEdit == YES) {
            self.selectedAllButton.hidden = YES;
        }
        
    }
    return _headerView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)choicedArray {
    if (!_choicedArray) {
        _choicedArray = [NSMutableArray array];
    }
    return _choicedArray;
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
//MARK:确定所选后 返回
            if (self.isEdit == YES) {
                
                if (weakSelf.updateManualSceneBlock) {
                    if (weakSelf.choicedArray.count != 0) {
                        weakSelf.updateManualSceneBlock(weakSelf.choicedArray[0], weakSelf.editIndex);
                    }else {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }
            }else {
                if (weakSelf.addManualSceneBlock) {
                    if (weakSelf.choicedArray.count != 0) {
                        weakSelf.addManualSceneBlock(weakSelf.choicedArray);
                    }else {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                    
                }
            }
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
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
