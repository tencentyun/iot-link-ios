//
//  WCUserInfomationTableViewCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const ID = @"TIoTUserInfomationTableViewCell";

@interface TIoTUserInfomationTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSDictionary *dic;

@end

NS_ASSUME_NONNULL_END
