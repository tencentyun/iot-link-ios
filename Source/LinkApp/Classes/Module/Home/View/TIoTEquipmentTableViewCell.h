//
//  WCEquipmentTableViewCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTEquipmentTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, copy) NSDictionary *dataDic;

@end

NS_ASSUME_NONNULL_END
