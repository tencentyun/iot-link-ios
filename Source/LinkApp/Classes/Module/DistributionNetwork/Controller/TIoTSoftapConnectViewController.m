//
//  WCSoftapConnectViewController.m
//  TenextCloud
//
//

#import "TIoTSoftapConnectViewController.h"
#import "TIoTSoftapWaitVC.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>
#import "UIImage+Ex.h"

@interface TIoTSoftapConnectViewController ()

@property (nonatomic,strong) UIButton *connectB;//连接按钮
@property (nonatomic,strong) UIButton *nextB;//下一步按钮
@property (nonatomic, strong) UILabel *WiFiNameLabel;

@end

@implementation TIoTSoftapConnectViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePage) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self setupUI];
    
}

#pragma mark privateMethods
- (void)setupUI{
    self.view.backgroundColor = kBgColor;
    self.title = NSLocalizedString(@"soft_ap", @"自助配网");
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [cancleBtn sizeToFit];
    UIBarButtonItem *cancleItem = [[UIBarButtonItem alloc] initWithCustomView:cancleBtn];
    self.navigationItem.leftBarButtonItems  = @[cancleItem];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:scroll];
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.text = NSLocalizedString(@"phoenWIFI_connectHot", @"将手机Wi-Fi连接设备热点");
    tipLab.textColor = kRGBColor(51, 51, 51);
    tipLab.font = [UIFont wcPfSemiboldFontOfSize:20];
    [scroll addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scroll).offset(20);
        make.top.equalTo(scroll).offset(30);
    }];
    
    
    UILabel *tip1 = [[UILabel alloc] init];
    tip1.text = NSLocalizedString(@"soft_ap_hotspot_step_1", @"1.手机WIFI连接到如下图所示的设备热点");
    tip1.textColor = kRGBColor(51, 51, 51);
    tip1.font = [UIFont wcPfRegularFontOfSize:16];
    [scroll addSubview:tip1];
    [tip1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(scroll).offset(20);
        make.top.equalTo(tipLab.mas_bottom).offset(30);
    }];
    
    CGFloat kImageScale = 0.866667; //高/宽
    CGFloat kPadding = 30;
    UIImageView *tipImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor redColor]]];
    [tipImageView setImage:[UIImage imageNamed:@"wifieg"]];
//    tipImageView.contentMode = UIViewContentModeCenter;
    [scroll addSubview:tipImageView];
    [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tip1.mas_bottom).offset(20);
        make.centerX.equalTo(scroll);
        make.left.equalTo(scroll.mas_left).offset(kPadding);
        make.right.equalTo(scroll.mas_right).offset(-kPadding);
        make.height.mas_equalTo(tipImageView.mas_width).multipliedBy(kImageScale);
//        make.height.mas_equalTo(200);
    }];
    
    CGFloat kWiFiNameHeithtScale =  0.5;//0.487179;//380/780   WiFi 距离顶部高度比例
    CGFloat kWiFiNameWidthtScale = 0.1;//90/900  WiFi 距离左边距比例
    CGFloat kWiFiNameHeitht = 0.0769230;//60/780 WiFi 高度比例
    CGFloat kWiFiNameWidth = 0.6666;//200/900; WiFi 宽度比例
    CGFloat kImageViewWidth = kScreenWidth - kPadding*2;  //imageview 宽度
    CGFloat kImageViewheight = kImageViewWidth * kImageScale; //image 高度
    
    CGFloat kLeftPadding = kWiFiNameWidthtScale * kImageViewWidth; // 转换到image view的左边距
    CGFloat kTopPadding = kWiFiNameHeithtScale * kImageViewheight; //转换到image view的顶部距离
    CGFloat kWiFiHeitht =  kWiFiNameHeitht * kImageViewheight; //转换到image view的高度
    CGFloat kWiFiWidth = kWiFiNameWidth * kImageViewWidth; //转换到image view的宽度
    
    self.WiFiNameLabel = [[UILabel alloc]init];
    self.WiFiNameLabel.text = @"tcloud_XXX";
    [tipImageView addSubview:self.WiFiNameLabel];
    [self.WiFiNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipImageView.mas_left).offset(kLeftPadding);
        make.top.equalTo(tipImageView.mas_top).offset(kTopPadding);
        make.height.mas_equalTo(kWiFiHeitht);
        make.width.mas_equalTo(kWiFiWidth);
    }];
    
    UILabel *tip2 = [[UILabel alloc] init];
    tip2.text = NSLocalizedString(@"soft_ap_hotspot_step_2", @"2.返回APP,添加设备");
    tip2.textColor = kRGBColor(51, 51, 51);
    tip2.font = [UIFont wcPfRegularFontOfSize:16];
    [scroll addSubview:tip2];
    [tip2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(scroll).offset(20);
        make.top.equalTo(tipImageView.mas_bottom).offset(20);
    }];
    
    
    UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [connectBtn setTitle:NSLocalizedString(@"soft_ap_connect_hotspot", @"连接设备热点") forState:UIControlStateNormal];
    [connectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    connectBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [connectBtn addTarget:self action:@selector(connectClick:) forControlEvents:UIControlEventTouchUpInside];
    connectBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    connectBtn.layer.cornerRadius = 3;
    [scroll addSubview:connectBtn];
    self.connectB = connectBtn;
    [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scroll).offset(30);
        make.top.equalTo(tip2.mas_bottom).offset(70 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 60);
        make.height.mas_equalTo(48);
    }];
    
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:@"连接正确，进入下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    nextBtn.layer.cornerRadius = 3;
    nextBtn.hidden = YES;
    [scroll addSubview:nextBtn];
    self.nextB = nextBtn;
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scroll).offset(30);
        make.top.equalTo(connectBtn.mas_bottom).offset(kScreenAllHeightScale * 30);
        make.width.mas_equalTo(kScreenWidth - 60);
        make.height.mas_equalTo(48);
        make.bottom.equalTo(scroll.mas_bottom).offset(-20);
    }];
    
 }


- (void)updatePage
{
    self.connectB.backgroundColor = [UIColor whiteColor];
    [self.connectB setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.connectB setTitle:NSLocalizedString(@"reconnect",  @"重新连接") forState:UIControlStateNormal];
    self.connectB.layer.borderColor = kRGBColor(221, 221, 221).CGColor;
    self.connectB.layer.borderWidth = 1.0;
    
    self.nextB.hidden = NO;
}

#pragma mark eventResponse
- (void)connectClick:(id)sender{
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)nextClick:(id)sender{
    TIoTSoftapWaitVC *vc = [[TIoTSoftapWaitVC alloc] init];
    vc.title = NSLocalizedString(@"softAP_distributionnetwork", @"soft ap配网");
    vc.wifiInfo = self.wifiInfo.copy;
    vc.roomId = self.roomId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancleClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
