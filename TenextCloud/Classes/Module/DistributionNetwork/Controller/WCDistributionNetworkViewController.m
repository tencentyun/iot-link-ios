//
//  WC 配网 WCDistributionNetworkViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/15.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCDistributionNetworkViewController.h"
#import "TYCyclePagerView.h"
#import "WCDistributionNetCollectionViewCell.h"
#import "WCWIFINetViewController.h"

@interface WCDistributionNetworkViewController ()<TYCyclePagerViewDataSource, TYCyclePagerViewDelegate>

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) TYCyclePagerView *pagerView;
@property (nonatomic, strong) UILabel *desLab;
@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) NSArray *dataArr;

@property (nonatomic, strong) NSString *networkToken;
@end

@implementation WCDistributionNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self getDistributionNetworkToken];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self getDistributionNetworkToken];
//}

- (void)setupUI{
    self.view.backgroundColor = kBgColor;
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [cancleBtn sizeToFit];
    UIBarButtonItem *cancleItem = [[UIBarButtonItem alloc] initWithCustomView:cancleBtn];
    self.navigationItem.leftBarButtonItems  = @[cancleItem];
    
    if ([self.title isEqualToString:@"智能配网"]) {
        self.equipmentType = SmartConfig;
    }
    else{
        self.equipmentType = Softap;
    }
    
    
    
    UIScrollView *scroll = [[UIScrollView alloc] init];
    [self.view addSubview:scroll];
    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-[WCUIProxy shareUIProxy].tabbarAddHeight);
    }];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.textColor = kRGBColor(51, 51, 51);
    self.titleLab.font = [UIFont wcPfSemiboldFontOfSize:20];
    self.titleLab.text = self.equipmentType == SmartConfig ? @"将设备设置为智能配网模式" : @"将设备设置为自助配网模式";
    [scroll addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scroll).offset(30);
        make.right.equalTo(scroll).offset(-30);
        make.top.equalTo(scroll).offset(32 * kScreenAllHeightScale);
        make.width.equalTo(scroll).offset(-60);
    }];
    
    
    UILabel *tip1 = [[UILabel alloc] init];
    tip1.textColor = kFontColor;
    tip1.font = [UIFont wcPfRegularFontOfSize:16];
    tip1.text = @"若指示灯已经在快闪，可跳过该步骤。";
    [scroll addSubview:tip1];
    [tip1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(30);
        make.trailing.mas_equalTo(-30);
        make.top.equalTo(self.titleLab.mas_bottom).offset(10);
    }];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: self.equipmentType == SmartConfig ? @"steps" : @"steps2"]];
    [scroll addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(scroll);
        make.leading.mas_greaterThanOrEqualTo(30);
        make.trailing.mas_lessThanOrEqualTo(-30);
        make.top.equalTo(tip1.mas_bottom).offset(20);
    }];
    
    UILabel *tip2 = [[UILabel alloc] init];
    tip2.textColor = kFontColor;
    tip2.font = [UIFont wcPfRegularFontOfSize:16];
    tip2.text = @"1.接通设备电源。";
    [scroll addSubview:tip2];
    [tip2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(30);
        make.trailing.mas_equalTo(-30);
        make.top.equalTo(imgView.mas_bottom).offset(20);
    }];
    
    UILabel *tip3 = [[UILabel alloc] init];
    tip3.textColor = kFontColor;
    tip3.font = [UIFont wcPfRegularFontOfSize:16];
    tip3.numberOfLines = 0;
    tip3.text = self.equipmentType == SmartConfig ? @"2.长按复位键（开关）5秒" : @"2.长按复位键（开关）5秒，指示灯快闪时，在此长按复位键3秒";
    [scroll addSubview:tip3];
    [tip3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(30);
        make.trailing.mas_equalTo(-30);
        make.top.equalTo(tip2.mas_bottom).offset(20);
    }];
    
    UILabel *tip4 = [[UILabel alloc] init];
    tip4.textColor = kFontColor;
    tip4.font = [UIFont wcPfRegularFontOfSize:16];
    tip4.text = self.equipmentType == SmartConfig ? @"3.指示灯进入快闪状态" : @"3.指示灯进入慢闪状态";
    [scroll addSubview:tip4];
    [tip4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(30);
        make.trailing.mas_equalTo(-30);
        make.top.equalTo(tip3.mas_bottom).offset(20);
    }];
//    [scroll addSubview:self.pagerView];
//    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(scroll);
//        make.top.equalTo(self.titleLab.mas_bottom).offset(15);
//        make.height.mas_equalTo(280 * kScreenAllWidthScale + 30);
//    }];
//
//    self.desLab = [[UILabel alloc] init];
//    self.desLab.text = @"给设备通上电";
//    self.desLab.numberOfLines = 0;
//    self.desLab.textAlignment = NSTextAlignmentCenter;
//    self.desLab.font = [UIFont wcPfRegularFontOfSize:16];
//    self.desLab.textColor = kRGBColor(51, 51, 51);
//    [scroll addSubview:self.desLab];
//    [self.desLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(scroll);
//        make.top.equalTo(self.pagerView.mas_bottom).offset(40 *kScreenAllHeightScale);
//        make.leading.mas_equalTo(20);
//        make.trailing.mas_equalTo(-20);
//    }];
    
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextBtn setTitle:self.equipmentType == SmartConfig ? @"提示灯在快闪" : @"提示灯在慢闪" forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    self.nextBtn.backgroundColor = kMainColor;
    self.nextBtn.layer.cornerRadius = 3;
    [scroll addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scroll).offset(30);
        make.top.equalTo(tip4.mas_bottom).offset(60 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 60);
        make.height.mas_equalTo(48);
        make.bottom.mas_equalTo(-40);
    }];
}

- (void)getDistributionNetworkToken {
    if ([self.title isEqualToString:@"智能配网"]) {
        [self getSoftApToken];
    }else {
        [self getSoftApToken];
    }
}

- (void)getSoftApToken {
    [[WCRequestObject shared] post:AppCreateDeviceBindToken Param:@{} success:^(id responseObject) {

        WCLog(@"AppCreateDeviceBindToken----responseObject==%@",responseObject);
        
        if (![NSObject isNullOrNilWithObject:responseObject[@"Token"]]) {
            self.networkToken = responseObject[@"Token"];
        }
        
    } failure:^(NSString *reason, NSError *error) {

        WCLog(@"AppCreateDeviceBindToken--reason==%@--error=%@",reason,reason);
    }];
}

#pragma mark eventResponse
- (void)nextClick:(id)sender{
    WCWIFINetViewController *vc = [[WCWIFINetViewController alloc] init];
    vc.equipmentType = self.equipmentType;
    vc.currentDistributionToken = self.networkToken;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancleClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TYCyclePagerViewDataSource
- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
    return self.dataArr.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    WCDistributionNetCollectionViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"WCDistributionNetCollectionViewCell" forIndex:index];
    cell.imgName = self.dataArr[index][@"img"];
    return cell;
}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc]init];
    layout.itemSize = CGSizeMake(280 * kScreenAllWidthScale, 280 * kScreenAllWidthScale);
    layout.itemSpacing = 18;
    layout.itemHorizontalCenter = YES;
    return layout;
}

- (void)pagerView:(TYCyclePagerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    WCLog(@"fromIndex:%ld -- toIndex:%ld",(long)fromIndex,(long)toIndex);
    self.desLab.text = [NSString stringWithFormat:@"%@",self.dataArr[toIndex][@"desc"]];
}

#pragma mark --- getter
- (TYCyclePagerView *)pagerView{
    if (_pagerView == nil) {
        _pagerView = [[TYCyclePagerView alloc] init];
//        _pagerView.backgroundColor = kRGBColor(247, 249, 250);
        _pagerView.dataSource = self;
        _pagerView.delegate = self;
        _pagerView.isInfiniteLoop = NO;
        [_pagerView registerClass:[WCDistributionNetCollectionViewCell class] forCellWithReuseIdentifier:@"WCDistributionNetCollectionViewCell"];
    }
    return _pagerView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        if (self.equipmentType == SmartConfig) {
            _dataArr = @[@{@"img":@"step1",@"desc":@"接通设备电源"},@{@"img":@"step2",@"desc":@"长按复位键(开关)5秒"},@{@"img":@"step3",@"desc":@"指示灯进入快闪状态"}];
        }
        else
        {
            _dataArr = @[@{@"img":@"step1",@"desc":@"接通设备电源"},@{@"img":@"step2",@"desc":@"长按复位键(开关)5秒，指示灯快闪时，再次长按复位键3秒"},@{@"img":@"step3",@"desc":@"指示灯进入慢闪状态"}];
        }
    }
    return _dataArr;
}

- (NSString *)networkToken {
    if (_networkToken == nil) {
        _networkToken = @"";
    }
    return _networkToken;
}
@end
