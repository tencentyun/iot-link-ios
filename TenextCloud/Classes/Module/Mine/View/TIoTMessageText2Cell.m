//
//  WCMessageText2Cell.m
//  TenextCloud
//
//  Created by Wp on 2020/3/13.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCMessageText2Cell.h"

@interface WCMessageText2Cell()
@property (weak, nonatomic) IBOutlet UIImageView *picView;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;

@end
@implementation WCMessageText2Cell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setMsgData:(NSDictionary *)msgData
{
    self.titleL.text = msgData[@"MsgTitle"];
    self.contentL.text = msgData[@"MsgContent"];
    self.timeL.text = [NSString convertTimestampToTime:msgData[@"MsgTimestamp"] byDateFormat:@"yyyy-MM-dd HH:mm"];
    [self.picView setImage:[UIImage imageNamed:@"deviceDefault"]];
}

@end
