//
//  TIoTShortcutView.m
//  LinkApp
//
//  Created by ccharlesren on 2021/3/15.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTShortcutView.h"
#import "UIView+XDPExtension.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTShortcutViewCell.h"
#import "UIButton+LQRelayout.h"
#import "TIoTCoreDeviceSet.h"
#import "TIOTTRTCModel.h"
#import "TIoTTRTCUIManage.h"
#import "TIoTChooseSliderValueView.h"
#import "TIoTChooseClickValueView.h"

static NSString *const kShortcutViewCellID = @"kShortcutViewCellID";

@interface TIoTShortcutView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UIView *blackMaskView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;                //设备快捷属性数组
@property (nonatomic, strong) NSMutableArray *panelShortcutProperties; //设备完整属性中和快捷属性对应的数据（包含设备名和属性值）

@property (nonatomic, strong) NSDictionary *userConfigDic;
@property (nonatomic, strong) NSDictionary *configData;
@property (nonatomic, strong) NSString *productId;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong)  DeviceInfo *deviceInfo;
@property (nonatomic, strong) NSMutableDictionary *deviceDic;

// TRTC 相关
@property (nonatomic, strong) NSDictionary *reportData;
@property (nonatomic, strong) TIOTtrtcPayloadModel *reportModel;
@end

@implementation TIoTShortcutView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUIView];
    }
    return self;
}

- (void)setupUIView {
    
    CGFloat kIntervalPadding = 12;
    CGFloat kMessageHeight = 48;
    CGFloat kMiddleHeight = 184;

    CGFloat kBottomViewHeight = 56;
    CGFloat kSafeAreaInsetBottom = 34;
    
    self.blackMaskView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.blackMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [[UIApplication sharedApplication].delegate.window addSubview:self.blackMaskView];
    
    if (@available (iOS 11.0, *)) {
        if ([UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom) {
            kBottomViewHeight = kBottomViewHeight +[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        }else {
            kBottomViewHeight = kBottomViewHeight + kSafeAreaInsetBottom;
        }
    }else {
        kBottomViewHeight = kBottomViewHeight + kSafeAreaInsetBottom;
    }
    
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.blackMaskView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.blackMaskView.mas_width);
        make.bottom.equalTo(self.blackMaskView.mas_bottom);
        make.height.mas_equalTo(kMiddleHeight + kMessageHeight + kBottomViewHeight);
    }];
    
    [self changeViewRectConnerWithView:self.contentView withRect:CGRectMake(0, 0, kScreenWidth, kMiddleHeight + kMessageHeight + kBottomViewHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    
    
    UILabel *messageLabel = [[UILabel alloc]init];
    [messageLabel setLabelFormateTitle:@"" font:[UIFont wcPfBoldFontOfSize:16] titleColorHexString:@"#15161A" textAlignment:NSTextAlignmentCenter];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:messageLabel];
    self.messageLabel = messageLabel;
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.equalTo(self.contentView.mas_top).offset(kIntervalPadding);
        make.trailing.mas_equalTo(-0);
        make.height.mas_equalTo(kMessageHeight);
    }];

    UIView *lineTop = [[UIView alloc]init];
    lineTop.backgroundColor = kLineColor;
    [self.contentView addSubview:lineTop];
    [lineTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(1);
        make.top.equalTo(messageLabel.mas_bottom).offset(kIntervalPadding);
    }];
    
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineTop.mas_bottom);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kBottomViewHeight);
    }];
    
    UIView *lineBottom = [[UIView alloc]init];
    lineBottom.backgroundColor = kLineColor;
    [self.contentView addSubview:lineBottom];
    [lineBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kBottomViewHeight);
    }];
    
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn addTarget:self action:@selector(clickMoreBtn) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setButtonFormateWithTitlt:NSLocalizedString(@"more_operation", @"更多操作") titleColorHexString:@"#15161A" font:[UIFont wcPfRegularFontOfSize:14]];
    [self.bottomView addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top).offset(15);
        make.centerX.equalTo(self.bottomView);
        make.left.right.equalTo(self.bottomView);
    }];
    
    UIButton *dissmissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [dissmissBtn addTarget:self action:@selector(hideAlertView) forControlEvents:UIControlEventTouchUpInside];
    [self.blackMaskView addSubview:dissmissBtn];
    [dissmissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.blackMaskView);
        make.bottom.equalTo(self.contentView.mas_top);
    }];
}

#pragma mark - private method
- (void)hideAlertView {
    [self.blackMaskView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)clickMoreBtn {
    [self hideAlertView];
    
    if (self.moreFunctionBlock) {
        self.moreFunctionBlock();
    }
}

- (void)shortcutViewData:(NSDictionary *)config productId:(NSString *)productId deviceDic:(NSMutableDictionary *)deviceDic withDeviceName:aliasName shortcutArray:(NSArray *)shortcutArray{
    
    [HXYNotice addReportDeviceListener:self reaction:@selector(deviceReport:)];
    
    self.configData = [config copy]; // 设备面板详情的每个属性和快捷页面的添加属性项
    self.productId = productId?:@"";
    self.deviceDic = deviceDic;
    self.messageLabel.text = aliasName?:@"";
    self.deviceName = deviceDic[@"DeviceName"]?:@"";
    
    self.deviceInfo.deviceId = deviceDic[@"DeviceId"]?:@"";
    
    NSDictionary *shortcutDic = config[@"ShortCut"]?:@{};
    NSArray *itemArray = shortcutDic[@"shortcut"] ? : @[];
    
    self.dataArray = [itemArray mutableCopy];
    
    [self loadData:self.configData];
    
}


#pragma mark - Network Request
- (void)getProductsConfig
{
    //先获取用户配置信息
    [[TIoTRequestObject shared] post:AppGetUserSetting Param:@{} success:^(id responseObject) {
        self.userConfigDic = [[NSDictionary alloc]initWithDictionary:responseObject[@"UserSetting"]];
        [self loadData:self.configData];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {

    }];
    
}

- (void)loadData:(NSDictionary *)dic {
//    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];

    [[TIoTRequestObject shared] post:AppGetProducts Param:@{@"ProductIds":@[self.productId]} success:^(id responseObject) {
        NSArray *tmpArr = responseObject[@"Products"];
        if (tmpArr.count > 0) {
            NSString *DataTemplate = tmpArr.firstObject[@"DataTemplate"];
            NSDictionary *DataTemplateDic = [NSString jsonToObject:DataTemplate];
            
//            TIoTDataTemplateModel *product = [TIoTDataTemplateModel yy_modelWithJSON:DataTemplate];
            
            TIoTProductConfigModel *config = [TIoTProductConfigModel yy_modelWithJSON:dic];
            if ([config.Panel.type isEqualToString:@"h5"]) {

            }else {
                [self getDeviceData:dic andBaseInfo:DataTemplateDic];
            }

        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];
}

- (void)getDeviceData:(NSDictionary *)uiInfo andBaseInfo:(NSDictionary *)baseInfo {

    [[TIoTRequestObject shared] post:AppGetDeviceData Param:@{@"ProductId":self.productId,@"DeviceName":self.deviceName} success:^(id responseObject) {
        NSString *tmpStr = (NSString *)responseObject[@"Data"];
        NSDictionary *tmpDic = [NSString jsonToObject:tmpStr]?:@{};
        
//        TIoTDeviceDataModel *product = [TIoTDeviceDataModel yy_modelWithJSON:tmpStr];
        NSArray *propertiesArray = baseInfo[@"properties"];
        if (propertiesArray.count == 0) {
//            [self addEmptyCandidateModelTipView];
        }
        [self.deviceInfo zipData:uiInfo baseInfo:baseInfo deviceData:tmpDic];
        
        self.panelShortcutProperties = [NSMutableArray array];
        
        //筛选和快捷属性对应的设备属性列表中的完整值（包括属性值、最大值等）
        
        for (NSDictionary *prpertyModel in self.deviceInfo.allProperties) {
            for (NSDictionary *shortcutDic in self.dataArray) {
                if (![NSString isNullOrNilWithObject:shortcutDic[@"id"]] && ![NSString isNullOrNilWithObject:prpertyModel[@"id"]?:@""]) {
                    if ([shortcutDic[@"id"]?:@"" isEqualToString:prpertyModel[@"id"]?:@""]) {
                        [self.panelShortcutProperties addObject:prpertyModel];
                    }
                }
            }
        }
        
        [self.collectionView reloadData];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];
}

#pragma mark - UICollectionDelegate And  UICollectionDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    TIoTShortcutViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kShortcutViewCellID forIndexPath:indexPath];
    
    NSDictionary *shortcutDic = self.dataArray[indexPath.row]?:@{};
//    cell.iconURLString = shortcutDic[@"ui"][@"icon"]?:@"";
    NSDictionary *model = self.panelShortcutProperties[indexPath.row];
    
//    TIoTShortcutViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kShortcutViewCellID forIndexPath:indexPath];
//    cell.propertyName = model[@"name"];
    
    if (indexPath.row < self.panelShortcutProperties.count) {
        
        ///MARK: 逻辑判断放入cell内  优化点
        if ([model[@"define"][@"type"] isEqualToString:@"int"]||[model[@"define"][@"type"] isEqualToString:@"float"]) {
            
            TIoTShortcutViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kShortcutViewCellID forIndexPath:indexPath];
            cell.propertyName = model[@"name"];
            
            __weak typeof(self)weakSelf = self;
            cell.propertyValue = [NSString stringWithFormat:@"%@%@",model[@"status"][@"Value"]?:@"",model[@"define"][@"unit"]?:@""];
            cell.userInteractionEnabled = [weakSelf.deviceDic[@"Online"] boolValue];
            [cell setIconDefaultImageString:@"shortcut_light" withURLString:shortcutDic[@"ui"][@"icon"]?:@""];
            
            [cell setPropertyModel:model];
            
            cell.intOrFloatUpdate = ^{
                
                TIoTChooseSliderValueView *sliderValueView = [[TIoTChooseSliderValueView alloc]init];
                TIoTPropertiesModel *propertyModel = [TIoTPropertiesModel yy_modelWithDictionary:model];
                sliderValueView.model = propertyModel;
                sliderValueView.sliderTaskValueBlock = ^(NSString * _Nonnull valueString, TIoTPropertiesModel * _Nonnull model, NSString * _Nonnull numberStr, NSString * _Nonnull compareValue) {
                    if ([model.define.type isEqualToString:@"int"]) {
                        [weakSelf reportDeviceData:@{model.id:@(roundf(numberStr.floatValue))}];
                    }else if ([model.define.type isEqualToString:@"float"]){
                        [weakSelf reportDeviceData:@{model.id:@(numberStr.floatValue)}];
                    }else {
                        [weakSelf reportDeviceData:@{model.id:numberStr}];
                    }
                };
                
                [self.blackMaskView addSubview:sliderValueView];
                [sliderValueView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.equalTo([UIApplication sharedApplication].delegate.window);
                    if ([TIoTUIProxy shareUIProxy].iPhoneX) {
                        if (@available(iOS 11.0, *)) {
                            make.bottom.equalTo(self.blackMaskView.mas_bottom).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
                        }else {
                            make.bottom.equalTo(self.blackMaskView.mas_bottom);
                        }
                    }else {
                        make.bottom.equalTo(self.blackMaskView.mas_bottom);
                    }
                }];
                
            };
            return cell;
        }else if ([model[@"define"][@"type"] isEqualToString:@"enum"]) {
            TIoTShortcutViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kShortcutViewCellID forIndexPath:indexPath];
            cell.propertyName = model[@"name"];
            __weak typeof(self)weakSelf = self;
            
            NSString *valueString = [NSString stringWithFormat:@"%@",model[@"status"][@"Value"]?:@"0"];
            cell.propertyValue = [NSString stringWithFormat:@"%@",model[@"define"][@"mapping"][valueString]?:@""];
            cell.userInteractionEnabled = [self.deviceDic[@"Online"] boolValue];
            [cell setIconDefaultImageString:@"shortcut_color" withURLString:shortcutDic[@"ui"][@"icon"]?:@""];
            [cell setPropertyModel:model];
            cell.enumUpdate = ^{
                //trtc特殊判断逻辑
                NSString *key = model[@"id"];
                if ([key isEqualToString:TIoTTRTCaudio_call_status] || [key isEqualToString:TIoTTRTCvideo_call_status]) {
                    weakSelf.reportData = model;
                    [weakSelf reportDeviceData:@{key: @1}];
                }
                
                __weak typeof(self) weakSelf = self;
                TIoTChooseClickValueView *clickValueView = [[TIoTChooseClickValueView alloc]init];
                TIoTPropertiesModel *propertyModel = [TIoTPropertiesModel yy_modelWithDictionary:model];
                clickValueView.model = propertyModel;
                
                clickValueView.chooseTaskValueBlock = ^(NSString * _Nonnull valueString, TIoTPropertiesModel * _Nonnull model) {
                    
                    for (int i= 0; i < model.define.mapping.allValues.count; i++) {
                        NSString *key = [NSString stringWithFormat:@"%d",i];
                        NSString *value = model.define.mapping[key];
                        if ([value isEqualToString:valueString]) {
                            [weakSelf reportDeviceData:@{model.id:@(i)}];
                        }
                    }
                };
                
                [self.blackMaskView addSubview:clickValueView];
                [clickValueView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.equalTo([UIApplication sharedApplication].delegate.window);
                    if ([TIoTUIProxy shareUIProxy].iPhoneX) {
                        if (@available(iOS 11.0, *)) {
                            make.bottom.equalTo(self.blackMaskView.mas_bottom).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
                        }else {
                            make.bottom.equalTo(self.blackMaskView.mas_bottom);
                        }
                    }else {
                        make.bottom.equalTo(self.blackMaskView.mas_bottom);
                    }
                }];
                
            };
            
            return cell;
            
        }else if ([model[@"define"][@"type"] isEqualToString:@"bool"]) {
            TIoTShortcutViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kShortcutViewCellID forIndexPath:indexPath];
            cell.propertyName = model[@"name"];
            
            NSString *valueString = [NSString stringWithFormat:@"%@",model[@"status"][@"Value"]?:@"0"];
            cell.propertyValue = [NSString stringWithFormat:@"%@",model[@"define"][@"mapping"][valueString]?:@""];
            
            
            NSString *iconStr = @"";
            if (valueString.intValue) {
                iconStr = @"shortcut_switch_on";
            }else {
                iconStr = @"shortcut_switch_off";
            }
            [cell setPropertyModel:model];
            [cell setIconDefaultImageString:iconStr withURLString:shortcutDic[@"ui"][@"icon"]?:@""];
    
            cell.userInteractionEnabled = [self.deviceDic[@"Online"] boolValue];
            cell.boolUpdate = ^(NSDictionary * _Nonnull uploadInfo) {
                [self reportDeviceData:uploadInfo];
            };
            return cell;
        }else {
            TIoTShortcutViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kShortcutViewCellID forIndexPath:indexPath];
            cell.propertyName = model[@"name"];
            
            if (![NSString isNullOrNilWithObject:model[@"define"][@"type"]]) {
                cell.propertyValue = @"";
                [cell setPropertyModel:model];
                [cell setIconDefaultImageString:@"shortcut_color" withURLString:shortcutDic[@"ui"][@"icon"]?:@""];
            }
            return cell;
        }
    }else {
        //云端定时
        TIoTShortcutViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kShortcutViewCellID forIndexPath:indexPath];
        cell.propertyName = model[@"name"];
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - 上报 下发数据
//下发数据
- (void)reportDeviceData:(NSDictionary *)deviceReport {
    
    NSMutableDictionary *trtcReport = [deviceReport mutableCopy];
    
    NSDictionary *tmpDic = @{
                                @"ProductId":self.productId,
                                @"DeviceName":self.deviceName,
//                                @"Data":[NSString objectToJson:deviceReport],
                                @"Data":[NSString objectToJson:trtcReport]
                            };
    
    [[TIoTRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

//收到上报
- (void)deviceReport:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    [self.deviceInfo handleShortcutReportDeveic:dic];
    
    [self.collectionView reloadData];
    
}


#pragma mark - lazy loading
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CGFloat kMiddleHeight = 184;
        CGFloat kWidthPadding = 28;
        CGFloat kHorizontalSpace = 17;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat itemWidth = (kScreenWidth - kWidthPadding*2 - 3*kHorizontalSpace)/4;
        CGFloat itemHeight = kMiddleHeight;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, kHorizontalSpace, 0, kHorizontalSpace);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[TIoTShortcutViewCell class] forCellWithReuseIdentifier:kShortcutViewCellID];
    }
    return _collectionView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (DeviceInfo *)deviceInfo
{
    if (!_deviceInfo) {
        _deviceInfo = [[DeviceInfo alloc] init];
    }
    return _deviceInfo;
}
@end
