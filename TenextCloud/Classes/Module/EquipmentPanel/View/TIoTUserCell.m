//
//  WCUserCell.m
//  TenextCloud
//
//  Created by Wp on 2020/1/11.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCUserCell.h"

@interface WCUserCell()
@property (weak, nonatomic) IBOutlet UIImageView *header;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;


@end
@implementation WCUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfo:(NSDictionary *)info
{
    _info = info;
    [self.header setImageWithURLStr:info[@"Avatar"] placeHolder:@"userDefalut"];
    self.nameL.text = info[@"NickName"];
    self.timeL.text = [NSString convertTimestampToTime:info[@"BindTime"] byDateFormat:@"yyyy-MM-dd HH:mm"];
}

@end
