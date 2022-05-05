//
//  TIoTSamplingReteChoiceVC.m
//  LinkApp
//

#import "TIoTSamplingReteChoiceVC.h"
static NSString * const KSamplingReteSetVCID = @"KSamplingReteSetVCID";
@interface TIoTSamplingReteChoiceVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *samplingArray;

@end

@implementation TIoTSamplingReteChoiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self dataConfigure];
    [self setSamplingReteViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSDictionary *dic = @{@"kSamplingRateKey":[NSString stringWithFormat:@"%ld",(long)self.samplingValue]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifySamplingChangedValue" object:nil userInfo:dic];
    
    if (self.samplingBlock) {
        self.samplingBlock(self.samplingValue);
    }
}

- (void)dataConfigure {
    
    self.samplingArray = @[@"8k",@"16k"];
}

- (void)setSamplingReteViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KSamplingReteSetVCID];
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
    return self.samplingArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KSamplingReteSetVCID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.samplingArray[indexPath.row];
    NSRange range = [cell.textLabel.text rangeOfString:@"k"];
    cell.tag = [cell.textLabel.text substringToIndex:range.location].integerValue;
    cell.accessoryType = self.samplingValue == cell.tag ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case 8:
            self.samplingValue = cell.tag;
            break;
        case 16:
            self.samplingValue = cell.tag;
            break;
        default:
            self.samplingValue = 8;
            break;
    }
    [self.tableView reloadData];
}
@end
