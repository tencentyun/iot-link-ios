//
//  TIoTIntelligentLogVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentLogVC.h"
#import "TIoTIntelligentLogCell.h"
#import "TIoTIntelligentLogModel.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTDeviceDetailModel.h"
#import <MJRefresh/MJRefresh.h>
#import "TIoTRefreshHeader.h"

static NSUInteger limit = 10; //每次请求数据个数限制

@interface TIoTIntelligentLogVC ()<UITableViewDelegate,UITableViewDataSource>
@property  (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *noIntelligentLogTipLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *logDataArray;
@property (nonatomic, assign) NSInteger selectedRowHeight;
@property (nonatomic, strong) NSIndexPath *clickIndexPath;

@property (nonatomic, assign) NSInteger isOpen;
@property (nonatomic, assign) NSInteger currentRow;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, strong) NSDictionary *monthDictionary;

@property (nonatomic, strong) NSString *lastMsgID;
@property (nonatomic, strong) NSMutableArray *timeSectioniArray; // time section 累计数组
@property (nonatomic, strong) NSMutableArray *sectionDataArray; //@[@"xx-xx-xx":@[model]] key：时间 key:model数组

@property (nonatomic, strong) NSMutableArray *deviceAliasNameArray;

@end

@implementation TIoTIntelligentLogVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView.mj_header beginRefreshing];
    [self.tableView scrollsToTop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViewsUI];
    [self setupRefreshView];
}


- (void)setupRefreshView
{
    // 下拉刷新
    WeakObj(self)
    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
        selfWeak.lastMsgID = nil;
        [selfWeak requestLogData];
    }];
    
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [selfWeak requestLogData];
    }];
    
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
}

- (void)endRefresh:(BOOL)isFooter total:(NSInteger)total {
    
    if (isFooter) {
        if (total < limit) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [self.tableView.mj_footer endRefreshing];
        }
    }
    else{
        
        [self.tableView.mj_header endRefreshing];
        if (total < limit) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }
}

- (void)setupViewsUI {
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self addEmptyIntelligentLogTipView];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)requestLogData {
    
    NSString *msgIDString = @"";
    if (![NSString isNullOrNilWithObject:self.lastMsgID]) {
        msgIDString = self.lastMsgID;
        
    }
    
    NSDictionary *paramDic = @{@"FamilyId":[TIoTCoreUserManage shared].familyId,@"Limit":@(limit),@"MsgId":msgIDString};
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] post:AppGetSceneAndAutomationLogs Param:paramDic success:^(id responseObject) {
        [MBProgressHUD dismissInView:self.view];
        
        TIoTIntelligentLogModel *msgListModel = [TIoTIntelligentLogModel yy_modelWithJSON:responseObject[@"Data"]];
        
        self.logDataArray = [NSMutableArray arrayWithArray:msgListModel.Msgs];
        
        if (self.lastMsgID == nil) {
            [self.sectionDataArray removeAllObjects];
            [self.timeSectioniArray removeAllObjects];
            [self endRefresh:NO total:self.logDataArray.count];
        }else {
            [self endRefresh:YES total:self.logDataArray.count];
        }
        
        NSMutableArray *previousTimeKeyArray = [NSMutableArray array]; //保存之前请求的sectionArray key（日期） 数组
        for (int u = 0; u < self.sectionDataArray.count; u++) {
            NSDictionary *tempDic = self.sectionDataArray[u];
            [previousTimeKeyArray addObject:tempDic.allKeys[0]];//只有一个key（时间）
        }
        
        
        NSMutableArray *timeTempArray = [NSMutableArray array]; //一次拉去list的时间数组
        
        //将时间单独成数组
        for (int i = 0; i< self.logDataArray.count; i++) {
            TIoTLogMsgsModel *model = self.logDataArray[i];
            NSString *time = [NSString getTimeToStr:model.CreateAt withFormat:@"yyyy-MM-dd HH:mm:ss" withTimeZone:[TIoTCoreUserManage shared].userRegion]?:@"";
            NSString *dayString = [time componentsSeparatedByString:@" "].firstObject;
            
            if (![timeTempArray containsObject:dayString]) {
                [timeTempArray addObject:dayString];
                if ([self.timeSectioniArray containsObject:dayString]) {
                    
                }else {
                    [self.timeSectioniArray addObject:dayString];   //每次拉去数据后都保存时间
                }
            }
        }
        
        for (int j = 0; j < timeTempArray.count; j++) {
            
            NSMutableArray *dayTempArray = [NSMutableArray array]; //每个section model数组
            
            //时间单独组成数组
            for (int i = 0; i < self.logDataArray.count; i++)  {
                TIoTLogMsgsModel *model = self.logDataArray[i];
                NSString *time = [NSString getTimeToStr:model.CreateAt withFormat:@"yyyy-MM-dd HH:mm:ss" withTimeZone:[TIoTCoreUserManage shared].userRegion]?:@"";
                NSString *dayString = [time componentsSeparatedByString:@" "].firstObject;
                
                if ([dayString isEqualToString:timeTempArray[j]]) {
                    [dayTempArray addObject:model];
                }
            }
            
            
            if (![NSString isNullOrNilWithObject:self.lastMsgID]) {  //非第一次
                
                if ([previousTimeKeyArray containsObject:timeTempArray[j]]) { // 判断加载更多数据时，判断时间是否和之前数据重复
                    NSMutableDictionary *sectionTempDic = [NSMutableDictionary dictionaryWithDictionary:self.sectionDataArray.lastObject];
                    NSString *timeTempStr = sectionTempDic.allKeys[0]?:@"";
                    NSMutableArray *modelTempArray = [NSMutableArray arrayWithArray:sectionTempDic[timeTempStr]];
                    [modelTempArray addObjectsFromArray:dayTempArray];
                    [sectionTempDic setValue:modelTempArray forKey:timeTempStr];
                    [self.sectionDataArray replaceObjectAtIndex:self.sectionDataArray.count-1 withObject:sectionTempDic];
                }else {
                    [self.sectionDataArray addObject:@{timeTempArray[j]:dayTempArray}];
                }
                
            }else {
                [self.sectionDataArray addObject:@{timeTempArray[j]:dayTempArray}]; //第一次完全添加 @[@"xx-xx-xx":@[model]]
            }
            
        }
            
        NSArray *msgsArray = [NSArray arrayWithArray:msgListModel.Msgs];
        TIoTLogMsgsModel *model = msgsArray.lastObject;
        
        self.lastMsgID = model.MsgId;
        
        [self.tableView reloadData];
        
        if (self.sectionDataArray.count == 0) {
            self.tableView.hidden = YES;
        }else {
            self.tableView.hidden = NO;
        }
        
        NSLog(@"----%@",self.sectionDataArray);
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {

        if (self.lastMsgID == nil) {
            [self.tableView.mj_header endRefreshing];
            
        }else {
            [self.tableView.mj_footer endRefreshing];
        }
        
    }];
}

- (void)requestDeviceAliasNameData:(NSDictionary *)dic semaphore:(dispatch_semaphore_t )sema withIndexPath:(NSIndexPath *)indexPath withResultModel:(TIoTActionResultsModel *)resultModel{

    //根据每个deviceID 获取设备名，并赋值model
    [[TIoTRequestObject shared] post:AppGetDeviceInFamily Param:dic success:^(id responseObject) {
        TIoTDeviceDetailModel *deviceDetailModel = [TIoTDeviceDetailModel yy_modelWithJSON:responseObject[@"Data"]];
        NSString *deviceNameString = @"";
        if ([NSString isNullOrNilWithObject:deviceDetailModel.AliasName]) {
            deviceNameString = deviceDetailModel.DeviceName;
        }else {
            deviceNameString = deviceDetailModel.AliasName;
        }
        
        resultModel.deviceName = deviceNameString;
        
        TIoTIntelligentLogCell *selCell = (TIoTIntelligentLogCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        NSDictionary *modelDic = self.sectionDataArray[indexPath.section];
        NSString *keyString = modelDic.allKeys[0]?:@"";
        NSArray *modelArray = modelDic[keyString]?:@[];
        TIoTLogMsgsModel *model = modelArray[indexPath.row];
        
        selCell.msgModel = model;
        selCell.resultListModel = model.ActionResults;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        dispatch_semaphore_signal(sema);
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

#pragma mark - event

- (void)addEmptyIntelligentLogTipView {
    [self.view addSubview:self.emptyImageView];
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat kSpaceHeight = 100; //距离中心偏移量
        if (@available(iOS 11.0, *)) {
            
            if ([TIoTUIProxy shareUIProxy].iPhoneX) {
                kSpaceHeight = 150;
            }
            make.centerY.mas_equalTo(kScreenHeight/2).offset(-kSpaceHeight);
        } else {
            // Fallback on earlier versions
            if ([TIoTUIProxy shareUIProxy].iPhoneX) {
                kSpaceHeight = 150;
            }
            make.centerY.mas_equalTo(kScreenHeight/2).offset(-kSpaceHeight);
        }
        make.left.equalTo(self.view).offset(60);
        make.right.equalTo(self.view).offset(-60);
        make.height.mas_equalTo(160);
    }];
    
    [self.view addSubview:self.noIntelligentLogTipLabel];
    [self.noIntelligentLogTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emptyImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark -UITableViewDelegate And UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *modelDic = self.sectionDataArray[section];
    NSString *keyString = modelDic.allKeys[0]?:@"";
    NSArray *modelArray = modelDic[keyString]?:@[];
    return modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTIntelligentLogCell *cell = [TIoTIntelligentLogCell cellWithTableView:tableView];
    
    NSDictionary *modelDic = self.sectionDataArray[indexPath.section];
    NSString *keyString = modelDic.allKeys[0]?:@"";
    NSArray *modelArray = modelDic[keyString]?:@[];
    TIoTLogMsgsModel *model = modelArray[indexPath.row];

    cell.msgModel = model;
    cell.resultListModel = model.ActionResults;
    cell.selectedIndex = indexPath;
    
    cell.logDetailBlock = ^(BOOL isShow, NSIndexPath * _Nullable selectedIndex) {
        
//        TIoTIntelligentLogCell *selCell = (TIoTIntelligentLogCell *)[tableView cellForRowAtIndexPath:selectedIndex];
//        if (isShow == YES) {
//            selCell.isCellOpen = YES;
////            self.isOpen = YES;
//        }else {
//            selCell.isCellOpen = NO;
////            self.isOpen = NO;
//        }
//
////        self.currentRow = selectedIndex.row;
////        self.currentSection = selectedIndex.section;
//
//        [tableView beginUpdates];
//        [tableView endUpdates];
        
    };
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTIntelligentLogCell *selCell = (TIoTIntelligentLogCell *)[tableView cellForRowAtIndexPath:indexPath];

    NSDictionary *modelDic = self.sectionDataArray[indexPath.section];
    NSString *keyString = modelDic.allKeys[0]?:@"";
    NSArray *modelArray = modelDic[keyString]?:@[];
    TIoTLogMsgsModel *model = modelArray[indexPath.row];
    
    if (model.ResultCode == 0) { //success
        
    }else if (model.ResultCode == -1) { //fail
        
        if (model.isOpenDetail == YES) {
            model.isOpenDetail = NO;
            
            selCell.msgModel = model;
            
            [tableView beginUpdates];
            [tableView endUpdates];
            
        }else {
            model.isOpenDetail = YES;
            
            TIoTActionResultsModel *resuleModel = model.ActionResults[0]; //success fail 都会返回执行结果
            if ([NSString isNullOrNilWithObject:resuleModel.deviceName]) {
                //GCD+信号量 保证请求顺序
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    for (int i = 0 ; i < model.ActionResults.count; i++) {
                        TIoTActionResultsModel *resuleModel = model.ActionResults[i];
                        NSString *productId = [resuleModel.DeviceId componentsSeparatedByString:@"/"].firstObject?:@"";
                        NSString *deviceName = [resuleModel.DeviceId componentsSeparatedByString:@"/"].lastObject?:@"";
                        NSDictionary *paramDic = @{@"FamilyId":[TIoTCoreUserManage shared].familyId,@"ProductId":productId,@"DeviceName":deviceName};
                        [self requestDeviceAliasNameData:paramDic semaphore:sema withIndexPath:indexPath withResultModel:resuleModel];
                        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                        
                    }
                    
                });
            }else {
                
                selCell.msgModel = model;
                selCell.resultListModel = model.ActionResults;
                
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
            }
            
            
        }
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

//    TIoTIntelligentLogCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *modelDic = self.sectionDataArray[indexPath.section];
    NSString *keyString = modelDic.allKeys[0]?:@"";
    NSArray *modelArray = modelDic[keyString]?:@[];
    TIoTLogMsgsModel *model = modelArray[indexPath.row];

    //键值对处理
    if (model.isOpenDetail == YES) {
        return  72 + 26*model.ActionResults.count;
    }else {
        return  72;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerSectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 36)];
    headerSectionView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];

    NSDictionary *sectionDic = self.sectionDataArray[section];
    NSString *timeString = sectionDic.allKeys[0]?:@""; //2020-01-01
    NSString *dayString = [timeString componentsSeparatedByString:@"-"].lastObject;
    NSString *monthString = [timeString componentsSeparatedByString:@"-"][1]?:@"";
    
    //day
    UILabel *sectionTitle = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 40, 36)];
    [sectionTitle setLabelFormateTitle:dayString font:[UIFont wcPfMediumFontOfSize:30] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [headerSectionView addSubview:sectionTitle];

    //month
    UILabel *sectionDetailTitle = [[UILabel alloc]initWithFrame:CGRectMake(55, 15, 120, 18)];
    [sectionDetailTitle setLabelFormateTitle:self.monthDictionary[monthString] font:[UIFont wcPfMediumFontOfSize:12] titleColorHexString:@"#6C7078" textAlignment:NSTextAlignmentLeft];
    [headerSectionView addSubview:sectionDetailTitle];
    

    return headerSectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

#pragma mark - lazy loading

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 72;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    }
    return _tableView;
}

- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_noTask"]];
    }
    return _emptyImageView;
}


- (UILabel *)noIntelligentLogTipLabel {
    if (!_noIntelligentLogTipLabel) {
        _noIntelligentLogTipLabel = [[UILabel alloc]init];
        _noIntelligentLogTipLabel.text = NSLocalizedString(@"current_no_log", @"当前暂无日志");
        _noIntelligentLogTipLabel.font = [UIFont wcPfRegularFontOfSize:14];
        _noIntelligentLogTipLabel.textColor= [UIColor colorWithHexString:@"#6C7078"];
        _noIntelligentLogTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noIntelligentLogTipLabel;
}

- (NSMutableArray *)sectionDataArray {
    if (!_sectionDataArray) {
        _sectionDataArray = [NSMutableArray array];
    }
    return _sectionDataArray;
}

- (NSMutableArray *)timeSectioniArray {
    if (!_timeSectioniArray) {
        _timeSectioniArray = [NSMutableArray array];
    }
    return _timeSectioniArray;
}

- (NSDictionary *)monthDictionary {
    if (!_monthDictionary) {
        _monthDictionary = @{@"01":NSLocalizedString(@"January", @"1月"),
                             @"02":NSLocalizedString(@"February", @"2月"),
                             @"03":NSLocalizedString(@"March", @"3月"),
                             @"04":NSLocalizedString(@"April", @"4月"),
                             @"05":NSLocalizedString(@"May", @"5月"),
                             @"06":NSLocalizedString(@"June", @"6月"),
                             @"07":NSLocalizedString(@"July", @"7月"),
                             @"08":NSLocalizedString(@"August", @"8月"),
                             @"09":NSLocalizedString(@"September", @"9月"),
                             @"10":NSLocalizedString(@"October", @"10月"),
                             @"11":NSLocalizedString(@"November", @"11月"),
                             @"12":NSLocalizedString(@"December", @"12月")};
    }
    return _monthDictionary;
}

- (NSMutableArray *)deviceAliasNameArray {
    if (!_deviceAliasNameArray) {
        _deviceAliasNameArray = [NSMutableArray array];
    }
    return _deviceAliasNameArray;
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
