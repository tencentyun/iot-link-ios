//
//  WCFamilyInfoVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTCoreFamilyInfoVC.h"
#import "TIoTCoreFamilyInfoCell.h"
#import "TIoTCoreFamilyMemberCell.h"
#import "TIoTCoreRoomsVC.h"
#import "TIoTCoreMemberInfoVC.h"
#import "TIoTCoreAlertView.h"

#import "TIoTCoreUserManage.h"


static NSString *headerId = @"pf99";
static NSString *footerId = @"pfwer";
static NSString *itemId = @"pfrrr";
static NSString *itemId2 = @"pfDDD";

@interface TIoTCoreFamilyInfoVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *coll;

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation TIoTCoreFamilyInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    [self getMemberList];
}

- (void)setupUI
{
    self.title =  NSLocalizedString(@"family_detail", @"家庭详情") ;
    
    [self.coll registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
    [self.coll registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
    [self.coll registerNib:[UINib nibWithNibName:@"TIoTCoreFamilyInfoCell" bundle:nil] forCellWithReuseIdentifier:itemId];
    [self.coll registerNib:[UINib nibWithNibName:@"TIoTCoreFamilyMemberCell" bundle:nil] forCellWithReuseIdentifier:itemId2];
}

#pragma mark - request

- (void)getMemberList
{
    [[TIoTCoreFamilySet shared] getMemberListWithFamilyId:self.familyInfo[@"FamilyId"] offset:0 limit:0 success:^(id  _Nonnull responseObject) {
        [self.dataArr addObject:responseObject[@"MemberList"]];
        [self.coll reloadData];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
}

- (void)deleteFamily
{
    [[TIoTCoreFamilySet shared] deleteFamilyWithFamilyId:self.familyInfo[@"FamilyId"] name:self.familyInfo[@"FamilyName"] success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:NSLocalizedString(@"delete_success", @"删除成功")];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
}

- (void)leaveFamily
{
    [[TIoTCoreFamilySet shared] leaveFamilyWithFamilyId:self.familyInfo[@"FamilyId"] success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:@"退出成功"];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
}

- (void)modifyFamily:(NSString *)name
{
    [[TIoTCoreFamilySet shared] modifyFamilyWithFamilyId:self.familyInfo[@"FamilyId"] name:name success:^(id  _Nonnull responseObject) {
        NSMutableDictionary *dic = self.dataArr[0][0];
        [dic setValue:name forKey:@"name"];
        [self.coll reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
}

#pragma mark - event

- (void)deleteOrLeaveFamily
{
    if ([self.familyInfo[@"Role"] integerValue] == 1) {//删除
        
        TIoTCoreAlertView *av = [[TIoTCoreAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleText];
        [av alertWithTitle:NSLocalizedString(@"toast_delete_family_title", @"您确定要删除该家庭吗？")  message:NSLocalizedString(@"toast_delete_family_content", @"删除家庭后，系统将清除所有成员与家庭数据，该家庭下的设备也将被删除") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"delete", @"删除")];
        av.doneAction = ^(NSString * _Nonnull text) {
            [self deleteFamily];
        };
        [av showInView:[UIApplication sharedApplication].keyWindow];
        
    }
    else//退出
    {
        [self leaveFamily];
    }
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
        TIoTCoreFamilyInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemId forIndexPath:indexPath];
        [cell setInfo:info];
        return cell;
    }
    TIoTCoreFamilyMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemId2 forIndexPath:indexPath];
    [cell setInfo:info];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
        view.backgroundColor = [UIColor whiteColor];
        
        for (UIView *sub in view.subviews) {
            [sub removeFromSuperview];
        }
        
        if (indexPath.section == 1) {
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth - 40, 20)];
            lab.text = NSLocalizedString(@"family_member", @"家庭成员");
            lab.textColor = kFontColor;
            lab.font = [UIFont systemFontOfSize:18];
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
            
            UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteBtn.frame = CGRectMake(20, 21, kScreenWidth - 40, 48);
            deleteBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
            [deleteBtn addTarget:self action:@selector(deleteOrLeaveFamily) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:deleteBtn];
            
            if ([self.familyInfo[@"Role"] integerValue] == 1) {
                [deleteBtn setTitle:NSLocalizedString(@"delete_family", @"删除家庭") forState:UIControlStateNormal];
                
                if (self.familyCount <= 1) {
                    deleteBtn.enabled = NO;
                }
            }
            else
            {
                [deleteBtn setTitle:NSLocalizedString(@"exit_family", @"退出家庭") forState:UIControlStateNormal];
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
                TIoTCoreAlertView *av = [[TIoTCoreAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
                [av alertWithTitle:NSLocalizedString(@"family_name", @"家庭名称") message:NSLocalizedString(@"less20character", @"20字以内") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"verify", @"确认")];
                av.maxLength = 20;
                av.doneAction = ^(NSString * _Nonnull text) {
                    if (text.length > 0) {
                        [self modifyFamily:text];
                    }
                };
                [av showInView:[UIApplication sharedApplication].keyWindow];
            }
                break;
            case 1:
            {
                TIoTCoreRoomsVC *vc = [TIoTCoreRoomsVC new];
                vc.familyId = self.familyInfo[@"FamilyId"];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                UIViewController *vc = [NSClassFromString(@"InviteVC") new];
                [vc setValue:NSLocalizedString(@"invite_member", @"邀请成员") forKey:@"title"];
                [vc setValue:self.familyInfo[@"FamilyId"] forKey:@"familyId"];
                [self.navigationController pushViewController:vc animated:YES];
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
        TIoTCoreMemberInfoVC *vc = [[TIoTCoreMemberInfoVC alloc] init];
        if ([[TIoTCoreUserManage shared].userId isEqualToString:ownerInfo[@"UserID"]]) {
            vc.isOwner = YES;
        }
        vc.memberInfo = self.dataArr[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
         
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake(kScreenWidth, 60);
    }
    else
    {
        return CGSizeMake(kScreenWidth / 3.0, 120);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return CGSizeMake(kScreenWidth, 90);
    }
    return CGSizeMake(kScreenWidth, 20);
}

#pragma mark -

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        NSMutableArray *firstSection = [NSMutableArray array];
        [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"family_name", @"家庭名称"),@"name":self.familyInfo[@"FamilyName"]}]];
        [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"room_manager", @"房间管理"),@"name":@""}]];
        
        if ([self.familyInfo[@"Role"] integerValue] == 1) {
            [firstSection addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"invite_family_member", @"邀请家庭成员"),@"name":@""}]];
        }
        
        [_dataArr addObject:firstSection];
        
    }
    return _dataArr;
}

@end
