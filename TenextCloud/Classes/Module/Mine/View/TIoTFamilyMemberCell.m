//
//  WCFamilyMemberCell.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTFamilyMemberCell.h"

@interface TIoTFamilyMemberCell()
@property (weak, nonatomic) IBOutlet UIImageView *headerImg;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *authorL;

@end
@implementation TIoTFamilyMemberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfo:(NSDictionary *)info
{
    [self.headerImg setImageWithURLStr:info[@"Avatar"] placeHolder:@"userDefalut"];
    self.nameL.text = info[@"NickName"];
    self.authorL.text = [info[@"Role"] integerValue] == 1 ? @"所有者" : @"成员";
}

@end
