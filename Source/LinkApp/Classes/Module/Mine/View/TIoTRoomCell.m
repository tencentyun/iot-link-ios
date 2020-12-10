//
//  WCRoomCell.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTRoomCell.h"

@interface TIoTRoomCell()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UIImageView *mineArrow;

@end
@implementation TIoTRoomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsOwer:(BOOL)isOwer {
    _isOwer = isOwer;
    if (isOwer == YES) {
        self.mineArrow.hidden = NO;
    }else {
        self.mineArrow.hidden = YES;
    }
}

- (void)setInfo:(NSDictionary *)info
{
    self.name.text = info[@"RoomName"];
    self.contentL.text = [NSString stringWithFormat:@"%@个设备",info[@"DeviceNum"]];
    if (self.isOwer == YES) {
        self.mineArrow.hidden = NO;
    }else {
        self.mineArrow.hidden = YES;
    }
}

- (void)setInfo2:(NSDictionary *)info2
{
    self.name.text = info2[@"title"];
    self.contentL.text = info2[@"name"];
}

@end
