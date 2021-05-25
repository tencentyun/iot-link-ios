//
//  WCFamilyInfoCell.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTCoreFamilyInfoCell.h"

@interface TIoTCoreFamilyInfoCell()
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;

@end
@implementation TIoTCoreFamilyInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfo:(NSDictionary *)info
{
    self.nameL.text = info[@"title"];
    self.contentL.text = info[@"name"];
}

@end
