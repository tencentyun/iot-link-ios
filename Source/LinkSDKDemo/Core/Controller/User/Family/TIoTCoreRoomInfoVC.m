//
//  WCRoomInfoVC.m
//  TenextCloud
//
//

#import "TIoTCoreRoomInfoVC.h"
#import "TIoTCoreAlertView.h"

static NSString *cellId = @"rc62368";
@interface TIoTCoreRoomInfoVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *roomInfo;
@end

@implementation TIoTCoreRoomInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
}

- (void)setupUI
{
    self.title = NSLocalizedString(@"room_setting", @"房间设置");
    
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    self.tableView.rowHeight = 60;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 60, kScreenWidth - 40, 48);
    [btn setTitle:NSLocalizedString(@"delete_room", @"删除房间") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:kMainColor];
    [btn addTarget:self action:@selector(toDeleteRoom) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
    
}

#pragma mark - request

- (void)toDeleteRoom
{
    [[TIoTCoreFamilySet shared] deleteRoomWithFamilyId:self.familyId roomId:self.roomDic[@"RoomId"] success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:NSLocalizedString(@"delete_success", @"删除成功")];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
}

- (void)modifyRoom:(NSString *)name
{
    [[TIoTCoreFamilySet shared] modifyRoomWithFamilyId:self.familyId roomId:self.roomDic[@"RoomId"] name:name success:^(id  _Nonnull responseObject) {
        self.roomInfo = @[@{@"title":NSLocalizedString(@"room_name_tip", @"房间名称"),@"name":name}];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.roomInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = NSLocalizedString(@"room_name_tip", @"房间名称");
    cell.detailTextLabel.text = self.roomInfo[indexPath.row][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        TIoTCoreAlertView *av = [[TIoTCoreAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
        [av alertWithTitle:NSLocalizedString(@"room_name_tip", @"房间名称") message:NSLocalizedString(@"less20character", @"20字以内") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"verify", @"确认")];
        av.maxLength = 20;
        av.doneAction = ^(NSString * _Nonnull text) {
            if (text.length > 0) {
                [self modifyRoom:text];
            }
        };
        [av showInView:[[UIApplication sharedApplication] delegate].window];
    }
}

#pragma mark - getter

- (NSArray *)roomInfo
{
    if (!_roomInfo) {
        _roomInfo = @[@{@"title":NSLocalizedString(@"room_name_tip", @"房间名称"),@"name":self.roomDic[@"RoomName"]}];
    }
    return _roomInfo;
}
@end
