//
//  MessageVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/9.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "MessageVC.h"

@interface MessageVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *messages;
@end

@implementation MessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getMessagesWithCategory:1];
}


- (IBAction)segChanged:(UISegmentedControl *)sender {
    [self getMessagesWithCategory:sender.selectedSegmentIndex + 1];//1设备，2家庭，3通知
}


#pragma mark -

- (void)getMessagesWithCategory:(NSUInteger)category
{
    [[QCMessageSet shared] getMessagesWithMsgId:@"" msgTimestamp:0 limit:20 category:category success:^(id  _Nonnull responseObject) {
        NSDictionary *data = responseObject[@"Data"];
        self.messages = data[@"Msgs"];
        [self.tableView reloadData];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}


#pragma mark - TableView

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *msgDic = self.messages[indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rpk"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"rpk"];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.textLabel.text = msgDic[@"MsgTitle"];
    cell.detailTextLabel.text = msgDic[@"MsgContent"];
    
    
    NSInteger msgType = [msgDic[@"MsgType"] integerValue];
    if (msgType == 204 || msgType == 301) {
        UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 16)];
        tip.text = @"可点击同意";
        tip.font = [UIFont systemFontOfSize:12];
        tip.textColor = [UIColor systemRedColor];
        [cell.contentView addSubview:tip];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *message = self.messages[indexPath.row];
    NSInteger msgType = [message[@"MsgType"] integerValue];
    if (msgType == 204)
    {
        [[QCFamilySet shared] joinFamilyWithShareToken:message[@"Attachments"][@"ShareToken"] success:^(id  _Nonnull responseObject) {
            
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
            
        }];
    }
    else if (msgType == 301)
    {
        [[QCDeviceSet shared] bindUserShareDeviceWithProductId:message[@"ProductId"] deviceName:message[@"DeviceName"] shareDeviceToken:message[@"Attachments"][@"ShareToken"] success:^(id  _Nonnull responseObject) {
            
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
            
        }];
    }
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
        
    }
}


// 修改编辑按钮文字

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

@end
