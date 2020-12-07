//
//  WCUserInfomationViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTUserInfomationViewController.h"
#import "TIoTUserInfomationTableViewCell.h"
#import "TIoTMainVC.h"
#import "TIoTQCloudCOSXMLManage.h"
#import "TIoTModifyNikeNameViewController.h"
#import "TIoTBindPhoneViewController.h"
#import "XGPushManage.h"
#import "TIoTResetPwdVC.h"
#import "TIoTNavigationController.h"
#import "TIoTAppEnvironment.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import "TIoTUploadObj.h"
#import "TIoTAccountAndSafeVC.h"
#import "TIoTCustomActionSheet.h"
#import "NSString+Extension.h"
#import <MJRefresh.h>
#import "TIoTRefreshHeader.h"
#import "TIoTUserConfigModel.h"
#import <YYModel.h>
#import "TIoTChooseTimeZoneVC.h"
#import "TIoTCustomSheetView.h"

@interface TIoTUserInfomationViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (nonatomic, strong) TIoTQCloudCOSXMLManage *cosXml;
@property (nonatomic, copy) NSMutableArray *dataArr;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, strong) TIoTCustomSheetView *customSheet;
@end

@implementation TIoTUserInfomationViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [HXYNotice addModifyUserInfoListener:self reaction:@selector(modifyUserInfo:)];
    
    [self setupUI];
    
    //给UIView添加5次点击复制全局uin，让用户注册去
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    gesture.numberOfTapsRequired = 5;
    [self.view addGestureRecognizer:gesture];
    
    //国际化版本
    [self setupRefreshView];
    [self.tableView.mj_header beginRefreshing];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
    pastboard.string = TIoTAPPConfig.GlobalDebugUin;
}

- (void)dealloc{
    [HXYNotice removeListener:self];
}

//国际化版本
- (void)setupRefreshView {
    // 下拉刷新
    WeakObj(self);
    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
        [selfWeak requestUserConfigMessage];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

#pragma mark privateMethods
- (void)setupUI{
    self.view.backgroundColor = kBgColor;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.equalTo(self.view);
        
        //国际化版本
        make.left.right.bottom.equalTo(self.view);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view.mas_top);
        }
    }];
    
//    [self addTableHeaderView];
//    [self addTableFooterView];
    
    
    //国际化版本
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 16 * kScreenAllHeightScale)];
    headerView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.tableView.tableHeaderView = headerView;

    [self addTableViewFooterView];
}

- (void)addTableHeaderView{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 190)];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 190)];
    headerView.backgroundColor = kRGBColor(242, 242, 242);
    [header addSubview:headerView];
    
    UIView *bgborder = [[UIView alloc] init];
    bgborder.backgroundColor = kRGBAColor(255, 255, 255, 0.6);
    bgborder.layer.cornerRadius = 46;
    [headerView addSubview:bgborder];
    [bgborder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headerView);
        make.width.height.mas_equalTo(92);
    }];
    
    self.iconImageView = [[UIImageView alloc] init];
    [self.iconImageView setImageWithURLStr:[TIoTCoreUserManage shared].avatar placeHolder:@"userDefalut"];
    self.iconImageView.userInteractionEnabled = YES;
    self.iconImageView.layer.cornerRadius = 40;
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.iconImageView xdp_addTarget:self action:@selector(editIcon)];
    [headerView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headerView);
        make.width.height.mas_equalTo(80);
    }];
    
    self.tableView.tableHeaderView = header;
}

- (void)addTableFooterView{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    
    UIButton *deleteEquipmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteEquipmentBtn setTitle:NSLocalizedString(@"logout", @"退出登录") forState:UIControlStateNormal];
    [deleteEquipmentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteEquipmentBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:20];
    [deleteEquipmentBtn addTarget:self action:@selector(loginoutClick:) forControlEvents:UIControlEventTouchUpInside];
    deleteEquipmentBtn.backgroundColor = kWarnColor;
    deleteEquipmentBtn.layer.cornerRadius = 3;
    [footerView addSubview:deleteEquipmentBtn];
    [deleteEquipmentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView).offset(30);
        make.top.equalTo(footerView).offset(40 * kScreenAllHeightScale);
        make.right.equalTo(footerView).offset(-30);
        make.height.mas_equalTo(48);
    }];
    
    
    self.tableView.tableFooterView = footerView;
}

- (void)addTableViewFooterView {
    
    CGFloat kSignoutBtnHeight = 0.0 ;  //348:  5个cell高度 + 三个headerView高度
    
    if ([TIoTUIProxy shareUIProxy].iPhoneX) {
        kSignoutBtnHeight = kScreenHeight - 348 *kScreenAllHeightScale - [TIoTUIProxy shareUIProxy].tabbarAddHeight - [TIoTUIProxy shareUIProxy].navigationBarHeight;
    }else {
        kSignoutBtnHeight = kScreenHeight - 348 *kScreenAllHeightScale - [TIoTUIProxy shareUIProxy].navigationBarHeight;
    }
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kSignoutBtnHeight)];
    footerView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    UIButton *deleteEquipmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteEquipmentBtn setTitle:NSLocalizedString(@"logout", @"退出登录") forState:UIControlStateNormal];
    [deleteEquipmentBtn setTitleColor:[UIColor colorWithHexString:kSignoutHexColor] forState:UIControlStateNormal];
    deleteEquipmentBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [deleteEquipmentBtn addTarget:self action:@selector(loginoutClick:) forControlEvents:UIControlEventTouchUpInside];
    deleteEquipmentBtn.backgroundColor = [UIColor whiteColor];
    deleteEquipmentBtn.layer.cornerRadius = 20;
    [footerView addSubview:deleteEquipmentBtn];
    [deleteEquipmentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView).offset(30);
        make.right.equalTo(footerView).offset(-30);
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            make.bottom.equalTo(footerView).offset(-20 * kScreenAllHeightScale);
        }else {
            make.bottom.equalTo(footerView).offset(-40 * kScreenAllHeightScale);
        }
        
        make.height.mas_equalTo(48 * kScreenAllHeightScale);
    }];
    
    self.tableView.tableFooterView = footerView;

}

//选择获取图片方式
- (void)getImageType{
    
    self.customSheet = [[TIoTCustomSheetView alloc]init];
    
    [self.customSheet sheetViewTopTitleFirstTitle:NSLocalizedString(@"take_photo", @"拍照") secondTitle:NSLocalizedString(@"choice_from_mobilealbum", @"从手机相册选择")];
    __weak typeof(self)weakSelf = self;
    self.customSheet.chooseIntelligentFirstBlock = ^{
        //MARK: 拍照
        [weakSelf openSystemPhotoOrCamara:YES];
        if (weakSelf.customSheet) {
            [weakSelf.customSheet removeFromSuperview];
        }
        
    };
    self.customSheet.chooseIntelligentSecondBlock = ^{
        //MARK: 从手机相册选取
        
        [weakSelf openSystemPhotoOrCamara:NO];
        if (weakSelf.customSheet) {
            [weakSelf.customSheet removeFromSuperview];
        }
    };
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.customSheet];
    [self.customSheet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
    }];
}

//打开系统相册
- (void)openSystemPhotoOrCamara:(BOOL)isCamara{
    if (isCamara) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else{
            [MBProgressHUD showError:NSLocalizedString(@"camera_openFailure", @"相机打开失败")];
            return;
        }
    }
    else{
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    [self presentViewController:self.picker animated:YES completion:nil];
}

//绑定手机号
- (void)bindPhone{
    TIoTBindPhoneViewController *vc = [[TIoTBindPhoneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - req

- (void)modifyName:(NSString *)name
{
    if (name.length > 20) {
        [MBProgressHUD showError:NSLocalizedString(@"nick_less20characters", @"昵称请勿超过20字符")];
        return;
    }
    
    if (![name isEqualToString:[TIoTCoreUserManage shared].nickName]) {
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[TIoTRequestObject shared] post:AppUpdateUser Param:@{@"NickName":name,@"Avatar":[TIoTCoreUserManage shared].avatar} success:^(id responseObject) {
            [MBProgressHUD showSuccess:NSLocalizedString(@"modify_success", @"修改成功")];
            [[TIoTCoreUserManage shared] saveUserInfo:@{@"UserID":[TIoTCoreUserManage shared].userId,@"Avatar":[TIoTCoreUserManage shared].avatar,@"NickName":name,@"PhoneNumber":[TIoTCoreUserManage shared].phoneNumber}];
            [HXYNotice addModifyUserInfoPost];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }
}

- (void)modifyAvatar:(NSString *)avatar
{
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] post:AppUpdateUser Param:@{@"Avatar":avatar} success:^(id responseObject) {
        [MBProgressHUD showSuccess:NSLocalizedString(@"modify_success", @"修改成功")];
        [[TIoTCoreUserManage shared] saveUserInfo:@{@"Avatar":avatar}];
        [HXYNotice addModifyUserInfoPost];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)loginoutClick:(id)sender{
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] post:AppLogoutUser Param:@{} success:^(id responseObject) {
        [[TIoTAppEnvironment shareEnvironment] loginOut];
        TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTMainVC alloc] init]];
        self.view.window.rootViewController = nav;
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)reportTemperatureWithUnit:(NSString *)unitString {
    if ([unitString isEqualToString:@"F"]) {
        //转华氏温度
        [MBProgressHUD showLodingNoneEnabledInView:[[UIApplication sharedApplication] delegate].window withMessage:@""];
        [[TIoTRequestObject shared]post:AppUpdateUserSetting Param:@{@"TemperatureUnit":@"F"} success:^(id responseObject) {
            [MBProgressHUD dismissInView:self.view];
            if (![[responseObject allKeys] containsObject:@"Error"]) {
                NSMutableDictionary *temperatureDic = self.dataArr[2][0];
                [temperatureDic setValue:@"℉" forKey:@"value"];
                NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:2];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
            }
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            [MBProgressHUD dismissInView:self.view];
        }];
    }else if ([unitString isEqualToString:@"C"]) {
        //转摄氏温度
        [MBProgressHUD showLodingNoneEnabledInView:[[UIApplication sharedApplication] delegate].window withMessage:@""];
        [[TIoTRequestObject shared]post:AppUpdateUserSetting Param:@{@"TemperatureUnit":@"C"} success:^(id responseObject) {
            [MBProgressHUD dismissInView:self.view];
            if (![[responseObject allKeys] containsObject:@"Error"]) {
                NSMutableDictionary *temperatureDic = self.dataArr[2][0];
                [temperatureDic setValue:@"℃" forKey:@"value"];
                NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:2];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
            }
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            [MBProgressHUD dismissInView:self.view];
        }];
    }
}

- (void)requestUserConfigMessage {
    [[TIoTRequestObject shared] post:AppGetUserSetting Param:@{} success:^(id responseObject) {
        TIoTUserConfigModel *model = [TIoTUserConfigModel yy_modelWithJSON:responseObject[@"UserSetting"]];

        NSArray *userConfigArray = self.dataArr[2];
        NSMutableDictionary *temperatureDic = userConfigArray[0];
        if ([model.TemperatureUnit isEqualToString:@"C"]) {
            [temperatureDic setValue:@"℃" forKey:@"value"];
            
        }else if ([model.TemperatureUnit isEqualToString:@"F"]) {
            [temperatureDic setValue:@"℉" forKey:@"value"];
        }
        
        NSMutableDictionary *timeZoneDic = userConfigArray[1];
        [timeZoneDic setValue:model.Region forKey:@"value"];
        
        NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:2];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)editIcon{
    [self getImageType];
}

- (void)modifyUserInfo:(id)sender{
    [self.tableView reloadData];
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //国际化版本
    NSArray *sectionDataArray = self.dataArr[section];
    return sectionDataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    //国际化版本
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //国际化版本
    TIoTUserInfomationTableViewCell *cell = [TIoTUserInfomationTableViewCell cellWithTableView:tableView];
    cell.dic = self.dataArr[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //国际化版本
    NSArray *tempSectionArray = self.dataArr[indexPath.section];
    if ([tempSectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"avatar", @"头像")]) {
        [self editIcon];
    }else if ([tempSectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"nick", @"昵称")]) {

            TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
            [av alertWithTitle:NSLocalizedString(@"timing_name", @"名称设置")  message:NSLocalizedString(@"less10characters", @"10字以内") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"confirm", @"确定")];
            av.maxLength = 10;
            av.defaultText = tempSectionArray[indexPath.row][@"value"];
            av.doneAction = ^(NSString * _Nonnull text) {
                if (text.length > 0) {
                    [self modifyName:text];
                }
                else
                {
                    [MBProgressHUD showMessage:NSLocalizedString(@"nick_length_illegality", @"昵称长度非法") icon:@""];
                }
            };
        [av showInView:[[UIApplication sharedApplication] delegate].window];

    //        WCModifyNikeNameViewController *vc = [[WCModifyNikeNameViewController alloc] init];
    //        [self.navigationController pushViewController:vc animated:YES];
        } else if ([tempSectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"telephone_number", @"电话号码")]){
            if ([TIoTCoreUserManage shared].phoneNumber.length == 0) {
                [self bindPhone];
            }
        }else if([tempSectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"account_and_safety", @"账号与安全")]) {
            TIoTAccountAndSafeVC *accountAndSafeVC = [[TIoTAccountAndSafeVC alloc]init];
            [self.navigationController pushViewController:accountAndSafeVC animated:YES];
        }else if ([tempSectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"the_unit_of_temperature", @"温度单位")]) {
            TIoTCustomActionSheet *actionSheet = [[TIoTCustomActionSheet alloc]initWithFrame:[UIScreen mainScreen].bounds];
            actionSheet.choiceFahrenheitBlock = ^{
                //摄氏温度转华氏温度值，并上报用户配置信息
                //客户端目前模糊匹配处理：包含 “华氏” “℉”默认为是需要转换单位，进一步判断如果是纯数字则转换，不是则只替换单位,转化摄氏类似
                //华氏 = 摄氏 * 1.8 +32
                //摄氏 = （华氏 - 32）/ 1.8
                
                NSString *temperatureString = tempSectionArray[indexPath.row][@"value"];
                if (temperatureString) {
                    if ([temperatureString containsString:NSLocalizedString(@"celsius_Hanzi", @"摄氏")] || [temperatureString containsString:@"℃"]) {
                        temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"℃" withString:@""];
                        temperatureString = [temperatureString stringByReplacingOccurrencesOfString:NSLocalizedString(@"celsius_Hanzi", @"摄氏") withString:@""];
                        if ([NSString isPureIntOrFloat:[temperatureString copy]]) {
                            NSMeasurement *measurement = [[NSMeasurement alloc]initWithDoubleValue:temperatureString.floatValue unit:NSUnitTemperature.fahrenheit];
                            NSMeasurement *celsiusMeasurement = [measurement measurementByConvertingToUnit:NSUnitTemperature.celsius];
                            [tempSectionArray[indexPath.row] setValue:[NSString stringWithFormat:@"%f℉",celsiusMeasurement.doubleValue] forKey:@"value"];
                        }else {
                            [tempSectionArray[indexPath.row] setValue:[NSString stringWithFormat:@"%@℉",temperatureString] forKey:@"value"];
                        }
                        
                        //设置用户配置
                        [self reportTemperatureWithUnit:@"F"];
                    }else if ([temperatureString containsString:NSLocalizedString(@"Fahrenheit_Hanzi", @"华氏")] || [temperatureString containsString:@"℉"]){
                        
                    }else {
//                        [MBProgressHUD showError:NSLocalizedString(@"setup_failfure", @"设置失败") toView:[[UIApplication sharedApplication] delegate].window];
                    }
                }
                
            };
            
            actionSheet.choiceCelsiusBlock = ^{
                //华氏温度转换摄氏温度值，并上报用户配置信息
                NSString *temperatureString = tempSectionArray[indexPath.row][@"value"];
                if (temperatureString) {
                    if ([temperatureString containsString:NSLocalizedString(@"Fahrenheit_Hanzi", @"华氏")] || [temperatureString containsString:@"℉"]) {
                        temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"℉" withString:@""];
                        temperatureString = [temperatureString stringByReplacingOccurrencesOfString:NSLocalizedString(@"Fahrenheit_Hanzi", @"华氏") withString:@""];
                        if ([NSString isPureIntOrFloat:[temperatureString copy]]) {
                            NSMeasurement *measurement = [[NSMeasurement alloc]initWithDoubleValue:temperatureString.floatValue unit:NSUnitTemperature.celsius];
                            NSMeasurement *fahrenheitMeasurement = [measurement measurementByConvertingToUnit:NSUnitTemperature.fahrenheit];
                            [tempSectionArray[indexPath.row] setValue:[NSString stringWithFormat:@"%f℃",fahrenheitMeasurement.doubleValue] forKey:@"value"];
                        }else {
                            [tempSectionArray[indexPath.row] setValue:[NSString stringWithFormat:@"%@℃",temperatureString] forKey:@"value"];
                        }
                        
                        //设置用户配置
                        [self reportTemperatureWithUnit:@"C"];
                        
                    }else if ([temperatureString containsString:NSLocalizedString(@"celsius_Hanzi", @"摄氏")] || [temperatureString containsString:@"℃"]){
                        
                    }else {
//                        [MBProgressHUD showError:NSLocalizedString(@"setup_failfure", @"设置失败") toView:[[UIApplication sharedApplication] delegate].window];
                    }
                }

            };
            
            [actionSheet shwoActionSheetView];
        }else if ([tempSectionArray[indexPath.row][@"title"] isEqualToString:NSLocalizedString(@"time_zone", @"时区")]){
            TIoTChooseTimeZoneVC *timeZoneVC = [[TIoTChooseTimeZoneVC alloc]init];
            timeZoneVC.returnTimeZoneBlock = ^(NSString * _Nonnull timeZone, NSString * _Nonnull cityName) {

                [MBProgressHUD showLodingNoneEnabledInView:[[UIApplication sharedApplication] delegate].window withMessage:@""];
                [[TIoTRequestObject shared]post:AppUpdateUserSetting Param:@{@"Region":timeZone} success:^(id responseObject) {
                    [MBProgressHUD dismissInView:self.view];
                    if (![[responseObject allKeys] containsObject:@"Error"]) {

                        NSMutableDictionary *TimeZoneDic = self.dataArr[2][1];
                        [TimeZoneDic setValue:timeZone forKey:@"value"];
                        NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:2];
                        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];

                    }
                } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
                    [MBProgressHUD dismissInView:self.view];
                }];

            };
            [self.navigationController pushViewController:timeZoneVC animated:YES];
        }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

/// 决定具体cell是否显示提示
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //国际化版本
    if (indexPath.section == 0 && indexPath.row == 2) {
        return YES;
    }else {
        return NO;
    }
}

///菜单上显示名称
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        if (([TIoTCoreUserManage shared].userId == nil) || ([[TIoTCoreUserManage shared].userId isEqual: @""])) {
            return NO;
        }else {
            return YES;
        }
    }else {
        return NO;
    }
}

/// 点击菜单中选项会调用
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
        NSString *userID = [TIoTCoreUserManage shared].userId;
        pastboard.string = (userID != nil ? userID : @"");
    }
}

#pragma mark - UIImagePickerControllerDelegate && UINavigationControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
//    获取图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    self.cosXml = [[TIoTQCloudCOSXMLManage alloc] init];
    
    WeakObj(self)
    [self.cosXml getSignature:@[image] com:^(NSArray * _Nonnull reqs) {
        
        for (int i = 0; i < reqs.count; i ++) {
            TIoTUploadObj *obj = reqs[i];
            QCloudCOSXMLUploadObjectRequest *request = obj.req;
            [request setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
                StrongObj(self)
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [MBProgressHUD showError:NSLocalizedString(@"upload_error", @"上传失败") toView:selfstrong.view];
                    }
                    else
                    {
                        [MBProgressHUD dismissInView:selfstrong.view];
                        selfstrong.iconImageView.image = obj.image;
                        selfstrong.picUrl = result.location;
                        
                        [selfstrong modifyAvatar:selfstrong.picUrl];
                    }
                });
                
            }];
            
            [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:request];
        }
    }];
    
    
    
}

//按取消按钮时候的功能
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        //国际化版本
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        _tableView.rowHeight = 50 *kScreenAllHeightScale;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[TIoTUserInfomationTableViewCell class] forCellReuseIdentifier:ID];
    }
    
    return _tableView;
}

- (UIImagePickerController *)picker
{
    if (!_picker) {
        _picker = [[UIImagePickerController alloc]init];
        _picker.delegate = self;
        _picker.allowsEditing = YES;
    }
    return _picker;
}

- (NSArray *)dataArr{
    if (!_dataArr) {
        
        NSString *haveArrow = @"1";
        if ([TIoTCoreUserManage shared].phoneNumber && [TIoTCoreUserManage shared].phoneNumber.length > 0) haveArrow = @"0";
        
        //国际化版本
        _dataArr = [NSMutableArray arrayWithArray:@[
            @[@{@"title":NSLocalizedString(@"avatar", @"头像"),@"value":@"",@"vc":@"",@"haveArrow":@"1",@"Avatar":@"icon-avatar_man"},
              @{@"title":NSLocalizedString(@"nick", @"昵称"),@"value":[TIoTCoreUserManage shared].nickName,@"vc":@"",@"haveArrow":@"1"},
              @{@"title":NSLocalizedString(@"user_ID", @"用户ID"),@"value":[TIoTCoreUserManage shared].userId!=nil?[TIoTCoreUserManage shared].userId:@"",@"vc":@"",@"haveArrow":@"0"},
            ],
            @[@{@"title":NSLocalizedString(@"account_and_safety", @"账号与安全"),@"value":@"",@"vc":@"",@"haveArrow":@"1"}],
            @[[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"the_unit_of_temperature", @"温度单位"),@"value":@"",@"vc":@"",@"haveArrow":@"1"}],
              [NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"time_zone", @"时区"),@"value":@"",@"vc":@"",@"haveArrow":@"1"}],
            ],
        ]];
    }
    
    return _dataArr;
}

@end
