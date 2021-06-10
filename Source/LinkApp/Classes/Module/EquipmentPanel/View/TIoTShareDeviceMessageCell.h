//
//  TIoTShareDeviceMessageCell.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTShareDeviceMessageCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic,copy) NSDictionary *info;
@end

NS_ASSUME_NONNULL_END
