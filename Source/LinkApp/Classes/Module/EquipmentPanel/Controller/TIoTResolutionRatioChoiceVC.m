//
//  TIoTResolutionRatioChoiceVC.m
//  LinkApp
//
#import <AVFoundation/AVFoundation.h>
#import "TIoTResolutionRatioChoiceVC.h"
static NSString * const KResolutionRatioSetVCID = @"KResolutionRatioSetVCID";
@interface TIoTResolutionRatioChoiceVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *resolutionArray;
@end

@implementation TIoTResolutionRatioChoiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initDataConfigure];
    
    [self setResolutionRatioViews];
}

- (void)initDataConfigure {
    
    self.resolutionArray = @[@"352x288",@"640x480",@"1280x720",@"1920x1080"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSString *value = [self getCaptureSessionPreset:self.selectedResolutionHeight];
    NSDictionary *dic = @{@"kResolutionHeightKey":[NSString stringWithFormat:@"%@",value]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifyResolutionChangedValue" object:nil userInfo:dic];
    
    if (self.resolutionBlock) {
        self.resolutionBlock(self.selectedResolutionHeight);
    }
}

- (void)setResolutionRatioViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KResolutionRatioSetVCID];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resolutionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KResolutionRatioSetVCID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.resolutionArray[indexPath.row];
    NSRange range = [cell.textLabel.text rangeOfString:@"x"];
    cell.tag = [cell.textLabel.text substringFromIndex:range.location+1].integerValue;
    cell.accessoryType = self.selectedResolutionHeight == cell.tag ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *tempresu = self.resolutionArray[indexPath.row];
    NSInteger resolution = [tempresu componentsSeparatedByString:@"x"].lastObject.integerValue;
    self.selectedResolutionHeight = resolution;
    [self.tableView reloadData];
}

- (NSString *)getCaptureSessionPreset:(NSInteger)resolutionHeight {
    NSString *sesstionPreset = AVCaptureSessionPreset352x288;
    switch (resolutionHeight) {
        case 288:
            sesstionPreset = AVCaptureSessionPreset352x288;
            break;
        case 480:
            sesstionPreset = AVCaptureSessionPreset640x480;
            break;
        case 720:
            sesstionPreset = AVCaptureSessionPreset1280x720;
            break;
        case 1080:
            sesstionPreset = AVCaptureSessionPreset1920x1080;
            break;
        default:
            break;
    }
    
    return sesstionPreset;
}
@end
