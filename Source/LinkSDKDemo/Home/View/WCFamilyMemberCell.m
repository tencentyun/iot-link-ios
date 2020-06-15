//
//  WCFamilyMemberCell.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCFamilyMemberCell.h"
#import <UIImageView+WebCache.h>

@interface WCFamilyMemberCell()
@property (weak, nonatomic) IBOutlet UIImageView *headerImg;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *authorL;

@end
@implementation WCFamilyMemberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfo:(NSDictionary *)info
{
    [self.headerImg sd_setImageWithURL:[NSURL URLWithString:info[@"Avatar"]]];
    self.nameL.text = info[@"NickName"];
    self.authorL.text = [info[@"Role"] integerValue] == 1 ? @"所有者" : @"成员";
}

@end
