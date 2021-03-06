//
//  WCHelpCenterViewController.m
//  TenextCloud
//
//

#import "TIoTHelpCenterViewController.h"
#import "TIoTHelpCell.h"
#import "TIoTTextVC.h"

@interface TIoTHelpCenterViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArr;
@end

@implementation TIoTHelpCenterViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

#pragma mark privateMethods
- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"help_center", @"帮助中心");
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTHelpCell *cell = [TIoTHelpCell cellWithTableView:tableView];
    cell.dic = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTTextVC *vc = [TIoTTextVC new];
    vc.content = self.dataArr[indexPath.row][@"answer"];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - setter&getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
//        _tableView.separatorColor = kLineColor;
//        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (NSArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = @[
                     @{@"title":NSLocalizedString(@"helpCenter_question1", @"为什么用邮箱注册账号的时候收不到验证码？") ,@"answer":NSLocalizedString(@"helpCenter_answer1", @"您好，一般情况下都是可以收到验证码的。如果有超时现象，需要首先跟用邮箱注册的用户确认是否该验证码邮件被收在垃圾邮箱。我们的验证码发送邮箱地址是 cloud_smart@tencent.com，请确认是否收到该邮箱发送的邮件。有些邮箱可能会拦截我们的验证码邮件，可以设置邮箱的白名单，不拦截此账号发送的邮件。如仍有问题，您可以提供下未收到验证码的APP信息和用户APP账号，我们转交专业的工程师看下。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question2", @"有多少用户可以同时使用一个帐户登录？"),@"answer":NSLocalizedString(@"helpCenter_answer2", @"您好，没有限制。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question3", @"怎么分辨我用的网络是2.4G的还是5G的？") ,@"answer":@"web"},
                     @{@"title":NSLocalizedString(@"helpCenter_question4", @"设备连接的Wi-Fi名称和密码有什么规范么？") ,@"answer":NSLocalizedString(@"helpCenter_answer4", @"在APP添加设备联网时，wifi的名称没有限制，wifi的密码长度最多58位。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question5", @"无线路由器的设备接入上限是多少？") ,@"answer":NSLocalizedString(@"helpCenter_answer5", @"连接设备的数量是由路由器决定的，一般普通的家用路由器可以连接 10 多个，根据您所选的路由器参数不同上限数量会有不同。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question6", @"Smartconfig（智能）配网模式与soft ap（自助）配网模式有什么区别？") ,@"answer":NSLocalizedString(@"helpCenter_answer5", @"Smartconfig（智能）配网模式： Smartconfig就是手机APP端发送包含WIFI 用户名 WIFI密码的 UDP 广播包或者组播包，智能终端的WIFI芯片可以接收到该UDP包，只要知道UDP的组织形式，就可以通过接收到的UDP包解密 出WIFI 用户名 密码，然后智能硬件 配置受到的WIFI 用户名 密码到指定的WIFI AP 上。\nSoft ap（自助）配网模式： APP 配置手机连接到智能硬件（WIFI芯片 的AP），手机和WIFI芯片直接建立通讯，将要配置的WIFI用户名和WIFI密码发送给智能硬件，此时智能硬件可以连接到配置的路由器上。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question7", @"当我使用新的路由器，如何进行变更设置？"),@"answer":NSLocalizedString(@"helpCenter_answer7", @"当变更了路由器和家庭网络之后，原先添加的设备会离线，请将原先的设备从APP移除后，使用新的网络（5G暂时不支持，需使用2.4G）重新添加一次即可。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question8", @"设备添加成功后显示离线，怎么检查？") ,@"answer":NSLocalizedString(@"helpCenter_answer8", @"出现设备离线的情况，请按照下面列举的方法排查下： 1、请检查设备是否正常通电； 2、设备是否有断过电或者断过网，如断开过链接，上线有一个过程，请2分钟后确认是否显示在线； 3、请排查下设备所在网络是否稳定，排查办法：将手机或者Ipad置于同一个网络，并放到设备边上，尝试打开网页； 4、请确认家庭Wi-Fi网络是否正常，或者是否修改过Wi-Fi名称、密码等，如果有，也需要重置设备并重新添加； 5、如果网络正常，但是设备还是离线，请确认Wi-Fi连接数量是否过多。可以尝试重启路由器，给设备断电后重新上电，然后静待2-3分钟看设备是否可以恢复连接； 6、检查固件是否是最新版本，App端检查路径：我-设置-关于-检查更新； 如果以上都排除了还是有问题，建议您移除设备重新添加。移除后重新添加如果还是存在问题，请在APP用户反馈中选择该设备，然后提交反馈，提供登录账号、设备ID给到我们，我们会提交技术查询原因。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question9", @"WIFI设备联网失败可能是什么原因？") ,@"answer":NSLocalizedString(@"helpCenter_answer9", @"1.确保设备通电并开机。 2.确保设备处于待配网（快闪/慢闪）状态，且指示灯状态与APP配网状态一致。 3.确保设备、手机、路由器三者靠近。  4.确保设备所在网络流畅稳定，排查办法：将手机或者Ipad置于同一个网络，并放到设备边上，尝试打开网页  5.确保输入的路由器密码正确，注意密码前后是否有空格。 6.确保使用 2.4G 的 Wi-Fi 频段添加设备，Wi-Fi 需要开启广播，不可设置为隐藏。检查2.4G和5G是否共用为一个SSID，建议修改为不同的SSID。  7.确保路由器无线设置中加密方式为 WPA2-PSK 类型、认证类型为 AES，或两者皆设置为自动。 无线模式不能为 11n only。  8.若路由器接入设备量达到上限，可尝试关闭某个设备的 Wi-Fi 功能空出通道重新配置。  9.若路由器开启无线 MAC 地址过滤，可尝试将设备移出路由器的 MAC 过滤列表，保证路由器没有禁止设备联网。 10.确保路由器开启了DHCP服务，没有开启的话会导致地址被占用。 11.如果还是不行的话，可能是路由器跟设备的兼容性不好，建议您更换路由器再次尝试。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question10", @"最多可以拥有多少个“家庭”？") ,@"answer":NSLocalizedString(@"helpCenter_answer10", @"最多可拥有20个家庭。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question11", @"一个家庭内最多可以创建多少房间？"),@"answer":NSLocalizedString(@"helpCenter_answer11", @"最多可以创建100个房间。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question12", @"一个家庭里可以有多少个成员？") ,@"answer":NSLocalizedString(@"helpCenter_answer12", @"最多可以有20个成员。")},
                     @{@"title":NSLocalizedString(@"helpCenter_question13", @"一个家庭内，最多可以绑定多少设备？") ,@"answer":NSLocalizedString(@"helpCenter_answer13", @"最多不可超过1000个设备")},
                     ];
    }
    return _dataArr;
}

@end
