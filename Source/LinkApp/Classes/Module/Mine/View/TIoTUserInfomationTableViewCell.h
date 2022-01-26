//
//  WCUserInfomationTableViewCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TIoTUserInfomationTableViewCellDelegate <NSObject>

- (void)clickCopyUserid;

@end

static NSString * const ID = @"TIoTUserInfomationTableViewCell";

@interface TIoTUserInfomationTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSDictionary *dic;

@property (nonatomic, strong) UISwitch *arrowSwitch;
@property (nonatomic) void (^authSwitch)(BOOL open,UISwitch *switchControl);
@property (nonatomic, weak)id<TIoTUserInfomationTableViewCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
