//
//  WCMessageInviteCell.m
//  TenextCloud
//
//  Created by Wp on 2020/3/13.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTMessageInviteCell.h"

@interface TIoTMessageInviteCell()
@property (weak, nonatomic) IBOutlet UIImageView *picView;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;

@end

@implementation TIoTMessageInviteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setMsgData:(NSDictionary *)msgData
{
    _msgData = msgData;
    self.titleL.text = msgData[@"MsgTitle"];
    self.contentL.text = msgData[@"MsgContent"];
    self.timeL.text = [NSString convertTimestampToTime:msgData[@"MsgTimestamp"] byDateFormat:@"yyyy-MM-dd HH:mm"];
    NSInteger msgType = [msgData[@"MsgType"] integerValue];
    if (msgType >= 300) {
        [self.picView setImage:[UIImage imageNamed:@"deviceDefault"]];
    }
    else if (msgType >= 200)
    {
        [self.picView setImage:[UIImage imageNamed:@"deviceDefault"]];
    }
}

- (IBAction)reject:(UIButton *)sender {
    if (self.rejectEvent) {
        self.rejectEvent();
    }
}

- (IBAction)agree:(UIButton *)sender {
    
    NSInteger msgType = [self.msgData[@"MsgType"] integerValue];
    if (msgType == 204) {
        [[TIoTRequestObject shared] post:AppJoinFamily Param:@{@"ShareToken":self.msgData[@"Attachments"][@"ShareToken"]} success:^(id responseObject) {
            [MBProgressHUD showSuccess:@"加入成功"];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [MBProgressHUD showError:reason];
        }];
    }
    else if (msgType == 301)
    {
        NSDictionary *param = @{@"ShareDeviceToken":self.msgData[@"Attachments"][@"ShareToken"],@"ProductId":self.msgData[@"ProductId"],@"DeviceName":self.msgData[@"DeviceName"]};
        [[TIoTRequestObject shared] post:AppBindUserShareDevice Param:param success:^(id responseObject) {
            [MBProgressHUD showSuccess:@"绑定成功"];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }
}

@end
