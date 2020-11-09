//
//  TIoTDeviceSettingVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTDeviceSettingVC.h"
#import "TIoTDeviceDetailTableViewCell.h"
#import "TIoTIntelligentBottomActionView.h"
#import "TIoTAddManualIntelligentVC.h"
#import "TIoTChooseClickValueView.h"
#import "TIoTChooseSliderValueView.h"

@interface TIoTDeviceSettingVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;      //task 操作自定义view
@property (nonatomic, strong) TIoTChooseClickValueView *clickValueView;         //enum和bool 点击选择view
@property (nonatomic, strong) TIoTChooseSliderValueView *sliderValueView;       //int和float 滑动选择view
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) TIoTPropertiesModel *baseModel;                  //每次选择后的model

@property (nonatomic, strong) NSMutableArray *modifiedValueArray;
@property (nonatomic, strong) NSMutableArray *modifiedModelArray;
@property (nonatomic, strong) NSMutableArray *productArray;
@property (nonatomic, strong) NSString *modifiedValue;
@property (nonatomic, strong) TIoTPropertiesModel *modifiedModel;
@end

@implementation TIoTDeviceSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    if (![NSString isNullOrNilWithObject:self.productModel.AliasName]) {
        self.title = self.productModel.AliasName;
    }else {
        self.title = self.productModel.DeviceName;
    }
    
    CGFloat kBottomViewHeight = 90;
    
    [self.view addSubview: self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-kBottomViewHeight);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
}

#pragma mark - UITableViewDelegate And UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTDeviceDetailTableViewCell *cell = [TIoTDeviceDetailTableViewCell cellWithTableView:tableView];
    cell.dic = [self dataArr][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
// MARK: - enum和bool都是开关这种样式，int和float都是亮度这种样式
    
    self.baseModel = self.modelArray[indexPath.row];
    
    if ([self.baseModel.define.type isEqualToString:@"enum"] || [self.baseModel.define.type isEqualToString:@"bool"]) {
        //点击
        __weak typeof(self) weakSelf = self;
        self.clickValueView = [[TIoTChooseClickValueView alloc]init];
        self.clickValueView.model = self.baseModel;
        
        self.clickValueView.chooseTaskValueBlock = ^(NSString * _Nonnull valueString, TIoTPropertiesModel * _Nonnull model) {
            NSMutableDictionary *tempDic = weakSelf.dataArr[indexPath.row];
            [tempDic setValue:valueString?:@"" forKey:@"value"];
            
            NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[selectedPath] withRowAnimation:UITableViewRowAnimationNone];
            
            weakSelf.modifiedValue = valueString;
            weakSelf.modifiedModel = model;
            [weakSelf.modifiedValueArray addObject:weakSelf.modifiedValue];
            [weakSelf.modifiedModelArray addObject:weakSelf.modifiedModel];
            [weakSelf.productArray addObject:weakSelf.productModel];
        };
        
        [[UIApplication sharedApplication].delegate.window addSubview:self.clickValueView];
        [self.clickValueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo([UIApplication sharedApplication].delegate.window);
            if ([TIoTUIProxy shareUIProxy].iPhoneX) {
                if (@available(iOS 11.0, *)) {
                    make.bottom.equalTo(self.view.mas_bottom).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
                }else {
                    make.bottom.equalTo(self.view.mas_bottom);
                }
            }else {
                make.bottom.equalTo(self.view.mas_bottom);
            }
        }];
        
    }else if ([self.baseModel.define.type isEqualToString:@"int"] || [self.baseModel.define.type isEqualToString:@"float"]) {
        //滑动
        
        __weak typeof(self) weakSelf = self;
        self.sliderValueView = [[TIoTChooseSliderValueView alloc]init];
        self.sliderValueView.model = self.baseModel;
        
        self.sliderValueView.sliderTaskValueBlock = ^(NSString * _Nonnull valueString, TIoTPropertiesModel * _Nonnull model) {
            NSMutableDictionary *tempDic = weakSelf.dataArr[indexPath.row];
            [tempDic setValue:valueString?:@"" forKey:@"value"];
            
            NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[selectedPath] withRowAnimation:UITableViewRowAnimationNone];
            
            weakSelf.modifiedValue = valueString;
            weakSelf.modifiedModel = model;
            [weakSelf.modifiedValueArray addObject:weakSelf.modifiedValue];
            [weakSelf.modifiedModelArray addObject:weakSelf.modifiedModel];
            [weakSelf.productArray addObject:weakSelf.productModel];
        };

        [[UIApplication sharedApplication].delegate.window addSubview:self.sliderValueView];
        [self.sliderValueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo([UIApplication sharedApplication].delegate.window);
            if ([TIoTUIProxy shareUIProxy].iPhoneX) {
                if (@available(iOS 11.0, *)) {
                    make.bottom.equalTo(self.view.mas_bottom).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
                }else {
                    make.bottom.equalTo(self.view.mas_bottom);
                }
            }else {
                make.bottom.equalTo(self.view.mas_bottom);
            }
        }];
    }
    
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

#pragma mark - lazy loading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 48;
    }
    return _tableView;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        
        __weak typeof(self)weakSelf = self;
        
        [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"save", @"保存")]];
        
        _bottomView.firstBlock = ^{
            if (weakSelf.clickValueView) {
                [weakSelf.clickValueView removeFromSuperview];
            }
            if (weakSelf.sliderValueView) {
                [weakSelf.sliderValueView removeFromSuperview];
            }
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        
        _bottomView.secondBlock = ^{
            if (weakSelf.clickValueView) {
                [weakSelf.clickValueView removeFromSuperview];
            }
            if (weakSelf.sliderValueView) {
                [weakSelf.sliderValueView removeFromSuperview];
            }
#warning 保存然后刷新手动添加智能tableView
            if ([NSString isNullOrNilWithObject:weakSelf.modifiedValue] || [NSString isNullOrNilWithObject:weakSelf.modifiedModel]) {
                
                TIoTAddManualIntelligentVC *vc = [weakSelf findViewController:NSStringFromClass([TIoTAddManualIntelligentVC class])];
                if (vc) {
                    // 找到需要返回的控制器的处理方式
                    [weakSelf.navigationController popToViewController:vc animated:YES];
                }else{
                    // 没找到需要返回的控制器的处理方式
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                
            }else {
                
                TIoTAddManualIntelligentVC *vc = [weakSelf findViewController:NSStringFromClass([TIoTAddManualIntelligentVC class])];
                if (vc) {
                    // 找到需要返回的控制器的处理方式
                    vc.taskArray = weakSelf.modifiedModelArray;
                    vc.valueArray = weakSelf.modifiedValueArray;
                    vc.productModel = weakSelf.productModel;
                    vc.actionType = IntelligentActioinTypeManual;
                    [vc refreshData];
                    [weakSelf.navigationController popToViewController:vc animated:YES];
                }else{
                    // 没找到需要返回的控制器的处理方式
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                
//                TIoTAddManualIntelligentVC *addManualTask = [[TIoTAddManualIntelligentVC alloc]init];
//                addManualTask.taskArray = weakSelf.modifiedModelArray;
//                addManualTask.valueArray = weakSelf.modifiedValueArray;
//                addManualTask.productModel = weakSelf.productModel;
//                addManualTask.actionType = IntelligentActioinTypeManual;
//                [weakSelf.navigationController pushViewController:addManualTask animated:YES];
            }
            
        };
        
    }
    return _bottomView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        
        //MARK: enum 、bool 列表选择值 ; int float 滑动选择值
        NSArray *propertiesArray = nil;
        if (self.isEdited == YES) {
            propertiesArray = @[self.editedModel];
        }else {
            propertiesArray = [NSArray arrayWithArray:self.templateModel.properties];
        }
        
        self.modelArray = [propertiesArray mutableCopy];
        for (TIoTPropertiesModel *baseModel in propertiesArray) {
            if ([baseModel.mode isEqualToString:@"r"] || [baseModel.define.type isEqualToString:@"string"] || [baseModel.required isEqualToString:@"1"] ||([NSString isNullOrNilWithObject:baseModel.mode] || [NSString isNullOrNilWithObject:baseModel.required] || [NSString isNullOrNilWithObject:baseModel.define.type])) {
                [self.modelArray removeObject:baseModel];
            }
        }
        
        for (TIoTPropertiesModel *baseModel in self.modelArray) {
            
            NSString *valueSteing = NSLocalizedString(@"unset", @"未设置");
            if (self.isEdited == YES) {
                valueSteing = self.valueString?:@"";
            }
            NSDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":baseModel.name?:@"",@"value":valueSteing,@"needArrow":@"1"}];
            [_dataArr addObject:tempDic];
        }
    }
    
    return _dataArr;
}

- (NSMutableArray *)modifiedValueArray {
    if (!_modifiedValueArray) {
        _modifiedValueArray = [NSMutableArray array];
    }
    return _modifiedValueArray;
}

- (NSMutableArray *)modifiedModelArray {
    if (!_modifiedModelArray) {
        _modifiedModelArray = [NSMutableArray array];
    }
    return _modifiedModelArray;
}

- (NSMutableArray *)productArray {
    if (!_productArray) {
        _productArray = [NSMutableArray array];
    }
    return _productArray;
}

@end
