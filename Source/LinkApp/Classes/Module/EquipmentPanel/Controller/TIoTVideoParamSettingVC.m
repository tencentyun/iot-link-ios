//
//  TIoTVideoParamSettingVC.m
//  LinkApp
//

#import "TIoTVideoParamSettingVC.h"
#import "TIoTResolutionRatioChoiceVC.h"
#import "TIoTSamplingReteChoiceVC.h"

static NSString * const KvideoParamSetVCID = @"KvideoParamSetVCID";

@interface TIoTVideoParamSettingVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSourceArray;
@end

@implementation TIoTVideoParamSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureData];
    [self setUIViews];
}

- (void)setUIViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = NSLocalizedString(@"parameter_setting", @"参数设置");
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KvideoParamSetVCID];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64);
        }
    }];
}

- (void)configureData {
    self.dataSourceArray = @[NSLocalizedString(@"resolution_ratio", @"分辨率"),NSLocalizedString(@"sampling_rate", @"采样率")];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KvideoParamSetVCID forIndexPath:indexPath];
    cell.textLabel.text = self.dataSourceArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            TIoTResolutionRatioChoiceVC *resolutionRatioVC = [[TIoTResolutionRatioChoiceVC alloc]init];
            resolutionRatioVC.title =  self.dataSourceArray[indexPath.row];
            resolutionRatioVC.selectedResolutionHeight = self.resolutionHeightValue;
            __weak typeof(self)weakSelf = self;
            resolutionRatioVC.resolutionBlock = ^(NSInteger selectResolutionValue) {
                weakSelf.resolutionHeightValue = selectResolutionValue;
            };
            [self.navigationController pushViewController:resolutionRatioVC animated:YES];
            break;
        }
        case 1: {
            TIoTSamplingReteChoiceVC *samplingReteVC = [[TIoTSamplingReteChoiceVC alloc]init];
            samplingReteVC.title =  self.dataSourceArray[indexPath.row];
            samplingReteVC.samplingValue = self.samplingValue;
            __weak typeof(self)weakSelf = self;
            samplingReteVC.samplingBlock = ^(NSInteger samlpingRateValue) {
                weakSelf.samplingValue = samlpingRateValue;
            };
            [self.navigationController pushViewController:samplingReteVC animated:YES];
            break;
        }
        default:
            break;
    }
}
@end
