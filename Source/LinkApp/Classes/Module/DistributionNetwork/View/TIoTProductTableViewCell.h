//
//  WCProductTableViewCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTProductTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSDictionary *dic;
@property (nonatomic, copy) void (^connectEvent)(void);

@end

NS_ASSUME_NONNULL_END
