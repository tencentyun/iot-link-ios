//
//  TIoTChoseFamilyCell.h
//  TIoTLinkKit
//
//

#import <UIKit/UIKit.h>
#import "FamilyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTChoseFamilyCell : UITableViewCell
+ (instancetype)cellForTableView:(UITableView *)tableView;
@property (nonatomic, strong) FamilyModel *model;
@end

NS_ASSUME_NONNULL_END
