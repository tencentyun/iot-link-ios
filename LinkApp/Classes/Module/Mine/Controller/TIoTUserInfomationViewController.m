//
//  WCUserInfomationViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTUserInfomationViewController.h"
#import "TIoTUserInfomationTableViewCell.h"
//#import "TIoTLoginVC.h"
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

@interface TIoTUserInfomationViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (nonatomic, strong) TIoTQCloudCOSXMLManage *cosXml;
@property (nonatomic, copy) NSArray *dataArr;
@property (nonatomic, copy) NSString *picUrl;

@end

@implementation TIoTUserInfomationViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [HXYNotice addModifyUserInfoListener:self reaction:@selector(modifyUserInfo:)];
    
    [self setupUI];
}

- (void)dealloc{
    [HXYNotice removeListener:self];
}

#pragma mark privateMethods
- (void)setupUI{
    self.view.backgroundColor = kBgColor;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    [self addTableHeaderView];
    [self addTableFooterView];
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
    [deleteEquipmentBtn setTitle:@"退出登录" forState:UIControlStateNormal];
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

//选择获取图片方式
- (void)getImageType{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openSystemPhotoOrCamara:YES];
    }];
    
    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openSystemPhotoOrCamara:NO];
    }];
    
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:camera];
    [alert addAction:photo];
    [alert addAction:cancle];
    [self presentViewController:alert animated:YES completion:nil];
}

//打开系统相册
- (void)openSystemPhotoOrCamara:(BOOL)isCamara{
    if (isCamara) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else{
            [MBProgressHUD showError:@"相机打开失败"];
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
        [MBProgressHUD showError:@"昵称请勿超过20字符"];
        return;
    }
    
    if (![name isEqualToString:[TIoTCoreUserManage shared].nickName]) {
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[TIoTRequestObject shared] post:AppUpdateUser Param:@{@"NickName":name,@"Avatar":[TIoTCoreUserManage shared].avatar} success:^(id responseObject) {
            [MBProgressHUD showSuccess:@"修改成功"];
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
        [MBProgressHUD showSuccess:@"修改成功"];
        [[TIoTCoreUserManage shared] saveUserInfo:@{@"Avatar":avatar}];
        [HXYNotice addModifyUserInfoPost];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

#pragma mark - event
- (void)loginoutClick:(id)sender{
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] post:AppLogoutUser Param:@{} success:^(id responseObject) {
        [[TIoTAppEnvironment shareEnvironment] loginOut];
//        TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTLoginVC alloc] init]];
        TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTMainVC alloc] init]];
        self.view.window.rootViewController = nav;
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
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
    return self.dataArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTUserInfomationTableViewCell *cell = [TIoTUserInfomationTableViewCell cellWithTableView:tableView];
    cell.dic = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"昵称"]) {
        
        TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
        [av alertWithTitle:@"名称设置" message:@"10字以内" cancleTitlt:@"取消" doneTitle:@"确定"];
        av.maxLength = 10;
        av.defaultText = self.dataArr[indexPath.row][@"value"];
        av.doneAction = ^(NSString * _Nonnull text) {
            if (text.length > 0) {
                [self modifyName:text];
            }
            else
            {
                [MBProgressHUD showMessage:@"昵称长度非法" icon:@""];
            }
        };
        [av showInView:[UIApplication sharedApplication].keyWindow];
        
//        WCModifyNikeNameViewController *vc = [[WCModifyNikeNameViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"电话号码"]){
        if ([TIoTCoreUserManage shared].phoneNumber.length == 0) {
            [self bindPhone];
        }
    }
//    else if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"修改密码"]){
//
//        if ([TIoTCoreUserManage shared].phoneNumber.length == 0) {
//
//            TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleText];
//            [av alertWithTitle:@"请先绑定手机号" message:@"当前未绑定手机号，无法进行修改密码" cancleTitlt:@"取消" doneTitle:@"绑定"];
//            av.doneAction = ^(NSString *text) {
//                [self bindPhone];
//            };
//            [av showInView:[UIApplication sharedApplication].keyWindow];
//
//            return;
//        }
//
//        TIoTResetPwdVC *vc = [TIoTResetPwdVC new];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    else if([self.dataArr[indexPath.row][@"title"] isEqualToString:@"账户与安全"]) {
        TIoTAccountAndSafeVC *accountAndSafeVC = [[TIoTAccountAndSafeVC alloc]init];
        [self.navigationController pushViewController:accountAndSafeVC animated:YES];
    }
}

/// 决定具体cell是否显示提示
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
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
                        [MBProgressHUD showError:@"上传失败" toView:selfstrong.view];
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
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
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
        
        _dataArr = @[
        @{@"title":@"昵称",@"value":[TIoTCoreUserManage shared].nickName,@"vc":@"",@"haveArrow":@"1"},
        @{@"title":@"用户ID",@"value":[TIoTCoreUserManage shared].userId!=nil?[TIoTCoreUserManage shared].userId:@"",@"vc":@"",@"haveArrow":@"0"},
        @{@"title":@"账户与安全",@"value":@"",@"vc":@"",@"haveArrow":@"1"}
//        @{@"title":@"电话号码",@"value":[TIoTCoreUserManage shared].phoneNumber,@"vc":@"",@"haveArrow":haveArrow},
//        @{@"title":@"修改密码",@"value":@"",@"vc":@"",@"haveArrow":@"1"}
        ];
    }
    
    return _dataArr;
}

@end
