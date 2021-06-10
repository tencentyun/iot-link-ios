//
//  WCUserCell.m
//  TenextCloud
//
//

#import "TIoTUserCell.h"

@interface TIoTUserCell()
@property (weak, nonatomic) IBOutlet UIImageView *header;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;


@end
@implementation TIoTUserCell

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
