//
//  TIoTChooseIntelligentDeviceVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTChooseIntelligentDeviceVC.h"
#import "TIoTCategoryTableViewCell.h"
#import "TIoTProductCell.h"

#import "TIoTNavigationController.h"
#import "TIoTAppEnvironment.h"
#import "TIoTAppConfig.h"

#import <YYModel.h>
#import "FamilyModel.h"
#import "RoomModel.h"
#import "TIoTIntelligentProductConfigModel.h"

#import "TIoTDeviceSettingVC.h"

static NSInteger  const itemNumber = 3;

@interface TIoTChooseIntelligentDeviceVC ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) CGFloat itemWidth;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *categoryTableView;
@property (nonatomic, strong) UICollectionView *productCollectionView;
@property (nonatomic, strong) NSMutableArray *categoryArr;
@property (nonatomic, strong) NSMutableArray *productArr;
@property (nonatomic, strong) NSMutableArray *recommendArr;
@property (nonatomic, strong) NSDictionary *configData;
@property (nonatomic, strong) NSString *selectedProducetedID;

@property (nonatomic,strong) NSMutableArray *rooms;

@end

@implementation TIoTChooseIntelligentDeviceVC

static NSString *cellId = @"TIoTProductCellTIoTProductCell";
static NSString *headerId1 = @"TIoTProductSectionHeader1";
static NSString *headerId2 = @"TIoTProductSectionHeader2";

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _itemWidth = (kScreenWidth - 95 - 19.5*2 - 9.5*2) / 3.0;
    _categoryArr = [NSMutableArray array];
    _productArr = [NSMutableArray array];
    _recommendArr = [NSMutableArray array];
    
    [self setupUI];
    [self getCategoryList];

}

#pragma mark - other

- (void)setupUI{
    
    self.title = NSLocalizedString(@"selected_Device", @"选择设备");
    self.view.backgroundColor = kRGBColor(242, 242, 242);
    
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.scrollView addSubview:self.categoryTableView];
    [self.categoryTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self.view);
        make.width.mas_equalTo(95);
        make.top.equalTo(self.scrollView);
    }];
    
    [self.scrollView addSubview:self.productCollectionView];
    [self.productCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.categoryTableView.mas_right);
        make.top.equalTo(self.categoryTableView);
        make.bottom.right.equalTo(self.view);
    }];
}

- (void)refreshScrollContentSize {
    self.scrollView.bounces = YES;
    CGFloat productCollectionViewHeight = 0;
    CGFloat categoryTableViewHeight = self.categoryArr.count*50;
    if (self.recommendArr.count) {
        productCollectionViewHeight = ((self.recommendArr.count / itemNumber + (self.recommendArr.count % itemNumber == 0 ? 0 : 1) + self.productArr.count / itemNumber + (self.productArr.count % itemNumber == 0 ? 0 : 1)) * 104.5) + 43 + 20.5 + (self.recommendArr.count / itemNumber * 15) + (self.productArr.count / itemNumber * 15);
    } else {
        productCollectionViewHeight = ((self.productArr.count / itemNumber + (self.productArr.count % itemNumber == 0 ? 0 : 1)) * 104.5) + 20.5 + (self.productArr.count / itemNumber * 15);
    }
    CGFloat listHeight = productCollectionViewHeight > categoryTableViewHeight ? productCollectionViewHeight : categoryTableViewHeight;
    listHeight = 119.5 + 20 + listHeight > kScreenHeight - [TIoTUIProxy shareUIProxy].navigationBarHeight - 30 ? 119.5 + 20 + listHeight : kScreenHeight - [TIoTUIProxy shareUIProxy].navigationBarHeight - 30;
    self.scrollView.contentSize = CGSizeMake(kScreenWidth, listHeight);
}

- (void)popHomeVC {
//    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - request


- (void)getCategoryList{
    
    [[TIoTRequestObject shared] post:AppGetRoomList Param:@{@"FamilyId":[TIoTCoreUserManage shared].familyId} success:^(id responseObject) {
        
        self.rooms = [NSMutableArray arrayWithArray:responseObject[@"RoomList"]];
        [self.rooms insertObject:@{@"RoomName":NSLocalizedString(@"all_devices", @"全部设备")} atIndex:0];
        [self.categoryArr removeAllObjects];
        [self.categoryArr addObjectsFromArray:self.rooms];

        WCLog(@"AppGetRoomList responseObject%@", responseObject);
        [self.categoryTableView reloadData];
        if (self.categoryArr.count) {
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.categoryTableView selectRowAtIndexPath:firstIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            if ([self.categoryTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [self.categoryTableView.delegate tableView:self.categoryTableView didSelectRowAtIndexPath:firstIndexPath];
            }
        }
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD dismissInView:self.view];
    }];
}

- (void)getProductList:(NSString *)categoryKey {
    
    NSString *roomId = categoryKey ?: @"";
    NSString *familyId = [TIoTCoreUserManage shared].familyId ?: @"";

    [[TIoTRequestObject shared] post:AppGetFamilyDeviceList Param:@{@"FamilyId":familyId,@"RoomId":roomId} success:^(id responseObject) {
        
        [self.productArr removeAllObjects];
        [self.productArr addObjectsFromArray:responseObject[@"DeviceList"]];

        WCLog(@"AppGetRecommList responseObject%@", responseObject);
        [self.productCollectionView reloadData];
        [self refreshScrollContentSize];
        [MBProgressHUD dismissInView:self.view];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD dismissInView:self.view];
    }];
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.categoryArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTCategoryTableViewCell *cell = [TIoTCategoryTableViewCell cellWithTableView:tableView];
    cell.dic = self.categoryArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
    NSString *categoryKey = @"";
    if (indexPath.row != 0) {
        categoryKey = self.categoryArr[indexPath.row][@"RoomId"]?:@"";
    }
    [self getProductList:categoryKey];
}

#pragma mark UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.recommendArr.count) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.recommendArr.count) {
        if (section == 0) {
            return self.recommendArr.count;
        } else {
            return self.productArr.count;
        }
    } else {
        return self.productArr.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TIoTProductCell *cell = nil;
    if (self.recommendArr.count) {
        if (indexPath.section == 0) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
            cell.dic = self.recommendArr[indexPath.row];
        } else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
            cell.dic = self.productArr[indexPath.row];
        }
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        cell.dic = self.productArr[indexPath.row];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *headerView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        if (self.recommendArr.count) {
            if (indexPath.section == 0) {
                headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId1 forIndexPath:indexPath];
                if (headerView == nil) {
                    headerView = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 95, 43)];
                }
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 38)];
                label.font = [UIFont wcPfRegularFontOfSize:14];
                label.textColor = kRGBColor(136, 136, 136);
                label.text = NSLocalizedString(@"recommend", @"推荐");
                [headerView addSubview:label];
            } else {
                headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId2 forIndexPath:indexPath];
                if (headerView == nil) {
                    headerView = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 95, 20.5)];
                }
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth - 115, 0.5)];
                lineView.backgroundColor = kRGBColor(229, 229, 229);
                [headerView addSubview:lineView];
            }
        }
    }
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_itemWidth, 104.5);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (self.recommendArr.count) {
        return UIEdgeInsetsMake(0, 10, 5, 10);
    } else {
        return UIEdgeInsetsMake(20.5, 10, 5, 10);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (self.recommendArr.count) {
        if (section == 0) {
            return CGSizeMake(kScreenWidth, 43);
        } else {
            return CGSizeMake(kScreenWidth, 20.5);
        }
    } else {
        return CGSizeZero;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = self.productArr[indexPath.row];
    TIoTLog(@"--dic = %@",dic);
    TIoTIntelligentProductConfigModel *intelligentProjuctModel = [TIoTIntelligentProductConfigModel yy_modelWithJSON:dic];
    NSString *productIDString = self.productArr[indexPath.row][@"ProductId"] ?:@"";
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];

    [[TIoTRequestObject shared] post:AppGetProducts Param:@{@"ProductIds":@[productIDString]} success:^(id responseObject) {
        NSArray *tmpArr = responseObject[@"Products"];
        if (tmpArr.count > 0) {
            NSString *DataTemplate = tmpArr.firstObject[@"DataTemplate"];
//            NSDictionary *DataTemplateDic = [NSString jsonToObject:DataTemplate];
            TIoTDataTemplateModel *product = [TIoTDataTemplateModel yy_modelWithJSON:DataTemplate];
//            TIoTProductConfigModel *configModel = [TIoTProductConfigModel yy_modelWithJSON:config];
            NSLog(@"--!!!-%@",product);
            
            //MARK:需要根据AppGetProductsConfig接口筛选哪些是条件 哪些是action，这个是手动自动都需要按照这个字段判断
            
            [self getProductConfigWith:productIDString template:product intelligentProjuctModel:intelligentProjuctModel];
            
//            TIoTDeviceSettingVC *deviceSettingVC = [[TIoTDeviceSettingVC alloc]init];
//            deviceSettingVC.templateModel = product;
//            deviceSettingVC.productModel = intelligentProjuctModel;
//            deviceSettingVC.actionOriginArray = self.actionOriginArray;
//            deviceSettingVC.valueOriginArray = self.valueOriginArray;
//            deviceSettingVC.isEdited = NO;
//            [self.navigationController pushViewController:deviceSettingVC animated:YES];
            
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];
   
}

- (void)getProductConfigWith:(NSString *)selectedProductId template:(TIoTDataTemplateModel *)product intelligentProjuctModel:(TIoTIntelligentProductConfigModel *)intelligentProjuctModel{
    
    NSString *productId = selectedProductId?:@"";
    [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[productId]} success:^(id responseObject) {
        
        NSMutableDictionary *productDic = [NSMutableDictionary dictionaryWithDictionary:[product yy_modelToJSONObject]];
        
        NSArray *propertiesArray = [NSArray arrayWithArray:productDic[@"properties"]?:@[]];
        
        NSMutableArray *projuctArray = productDic[@"properties"]?:@[];
        
        NSArray *data = responseObject[@"Data"];
        if (data.count > 0) {
            NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
            self.configData = [[NSDictionary alloc]initWithDictionary:config];
            
            NSDictionary *AppAutomationDic = self.configData[@"AppAutomation"]?:@{};
            
            TIoTDataTemplateModel *newProduct = nil;
            
            if (self.enterType == DeviceChoiceEnterTypeManual) {
                //MARK:筛选手动智能显示的模板属性properties设置
                NSArray *actionsArray = AppAutomationDic[@"actions"]?:@[];
                
                //筛选设备模板所要显示属性
                projuctArray = [self filterActionOrConditionProductArray:projuctArray propertiesArray:propertiesArray withFilterArray:actionsArray];
                
                newProduct = [TIoTDataTemplateModel yy_modelWithJSON:productDic];
            }else if (self.enterType == DeviceChoiceEnterTypeAuto) {
                //MARK:筛选自动智能显示模板属性设置
                
                if (self.deviceAutoChoiceEnterActionType == YES) { //action
                    NSArray *actionsArray = AppAutomationDic[@"actions"]?:@[];
                
                    //筛选设备模板所要显示属性
                    projuctArray = [self filterActionOrConditionProductArray:projuctArray propertiesArray:propertiesArray withFilterArray:actionsArray];
                    
                }else { //condition
                    NSArray *conditionsArray = AppAutomationDic[@"conditions"]?:@[];
                    
                    //筛选设备模板所要显示属性
                    projuctArray =  [self filterActionOrConditionProductArray:projuctArray propertiesArray:propertiesArray withFilterArray:conditionsArray];
                }
                
                newProduct = [TIoTDataTemplateModel yy_modelWithJSON:productDic];
            }
            
            TIoTDeviceSettingVC *deviceSettingVC = [[TIoTDeviceSettingVC alloc]init];
            deviceSettingVC.templateModel = newProduct;
            deviceSettingVC.productModel = intelligentProjuctModel;
            deviceSettingVC.actionOriginArray = self.actionOriginArray;
            deviceSettingVC.valueOriginArray = self.valueOriginArray;
            deviceSettingVC.isEdited = NO;
            [self.navigationController pushViewController:deviceSettingVC animated:YES];
            
        }
        
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

//MARK:筛选设备模板所要显示属性
-(NSMutableArray *)filterActionOrConditionProductArray:(NSMutableArray *)projuctArray propertiesArray:(NSArray *)propertiesArray withFilterArray:(NSArray *)filterArray{
    
    
    for (int j = 0; j < propertiesArray.count; j++) {
        NSDictionary *tempProduct = propertiesArray[j];
        if (tempProduct != nil) {
            NSString *idString = tempProduct[@"id"]?:@"";
            if (![filterArray containsObject:idString]) {
                [projuctArray removeObject:tempProduct];
            }
        }
    }
    return projuctArray;
    
}

#pragma mark setter or getter

- (UITableView *)categoryTableView{
    if (_categoryTableView == nil) {
        _categoryTableView = [[UITableView alloc] init];
        _categoryTableView.backgroundColor = [UIColor clearColor];
        _categoryTableView.rowHeight = 50;
        _categoryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _categoryTableView.delegate = self;
        _categoryTableView.dataSource = self;
        _categoryTableView.scrollEnabled = NO;
    }
    
    return _categoryTableView;
}

- (UICollectionView *)productCollectionView{
    if (!_productCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 0;
        
        _productCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _productCollectionView.backgroundColor = [UIColor whiteColor];
        _productCollectionView.delegate = self;
        _productCollectionView.dataSource = self;
        _productCollectionView.scrollEnabled = NO;
        [_productCollectionView registerClass:[TIoTProductCell class] forCellWithReuseIdentifier:cellId];
        [_productCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId1];
        [_productCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId2];
        
    }
    return _productCollectionView;
}

@end
