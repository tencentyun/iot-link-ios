//
//  WCActionTypeTableViewCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTActionTypeTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSString *nameStr;

@end

NS_ASSUME_NONNULL_END
