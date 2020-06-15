//
//  ViewController.m
//  QCFrameworkDemo
//
//  Created by Wp on 2019/12/9.
//  Copyright © 2019 Reo. All rights reserved.
//

#import "HomeVC.h"
#import "WCEquipmentTableViewCell.h"
#import "NSObject+ro.h"
#import "CMPageTitleContentView.h"
#import "ControlDeviceVC.h"

#import <QCFoundation/QCFoundation.h>


static NSString *cellID = @"DODO";
@interface HomeVC ()<UITableViewDelegate,UITableViewDataSource,CMPageTitleContentViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tab;

@property (nonatomic,strong) NSArray *familyList;
@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong) NSString *currentFamilyId;
@property (nonatomic,strong) NSString *currentRoomId;
@property (nonatomic,strong) NSArray *deviceList;

@property (nonatomic,strong) CMPageTitleContentView *familyTitlesView;
@property (nonatomic,strong) CMPageTitleContentView *roomTitlesView;


@property dispatch_semaphore_t sem;
@property (nonatomic, copy) NSArray *deviceIds;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.title = @"首页";
    [self.tab registerClass:[WCEquipmentTableViewCell class] forCellReuseIdentifier:cellID];
    
    [self getFamilyList];
    
}

- (void)addViewWithType:(NSUInteger)type names:(NSArray<NSString *> *)names
{
    CMPageTitleConfig *config = [CMPageTitleConfig defaultConfig];
    config.cm_switchMode = CMPageTitleSwitchMode_Scale;
    config.cm_titles = names;
    config.cm_font = [UIFont systemFontOfSize:16];
    config.cm_selectedFont = [UIFont boldSystemFontOfSize:17];
    config.cm_normalColor = kFontColor;
    config.cm_selectedColor = kRGBColor(0, 82, 217);

    CMPageTitleContentView *titView = [[CMPageTitleContentView alloc] initWithConfig:config];
    titView.backgroundColor = [UIColor lightGrayColor];
    titView.cm_delegate = self;
    
    if (1 == type) {
        if (self.familyTitlesView) {
            [self.familyTitlesView removeFromSuperview];
        }
        titView.frame = CGRectMake(60, [NSObject navigationBarHeight], kScreenWidth - 60, 44);
        self.familyTitlesView = titView;
    }
    else
    {
        if (self.roomTitlesView) {
            [self.roomTitlesView removeFromSuperview];
        }
        titView.frame = CGRectMake(60, [NSObject navigationBarHeight] + 44 + 2, kScreenWidth - 60, 44);
        self.roomTitlesView = titView;
    }
    [self.view addSubview:titView];
}



- (void)getFamilyList
{
    [[QCFamilySet shared] getFamilyListWithOffset:0 limit:0 success:^(id  _Nonnull responseObject) {
        
        self.familyList = responseObject[@"FamilyList"];
        
        if (self.familyList.count > 0) {
            NSArray *names = [self.familyList valueForKey:@"FamilyName"];
            [self addViewWithType:1 names:names];
            
            self.currentFamilyId = self.familyList[0][@"FamilyId"];
            [self getRoomList];
            [self getDeviceList];
            
            [[NSUserDefaults standardUserDefaults] setValue:self.familyList[0][@"FamilyId"] forKey:@"firstFamilyId"];
        }
        else
        {
            [self createFamily];
        }
        
        
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}

- (void)createFamily
{
    [[QCFamilySet shared] createFamilyWithName:@"我的家" address:@"兰陵" success:^(id  _Nonnull responseObject) {
        [self getFamilyList];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}

- (void)getRoomList
{
    [[QCFamilySet shared] getRoomListWithFamilyId:self.currentFamilyId offset:0 limit:0 success:^(id  _Nonnull responseObject) {
        
        self.roomList = responseObject[@"RoomList"];
        NSMutableArray *names = [NSMutableArray arrayWithObject:@"全部"];
        [names addObjectsFromArray:[self.roomList valueForKey:@"RoomName"]];
        [self addViewWithType:2 names:names];
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}

- (void)getDeviceList
{
    [[QCDeviceSet shared] getDeviceListWithFamilyId:self.currentFamilyId roomId:self.currentRoomId ?: @"" offset:0 limit:0 success:^(id  _Nonnull responseObject) {
        self.deviceList = responseObject;
        
        self.deviceIds = [self.deviceList valueForKey:@"DeviceId"];
        if (self.deviceIds && self.deviceIds.count > 0) {
            [[QCDeviceSet shared] activePushWithDeviceIds:self.deviceIds complete:^(BOOL success, id data) {
                
            }];
        }
        
        [self.tab reloadData];
        
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}





#pragma mark - UITableView

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceList.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WCEquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.dataDic = self.deviceList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ControlDeviceVC *vc = [[ControlDeviceVC alloc] init];
    vc.title = [NSString stringWithFormat:@"%@",self.deviceList[indexPath.row][@"AliasName"]];
    vc.deviceInfo = [self.deviceList[indexPath.row] mutableCopy];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - CMPageTitleContentViewDelegate

- (void)cm_pageTitleContentView:(CMPageTitleContentView *)view clickWithLastIndex:(NSUInteger)LastIndex Index:(NSUInteger)index Repeat:(BOOL)repeat
{
    if (view == self.familyTitlesView) {
        NSLog(@"家庭==%zi",index);
        
        self.currentFamilyId = self.familyList[index][@"FamilyId"];
        self.currentRoomId = nil;
        [self getRoomList];
        [self getDeviceList];
    }
    else
    {
        NSLog(@"房间==%zi",index);
        
        if (index > 0) {
            self.currentRoomId = self.roomList[index - 1][@"RoomId"];
        }
        else
        {
            self.currentRoomId = nil;
        }
        
        [self getDeviceList];
    }
}


#pragma mark - setter

- (void)setCurrentFamilyId:(NSString *)currentFamilyId
{
    _currentFamilyId = currentFamilyId;
}





@end
