//
//  WCRoomCell.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCRoomCell.h"

@interface WCRoomCell()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *contentL;

@end
@implementation WCRoomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfo:(NSDictionary *)info
{
    self.name.text = info[@"RoomName"];
    self.contentL.text = [NSString stringWithFormat:@"%@个设备",info[@"DeviceNum"]];
}

- (void)setInfo2:(NSDictionary *)info2
{
    self.name.text = info2[@"title"];
    self.contentL.text = info2[@"name"];
}

@end
