//
//  TIoTModifyNameVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/12/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTModifyNameVC.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTSingleCustomButton.h"
#import "TIoTAutoIntellSettingCustomTimeCell.h"

static NSString *const kAutoCollectionViewCellID = @"kAutoCollectionViewCellID";

@interface TIoTModifyNameVC ()<UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) NSString *nameTypeString;
@property (nonatomic, strong) NSString *errorTypeString;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) TIoTSingleCustomButton *saveButton;
@property (nonatomic, strong) UICollectionView *collectionView; //推荐房间列表
@property (nonatomic, strong) UILabel *commendLabel; //推荐label
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation TIoTModifyNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI {
    
    self.nameTypeString = @"";
    self.errorTypeString = @"";
    [self setNameStringWithType:self.modifyType];
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    CGFloat kLeftPadding = 15;
    CGFloat kBackViewHeight = 48;
    CGFloat kCollectionHeight = 150;//collection高度
    
    self.backgroundView = [[UIView alloc]init];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backgroundView];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kBackViewHeight);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale).offset(20);
        }
        
    }];
    
    UILabel *titleTipText = [[UILabel alloc]init];
    [titleTipText setLabelFormateTitle:self.titleText?:@"" font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.backgroundView addSubview:titleTipText];
    [titleTipText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundView.mas_left).offset(kLeftPadding);
        make.centerY.equalTo(self.backgroundView.mas_centerY);
        make.width.mas_equalTo(100);
    }];
    
    self.nameField = [[UITextField alloc]init];
    self.nameField.textColor = [UIColor colorWithHexString:@"#6C7078"];
    self.nameField.font = [UIFont wcPfRegularFontOfSize:14];
    self.nameField.text = self.defaultText?:@"";
    self.nameField.placeholder = self.nameTypeString;
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.nameField.delegate = self;
    [self.backgroundView addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleTipText.mas_right);
        make.centerY.equalTo(titleTipText);
        make.right.equalTo(self.backgroundView.mas_right);
    }];
    
    self.commendLabel = [[UILabel alloc]init];
    [self.commendLabel setLabelFormateTitle:NSLocalizedString(@"recommend", @"推荐") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kRegionHexColor textAlignment:NSTextAlignmentLeft];
    [self.view addSubview:self.commendLabel];
    [self.commendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundView.mas_bottom).offset(20);
        make.left.equalTo(self.view.mas_left).offset(kLeftPadding);
    }];

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.commendLabel.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kCollectionHeight);
    }];
    
    __weak typeof(self)weakSelf = self;
    self.saveButton = [[TIoTSingleCustomButton alloc]init];
    self.saveButton.kLeftRightPadding = kLeftPadding * 2;
    [self.saveButton singleCustomButtonStyle:SingleCustomButtonConfirm withTitle:NSLocalizedString(@"confirm", @"确定")];
    self.saveButton.singleAction = ^{
        [weakSelf.nameField resignFirstResponder];
        
        if ([NSString isNullOrNilWithObject:weakSelf.nameField.text] || [NSString isFullSpaceEmpty:weakSelf.nameField.text]) {
            [MBProgressHUD showMessage:weakSelf.errorTypeString icon:@""];
        }else {
            
            if (weakSelf.modifyType == ModifyTypeNickName) {
                if (weakSelf.nameField.text.length > 10) {
                    [MBProgressHUD showError:NSLocalizedString(@"nickName_overLenght", @"名称不能超过10个字符")];
                }else {
                    [weakSelf modifyName:weakSelf.nameField.text];
                }
            }else {
                if (weakSelf.nameField.text.length >20) {
                    [MBProgressHUD showError:NSLocalizedString(@"sceneName_overLenght", @"名称不能超过20个字符")];
                }else {
                    [weakSelf modifyName:weakSelf.nameField.text];
                }
            }
        }
    };
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.top.equalTo(self.collectionView.mas_bottom).offset(30);
    }];
    
    [self judgeAddRoomWithType:self.modifyType];
}

- (void)modifyName:(NSString *)name
{
    switch (self.modifyType) {
        case ModifyTypeNickName: {
            [self modifyNickName:name];
            break;
        }
        case ModifyTypeFamilyName: {
            if (self.modifyNameBlock) {
                self.modifyNameBlock(name);
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        }
        case ModifyTypeRoomName: {
            if (self.modifyNameBlock) {
                self.modifyNameBlock(name);
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        }
        case ModifyTypeAddRoom: {
            [self addRoom:name];
            break;
        }
        default:
            break;
    }
}

- (void)modifyNickName:(NSString *)name {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];

    [[TIoTRequestObject shared] post:AppUpdateUser Param:@{@"NickName":name,@"Avatar":[TIoTCoreUserManage shared].avatar} success:^(id responseObject) {
        if (self.modifyNameBlock) {
            self.modifyNameBlock(name);
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];
}

- (void)addRoom:(NSString *)name {
    
    NSDictionary *param = @{@"FamilyId":self.familyId,@"Name":name};
    [[TIoTRequestObject shared] post:AppCreateRoom Param:param success:^(id responseObject) {
        [HXYNotice addUpdateRoomListPost];
        NSString *roomID = responseObject[@"RoomId"]?:@"";
        
        if (self.addRoomBlock) {
            self.addRoomBlock(@{@"RoomName":name,@"RoomId":roomID,@"DeviceNum":@"0"});
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)setNameStringWithType:(ModifyType)nameType {
    
    switch (nameType) {
        case ModifyTypeNickName: {
            self.nameTypeString = NSLocalizedString(@"please_input_nickName", @"请输入昵称名称");
            self.errorTypeString = NSLocalizedString(@"no_nickName", @"昵称名称不能为空");
            break;
        }
        case ModifyTypeFamilyName: {
            self.nameTypeString = NSLocalizedString(@"fill_family_name", @"请输入家庭名称");
            self.errorTypeString = NSLocalizedString(@"no_familyName", @"家庭名称不能为空");
            break;
        }
        case ModifyTypeRoomName: {
            self.nameTypeString = NSLocalizedString(@"empty_room", @"请输入房间名称");
            self.errorTypeString = NSLocalizedString(@"no_roomName", @"房间名称不能为空");
            break;
        }
        case ModifyTypeAddRoom: {
            self.nameTypeString = NSLocalizedString(@"fill_room_name", @"填写房间名称");
            self.errorTypeString = NSLocalizedString(@"please_fill_room_name", @"请填写房间名称");
            break;
        }
        default:
            break;
    }
}

- (void)judgeAddRoomWithType:(ModifyType)nameType {
    
    if (nameType == ModifyTypeAddRoom) {
        self.commendLabel.hidden = NO;
        self.collectionView.hidden = NO;
        [self.saveButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.collectionView.mas_bottom).offset(30);
        }];
    }else {
        self.commendLabel.hidden = YES;
        self.collectionView.hidden = YES;
        [self.saveButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backgroundView.mas_bottom).offset(30);
        }];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.nameField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameField resignFirstResponder];
    return YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAutoIntellSettingCustomTimeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAutoCollectionViewCellID forIndexPath:indexPath];
    cell.itemString = self.dataArray[indexPath.row];
    cell.autoRepeatTimeType = AutoRepeatTimeTypeTimerCustom;
    cell.isSelected = NO;
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.nameField.text = self.dataArray[indexPath.row];
}

#pragma mark - lazy loading

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat itemWidth = 100*kScreenAllWidthScale;
        CGFloat itemHeight = 40*kScreenAllHeightScale;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 24, 6, 24);
//        flowLayout.minimumLineSpacing = 0;
//        flowLayout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[TIoTAutoIntellSettingCustomTimeCell class] forCellWithReuseIdentifier:kAutoCollectionViewCellID];
    }
    return _collectionView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"living_room", @"客厅"),
                                                      NSLocalizedString(@"kitchen", @"厨房"),
                                                      NSLocalizedString(@"bedroom", @"卧室"),
                                                      NSLocalizedString(@"Assistant_bedroom", @"副卧"),
                                                      NSLocalizedString(@"bathroom", @"卫生间"),
                                                      NSLocalizedString(@"bathroom", @"浴室"),
                                                      NSLocalizedString(@"entrance", @"玄关"),
                                                      NSLocalizedString(@"balcony", @"阳台"),
                                                      NSLocalizedString(@"cloakroom", @"衣帽间")]];
    }
    return _dataArray;
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
