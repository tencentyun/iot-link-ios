//
//  TIoTComplementIntelligentVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTComplementIntelligentVC.h"
#import "TIoTSettingIntelligentCell.h"
#import "TIoTIntelligentBottomActionView.h"
#import "TIoTSettingIntelligentImageVC.h"
#import "TIoTSettingIntelligentNameVC.h"
#import "TIoTAppEnvironment.h"
#import "TIoTAppConfig.h"

@interface TIoTComplementIntelligentVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;      //task 操作自定义view

@property (nonatomic, strong) NSString *sceneImageUrl;
@property (nonatomic, strong) NSString  *sceneNameString;
@end

@implementation TIoTComplementIntelligentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI {
    self.title = NSLocalizedString(@"complement_Intelligent_Message", @"完善智能信息");
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
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
    TIoTSettingIntelligentCell *cell = [TIoTSettingIntelligentCell cellWithTableView:tableView];
    cell.dic = [self dataArr][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
// MARK: - 图片 名称 目前是死的
    if (indexPath.row == 0) {
        TIoTSettingIntelligentImageVC *settingImageVC = [[TIoTSettingIntelligentImageVC alloc]init];
        settingImageVC.selectedIntelligentImageBlock = ^(NSString * _Nonnull imageUrl) {
            NSMutableDictionary *dic  = self.dataArr[0];
            [dic setValue:imageUrl forKey:@"image"];
            self.sceneImageUrl = imageUrl;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:settingImageVC animated:YES];
        
    }else if (indexPath.row == 1) {
        TIoTSettingIntelligentNameVC *settingNameVC = [[TIoTSettingIntelligentNameVC alloc]init];
        settingNameVC.saveIntelligentNameBlock = ^(NSString * _Nonnull name) {
            NSMutableDictionary *dic  = self.dataArr[1];
            [dic setValue:name forKey:@"value"];
            self.sceneNameString = name;
            
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:settingNameVC animated:YES];
    }
    
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
            [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"finish", @"完成")]];
            
            _bottomView.firstBlock = ^{
                
//                [weakSelf.bottomView removeFromSuperview];
                [weakSelf.navigationController popViewControllerAnimated:YES];
#warning 返回前先释放当期加载view
            };
            
            _bottomView.secondBlock = ^{
#warning 完成场景设置步骤，成功创建完一个场景
                NSDictionary *paramDic = nil;
                NSMutableArray *actionArray = [NSMutableArray array];
                
                NSMutableDictionary *imageDic  = weakSelf.dataArr[0];
                NSString *imageUrl = imageDic[@"image"];
                NSMutableDictionary *nameDic = weakSelf.dataArr[1];
                NSString *nameString = nameDic[@"value"];

                for (int k = 0; k < self.dataArray.count; k++) {
                    id object = weakSelf.dataArray[k];
                    if ([object isKindOfClass:[NSString class]]) {
                        NSString *timeString = weakSelf.dataArray[k];
                        NSString *hourStr = [timeString componentsSeparatedByString:@":"].firstObject;
                        NSString *minuteStr = [timeString componentsSeparatedByString:@":"].lastObject;
                        NSInteger secondNum = hourStr.intValue*60*60 + minuteStr.intValue*60;
                        
                        [actionArray addObject:@{@"ActionType":@(1),@"Date":@(secondNum)}];
                    }else  {
                        
                        TIoTPropertiesModel *model = weakSelf.dataArray[k];
                        NSString *valueStr = weakSelf.valueArray[k]? :@"";
                        NSDictionary *mappingDic = model.define.mapping;
                        [mappingDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                            if ([obj isEqualToString:valueStr]) {
                                NSString *keyStr = key;
                                NSDictionary *dataDic = @{model.id?:@"" : @(keyStr.intValue)};
                                NSString *dataDicStr = [NSString objectToJson:dataDic];
                                
                                NSString *productIDStr = weakSelf.productModel.ProductId ?:@"";
                                NSString *diviceName = weakSelf.productModel.DeviceName ?:@"";
                                NSDictionary *tempData =  @{@"ActionType":@(0),@"ProductId":productIDStr,@"DeviceName":diviceName,@"Data":dataDicStr};
                                [actionArray addObject:tempData];
                            }
                        }];
                    }
                }
                
                paramDic = @{@"FamilyId":[TIoTCoreUserManage shared].familyId,@"SceneName":nameString,@"SceneIcon":imageUrl,@"Actions":actionArray};

                if ([NSString isNullOrNilWithObject:self.sceneImageUrl] && [NSString isNullOrNilWithObject:self.sceneNameString]) {
                    [MBProgressHUD showMessage:NSLocalizedString(@"error_setting_Intelligent_Image", @"请设置智能图片") icon:@""];
                }else if (![NSString isNullOrNilWithObject:self.sceneImageUrl] && [NSString isNullOrNilWithObject:self.sceneNameString]) {
                    [MBProgressHUD showMessage:NSLocalizedString(@"error_setting_Intelligent_Name", @"请设置智能名称") icon:@""];
                }else if ([NSString isNullOrNilWithObject:self.sceneImageUrl] && ![NSString isNullOrNilWithObject:self.sceneNameString]) {
                    [MBProgressHUD showMessage:NSLocalizedString(@"error_setting_Intelligent_Image", @"请设置智能图片") icon:@""];
                }else {
                    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
                    
                    [[TIoTRequestObject shared] post:AppCreateScene Param:paramDic success:^(id responseObject) {
                        
                        [MBProgressHUD showMessage:NSLocalizedString(@"add_sucess", @"添加成功") icon:@""];
                        
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        
                    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
                        
                    }];
                }
                
            };
            
        
        
    }
    return _bottomView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"setting_Intelligent_Image", @"智能图片"),@"value":NSLocalizedString(@"unset", @"未设置"),@"image":@"",@"needArrow":@"1"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"setting_Intelligent_Name", @"智能名称"),@"value":NSLocalizedString(@"unset", @"未设置"),@"needArrow":@"1"}]];
    }
    return _dataArr;
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
