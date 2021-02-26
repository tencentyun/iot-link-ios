//
//  WCFamilyInfoVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTFamilyInfoVC.h"
#import "TIoTFamilyInfoCell.h"
#import "TIoTFamilyMemberCell.h"
#import "TIoTRoomsVC.h"
#import "TIoTMemberInfoVC.h"
#import "TIoTSingleCustomButton.h"
#import "TIoTModifyNameVC.h"
#import "TIoTMapViewController.h"

static NSString *headerId = @"pf99";
static NSString *footerId = @"pfwer";
static NSString *itemId = @"pfrrr";
static NSString *itemId2 = @"pfDDD";

@interface TIoTFamilyInfoVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *coll;

@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIView *backMaskView;
@end

@implementation TIoTFamilyInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [HXYNotice addUpdateMemberListListener:self reaction:@selector(getMemberList)];
    
    [self setupUI];
    [self getMemberList];
}

- (void)setupUI
{
    self.title = NSLocalizedString(@"family_detail", @"家庭详情") ;
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self.coll registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
    [self.coll registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
    [self.coll registerNib:[UINib nibWithNibName:@"TIoTFamilyInfoCell" bundle:nil] forCellWithReuseIdentifier:itemId];
    [self.coll registerNib:[UINib nibWithNibName:@"TIoTFamilyMemberCell" bundle:nil] forCellWithReuseIdentifier:itemId2];
}

#pragma mark - request

- (void)getMemberList
{
    NSDictionary *param = @{@"FamilyId":self.familyInfo[@"FamilyId"]};
    [[TIoTRequestObject shared] post:AppGetFamilyMemberList Param:param success:^(id responseObject) {
        
        if (self.dataArr.count == 2) {
            [self.dataArr removeLastObject];
        }
        
        [self.dataArr addObject:responseObject[@"MemberList"]];
        
        //获取房间个数
        NSDictionary *param = @{@"FamilyId":self.familyInfo[@"FamilyId"],@"Offset":@(0),@"Limit":@(400)};
        [[TIoTRequestObject shared] post:AppGetRoomList Param:param success:^(id responseObject) {
            NSString *roomCount = [NSString stringWithFormat:@"%@",responseObject[@"Total"]?:@"0"];
            NSMutableDictionary *tempDic = self.dataArr[0][1];
            [tempDic setValue:roomCount forKey:@"RoomCount"];
            //刷新
            [self.coll reloadData];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)deleteFamily
{
    NSDictionary *param = @{@"FamilyId":self.familyInfo[@"FamilyId"],@"Name":self.familyInfo[@"FamilyName"]};
    [[TIoTRequestObject shared] post:AppDeleteFamily Param:param success:^(id responseObject) {
        
        [HXYNotice addUpdateFamilyListPost];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)leaveFamily
{
    NSDictionary *param = @{@"FamilyId":self.familyInfo[@"FamilyId"]};
    [[TIoTRequestObject shared] post:AppExitFamily Param:param success:^(id responseObject) {
        [HXYNotice addUpdateFamilyListPost];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)modifyFamily:(NSString *)name
{
    NSDictionary *param = @{@"FamilyId":self.familyInfo[@"FamilyId"],@"Name":name};
    [[TIoTRequestObject shared] post:AppModifyFamily Param:param success:^(id responseObject) {
        
        [HXYNotice addUpdateFamilyListPost];
        
        NSMutableDictionary *dic = self.dataArr[0][0];
        [dic setValue:name forKey:@"name"];
        [self.coll reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

#pragma mark - event

- (void)deleteOrLeaveFamily
{
    if ([self.familyInfo[@"Role"] integerValue] == 1) {//删除
        
        TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
        [av alertWithTitle:NSLocalizedString(@"toast_delete_family_title", @"您确定要删除该家庭吗？")  message:NSLocalizedString(@"toast_delete_family_content", @"删除家庭后，系统将清除所有成员与家庭数据，该家庭下的设备也将被删除") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"delete", @"删除")];
        [av setConfirmButtonColor:kWarnHexColor];
        av.doneAction = ^(NSString * _Nonnull text) {
            [self deleteFamily];
        };
        
        self.backMaskView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].delegate.window.frame];
        [[UIApplication sharedApplication].delegate.window addSubview:self.backMaskView];
        [av showInView:self.backMaskView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAlertView)];
        [self.backMaskView addGestureRecognizer:tap];
        
    }
    else//退出
    {
        TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
        [av alertWithTitle:NSLocalizedString(@"family_leaveConfirm_issue", @"您确定要离开该家庭吗？") message:NSLocalizedString(@"family_leaveConfirm_tip", @"离开家庭后，系统将清除您与该家庭数据")  cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"verify", @"确认")];
        av.doneAction = ^(NSString * _Nonnull text) {
            [self leaveFamily];
        };

        self.backMaskView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].delegate.window.frame];
        [[UIApplication sharedApplication].delegate.window addSubview:self.backMaskView];
        [av showInView:self.backMaskView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAlertView)];
        [self.backMaskView addGestureRecognizer:tap];
        
    }
}

- (void)hideAlertView {
    [self.backMaskView removeFromSuperview];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataArr.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataArr[section] count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = self.dataArr[indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        TIoTFamilyInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemId forIndexPath:indexPath];
        [cell setInfo:info];
        return cell;
    }
    TIoTFamilyMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemId2 forIndexPath:indexPath];
    [cell setInfo:info];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
        view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        
        for (UIView *sub in view.subviews) {
            [sub removeFromSuperview];
        }
        
        if (indexPath.section == 1) {
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, kScreenWidth - 40, 24)];
            lab.text = NSLocalizedString(@"family_member", @"家庭成员");
            lab.textColor = [UIColor colorWithHexString:@"#6C7078"];
            lab.font = [UIFont wcPfRegularFontOfSize:14];
            [view addSubview:lab];
        }
        return view;
    }
    else
    {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerId forIndexPath:indexPath];
        
        for (UIView *sub in view.subviews) {
            [sub removeFromSuperview];
        }
        
        if (indexPath.section == 0) {
            view.backgroundColor = kRGBColor(242, 242, 242);
        }
        else
        {
            view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
            
            TIoTSingleCustomButton *deleteBtn = [[TIoTSingleCustomButton alloc]initWithFrame:CGRectMake(0, 21, kScreenWidth, 40)];
            [deleteBtn singleCustomButtonStyle:SingleCustomButtonCenale withTitle:NSLocalizedString(@"delete_family", @"删除家庭")];
            [deleteBtn singleCustomBUttonBackGroundColor:@"ffffff" isSelected:YES];
            deleteBtn.singleAction = ^{
                [self deleteOrLeaveFamily];
            };
            [view addSubview:deleteBtn];
            
            if ([self.familyInfo[@"Role"] integerValue] == 1) {
                
                [deleteBtn singleCustomButtonStyle:SingleCustomButtonConfirm withTitle:NSLocalizedString(@"delete_family", @"删除家庭")];
//                [deleteBtn singleCustomBUttonBackGroundColor:@"ffffff" isSelected:YES];
                [deleteBtn singleCustomBUttonBackGroundColor:kNoSelectedHexColor isSelected:NO];
                
                if (self.familyCount <= 1) {
                    [deleteBtn singleCustomBUttonBackGroundColor:kNoSelectedHexColor isSelected:NO];
                }
            }
            else
            {
                [deleteBtn singleCustomButtonStyle:SingleCustomButtonCenale withTitle:NSLocalizedString(@"exit_family", @"退出家庭")];
                [deleteBtn singleCustomBUttonBackGroundColor:@"ffffff" isSelected:YES];
            }
            
        }
        
        return view;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.item) {
            case 0:
            {
                
                if ([self.familyInfo[@"Role"] integerValue] == 1) { //所有者
                    NSMutableDictionary *nameDic = self.dataArr[0][0];
                    
                    TIoTModifyNameVC *modifyNameVC = [[TIoTModifyNameVC alloc]init];
                    modifyNameVC.titleText = NSLocalizedString(@"family_name", @"家庭名称");
                    modifyNameVC.defaultText = nameDic[@"name"];
                    modifyNameVC.modifyType = ModifyTypeFamilyName;
                    modifyNameVC.title = NSLocalizedString(@"family_setting", @"家庭设置");
                    modifyNameVC.modifyNameBlock = ^(NSString * _Nonnull name) {
                        if (name.length > 0) {
                            [self modifyFamily:name];
                        }
                        
                    };
                    [self.navigationController pushViewController:modifyNameVC animated:YES];
                }
                
            }
                break;
            case 1:
            {
                TIoTRoomsVC *vc = [TIoTRoomsVC new];
                vc.familyId = self.familyInfo[@"FamilyId"];
                vc.isOwner = [self.familyInfo[@"Role"] integerValue] == 1;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                TIoTMapViewController *mapVC = [[TIoTMapViewController alloc]init];
                mapVC.title = NSLocalizedString(@"choose_location", @"地图选点");
                [self.navigationController pushViewController:mapVC animated:YES];
                break;
            }
            case 3:
            {
                if ([self.familyInfo[@"Role"] integerValue] == 1) { //所有者
                    UIViewController *vc = [NSClassFromString(@"TIoTInvitationVC") new];
                    if (vc) {
                        vc.title = NSLocalizedString(@"invite_member", @"邀请成员");
                        [vc setValue:self.familyInfo[@"FamilyId"] forKey:@"familyId"];
                        
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }
                
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        NSArray *members = self.dataArr[indexPath.section];
        NSDictionary *ownerInfo;
        for (NSDictionary *member in members) {
            if ([member[@"Role"] integerValue] == 1) {
                ownerInfo = member;
                break;
            }
        }
        TIoTMemberInfoVC *vc = [[TIoTMemberInfoVC alloc] init];
        if ([[TIoTCoreUserManage shared].userId isEqualToString:ownerInfo[@"UserID"]]) {
            vc.isOwner = YES;
        }
        vc.memberInfo = self.dataArr[indexPath.section][indexPath.row];
        vc.familyId = self.familyInfo[@"FamilyId"];
        [self.navigationController pushViewController:vc animated:YES];
         
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth, 48);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(kScreenWidth, 0.1);
    }else {
        return CGSizeMake(kScreenWidth, 44);
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(kScreenWidth, 0.1);
    }else {
        return CGSizeMake(kScreenWidth, 90);
    }
    
}

#pragma mark -

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        NSMutableArray *firstSection = [NSMutableArray array];
        [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"family_name", @"家庭名称"),@"name":self.familyInfo[@"FamilyName"],@"Role":self.familyInfo[@"Role"]?:@""}]];
        [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"room_manager", @"房间管理"),@"name":@"",@"RoomCount":@"",@"Role":@"1"}]];
        [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"family_location", @"家庭位置"),@"name":NSLocalizedString(@"set_location", @"设定位置")}]];
         
        if ([self.familyInfo[@"Role"] integerValue] == 1) {
            [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"invite_family_member", @"邀请家庭成员"),@"name":@""}]];
        }
        
        [_dataArr addObject:firstSection];
        
    }
    return _dataArr;
}

@end
