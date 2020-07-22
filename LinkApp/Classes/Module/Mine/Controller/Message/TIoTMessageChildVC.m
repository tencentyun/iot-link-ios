//
//  WCMessageChildVC.m
//  TenextCloud
//
//  Created by Wp on 2020/3/2.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTMessageChildVC.h"
#import "TIoTMessageInviteCell.h"
#import "TIoTMessageTextCell.h"
#import "TIoTMessageText2Cell.h"
#import <MJRefresh/MJRefresh.h>

static NSString *cell1 = @"qdg";
static NSString *cell2 = @"asg";
static NSString *cell3 = @"gddf";
static NSUInteger limit = 20;
@interface TIoTMessageChildVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, copy) NSString *msgID;//上次数据中最后一条的
@property (nonatomic, assign) SInt64 msgTimestamp;

@property (nonatomic, assign) NSUInteger category;//设备：1，家庭：2，通知：3

@end

@implementation TIoTMessageChildVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.mas_equalTo(0);
    }];
    
    [self setupRefreshView];
}

- (void)beginRefreshWithCategory:(NSUInteger)category
{
    self.category = category;
    [self.tableView.mj_header beginRefreshing];
}

/**  集成刷新控件 */
- (void)setupRefreshView
{
    // 下拉刷新
    WeakObj(self)
    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
        [selfWeak loadNewData];
    }];
    
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [selfWeak loadMoreData];
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

- (void)refreshUI:(NSUInteger)total {
    
    if (total == 0) {
        
        [MBProgressHUD dismissInView:self.view];
        
        [self.tableView showEmpty:@"" desc:@"暂无消息" image:[UIImage imageNamed:@"noMessage"] block:^{
            NSLog(@"水电费水电费");
        }];
        
        [self.tableView reloadData];
    }
    else{
        [self.tableView hideStatus];
        [self.tableView reloadData];
    }
    
    NSDictionary *lastDic = self.datas.lastObject;
    if (lastDic) {
        self.msgID = [NSString stringWithFormat:@"%@",lastDic[@"MsgID"]];
        self.msgTimestamp = [lastDic[@"MsgTimestamp"] longLongValue];
    }
}

- (void)loadNewData{
    
    //1设备，2家庭，3通知
    NSDictionary *dic = @{@"MsgID":@"",@"MsgTimestamp":@(0),@"Limit":@(limit),@"Category":@(self.category)};
    
    
    [[TIoTRequestObject shared] post:AppGetMessages Param:dic success:^(id responseObject) {
        
        NSDictionary *data = responseObject[@"Data"];
        [self.datas removeAllObjects];
        [self.datas addObjectsFromArray:data[@"Msgs"]];
        [self endRefresh:NO total:[data[@"Msgs"] count]];
        [self refreshUI:self.datas.count];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)loadMoreData{
    NSDictionary *dic = @{@"MsgID":self.msgID?:@"",@"MsgTimestamp":@(self.msgTimestamp),@"Limit":@(limit),@"Category":@(self.category)};
    
    [[TIoTRequestObject shared] post:AppGetMessages Param:dic success:^(id responseObject) {
        
        NSDictionary *data = responseObject[@"Data"];
        [self endRefresh:YES total:[data[@"Msgs"] count]];
        [self.datas addObjectsFromArray:data[@"Msgs"]];
        [self refreshUI:self.datas.count];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [self.tableView.mj_footer endRefreshing];
    }];
    
}

- (void)deleteMessage:(NSInteger)index
{
    NSNumber *deleteMsgId = self.datas[index][@"MsgID"];
    NSDictionary *dic = @{@"MsgID":deleteMsgId};
    
    [[TIoTRequestObject shared] post:AppDeleteMessage Param:dic success:^(id responseObject) {
        [self.datas removeObjectAtIndex:index];
        [self refreshUI:self.datas.count];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
    
}


#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return self.datas.count;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *msgDic = self.datas[indexPath.row];
    NSInteger msgType = [msgDic[@"MsgType"] integerValue];
    if (msgType >= 100 && msgType < 200) {
        TIoTMessageText2Cell *cell = [tableView dequeueReusableCellWithIdentifier:cell3 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setMsgData:msgDic];
        return cell;
    }
    else if (msgType == 301 || msgType == 204)
    {
        TIoTMessageInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:cell2 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setMsgData:msgDic];
        cell.rejectEvent = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        return cell;
    }
    else if (msgType >= 300)
    {
        TIoTMessageTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setMsgData:msgDic];
        return cell;
    }
    
    TIoTMessageText2Cell *cell = [tableView dequeueReusableCellWithIdentifier:cell3 forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setMsgData:msgDic];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *msgDic = self.datas[indexPath.row];
    NSInteger msgType = [msgDic[@"MsgType"] integerValue];
    if (msgType >= 100 && msgType < 200) {
        return 100;
    }
    else if (msgType == 301 || msgType == 204)
    {
        return 160;
    }
    else if (msgType >= 300)
    {
        return 100;
    }
    
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteMessage:indexPath.row];
    }
}

// 修改编辑按钮文字

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - setter & getter

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = kLineColor;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        
        [_tableView registerClass:[TIoTMessageTextCell class] forCellReuseIdentifier:cell1];
        [_tableView registerNib:[UINib nibWithNibName:@"TIoTMessageInviteCell" bundle:nil] forCellReuseIdentifier:cell2];
        [_tableView registerNib:[UINib nibWithNibName:@"TIoTMessageText2Cell" bundle:nil] forCellReuseIdentifier:cell3];
    }
    
    return _tableView;
}

- (NSMutableArray *)datas
{
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

@end
