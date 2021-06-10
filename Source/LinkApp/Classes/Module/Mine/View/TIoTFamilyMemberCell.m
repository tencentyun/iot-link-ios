//
//  WCFamilyMemberCell.m
//  TenextCloud
//
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
    self.authorL.text = [info[@"Role"] integerValue] == 1 ? NSLocalizedString(@"role_owner", @"所有者") : NSLocalizedString(@"role_member", @"成员") ;
}

@end
