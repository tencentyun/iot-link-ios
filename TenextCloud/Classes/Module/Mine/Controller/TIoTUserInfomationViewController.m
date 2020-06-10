//
//  WCUserInfomationViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCUserInfomationViewController.h"
#import "WCUserInfomationTableViewCell.h"
#import "WCLoginVC.h"
#import "WCQCloudCOSXMLManage.h"
#import "WCModifyNikeNameViewController.h"
#import "WCBindPhoneViewController.h"
#import "XGPushManage.h"
#import "WCResetPwdVC.h"
#import "WCNavigationController.h"
#import "WCAppEnvironment.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import "WCUploadObj.h"

@interface WCUserInfomationViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (nonatomic, strong) WCQCloudCOSXMLManage *cosXml;
@property (nonatomic, copy) NSArray *dataArr;
@property (nonatomic, copy) NSString *picUrl;

@end

@implementation WCUserInfomationViewController

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
    [self.iconImageView setImageWithURLStr:[WCUserManage shared].avatar placeHolder:@"userDefalut"];
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
    WCBindPhoneViewController *vc = [[WCBindPhoneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - req

- (void)modifyName:(NSString *)name
{
    if (name.length > 20) {
        [MBProgressHUD showError:@"昵称请勿超过20字符"];
        return;
    }
    
    if (![name isEqualToString:[WCUserManage shared].nickName]) {
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[WCRequestObject shared] post:AppUpdateUser Param:@{@"NickName":name,@"Avatar":[WCUserManage shared].avatar} success:^(id responseObject) {
            [MBProgressHUD showSuccess:@"修改成功"];
            [[WCUserManage shared] saveUserInfo:@{@"UserID":[WCUserManage shared].userId,@"Avatar":[WCUserManage shared].avatar,@"NickName":name,@"PhoneNumber":[WCUserManage shared].phoneNumber}];
            [HXYNotice addModifyUserInfoPost];
        } failure:^(NSString *reason, NSError *error) {
            
        }];
    }
}

- (void)modifyAvatar:(NSString *)avatar
{
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[WCRequestObject shared] post:AppUpdateUser Param:@{@"Avatar":avatar} success:^(id responseObject) {
        [MBProgressHUD showSuccess:@"修改成功"];
        [[WCUserManage shared] saveUserInfo:@{@"Avatar":avatar}];
        [HXYNotice addModifyUserInfoPost];
    } failure:^(NSString *reason, NSError *error) {
        
    }];
}

#pragma mark - event
- (void)loginoutClick:(id)sender{
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[WCRequestObject shared] post:AppLogoutUser Param:@{} success:^(id responseObject) {
        [[WCAppEnvironment shareEnvironment] loginOut];
        WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:[[WCLoginVC alloc] init]];
        self.view.window.rootViewController = nav;
    } failure:^(NSString *reason, NSError *error) {
        
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
    WCUserInfomationTableViewCell *cell = [WCUserInfomationTableViewCell cellWithTableView:tableView];
    cell.dic = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"昵称"]) {
        
        WCAlertView *av = [[WCAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
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
        if ([WCUserManage shared].phoneNumber.length == 0) {
            [self bindPhone];
        }
    }
    else if ([self.dataArr[indexPath.row][@"title"] isEqualToString:@"修改密码"]){
        
        if ([WCUserManage shared].phoneNumber.length == 0) {
            
            WCAlertView *av = [[WCAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleText];
            [av alertWithTitle:@"请先绑定手机号" message:@"当前未绑定手机号，无法进行修改密码" cancleTitlt:@"取消" doneTitle:@"绑定"];
            av.doneAction = ^(NSString *text) {
                [self bindPhone];
            };
            [av showInView:[UIApplication sharedApplication].keyWindow];
            
            return;
        }
        
        WCResetPwdVC *vc = [WCResetPwdVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIImagePickerControllerDelegate && UINavigationControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
//    获取图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    self.cosXml = [[WCQCloudCOSXMLManage alloc] init];
    
    WeakObj(self)
    [self.cosXml getSignature:@[image] com:^(NSArray * _Nonnull reqs) {
        
        for (int i = 0; i < reqs.count; i ++) {
            WCUploadObj *obj = reqs[i];
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
        if ([WCUserManage shared].phoneNumber && [WCUserManage shared].phoneNumber.length > 0) haveArrow = @"0";
        
        _dataArr = @[
        @{@"title":@"昵称",@"value":[WCUserManage shared].nickName,@"vc":@"",@"haveArrow":@"1"},
        @{@"title":@"电话号码",@"value":[WCUserManage shared].phoneNumber,@"vc":@"",@"haveArrow":haveArrow},
        @{@"title":@"修改密码",@"value":@"",@"vc":@"",@"haveArrow":@"1"}
        ];
    }
    
    return _dataArr;
}

@end
