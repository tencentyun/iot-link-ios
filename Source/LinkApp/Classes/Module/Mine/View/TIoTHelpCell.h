//
//  WCHelpCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTHelpCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSDictionary *dic;

@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
