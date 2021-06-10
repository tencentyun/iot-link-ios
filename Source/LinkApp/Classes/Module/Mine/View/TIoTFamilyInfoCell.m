//
//  WCFamilyInfoCell.m
//  TenextCloud
//
//

#import "TIoTFamilyInfoCell.h"

@interface TIoTFamilyInfoCell()
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UIImageView *mineArrow;

@end
@implementation TIoTFamilyInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfo:(NSDictionary *)info
{
    self.nameL.text = info[@"title"];
    self.contentL.text = info[@"name"];
    
    if ([info.allKeys containsObject:@"addresJson"]) {
        if (![NSString isNullOrNilWithObject:info[@"addresJson"]]) {
            NSDictionary *addJsonDic =  [NSString jsonToObject:info[@"addresJson"]?:@""]?:@{};
            if (![NSString isNullOrNilWithObject:addJsonDic[@"name"]]) {
                self.contentL.text = addJsonDic[@"name"]?:@"";
            }else {
                self.contentL.text = addJsonDic[@"address"]?:@"";
            }
        }
    }
    
    if ([info.allKeys containsObject:@"RoomCount"]) {
        if (![NSString isNullOrNilWithObject:info[@"RoomCount"]]) {
            self.contentL.text = [NSString stringWithFormat:@"%@个房间",info[@"RoomCount"],NSLocalizedString(@"XXX_rooms", @"个房间")];
        }
    }
    

    if ([info.allKeys containsObject:@"Role"]) {
        NSString  *roleString = [NSString stringWithFormat:@"%@",info[@"Role"]];
        if (![NSString isNullOrNilWithObject:roleString]) {
            if ([roleString intValue] == 1) {
                self.mineArrow.hidden = NO;
            }else {
                self.mineArrow.hidden = YES;
            }
        }
    }
    
}

@end
