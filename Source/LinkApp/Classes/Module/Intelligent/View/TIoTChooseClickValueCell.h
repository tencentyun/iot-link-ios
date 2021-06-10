//
//  TIoTChooseClickValueCell.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTChooseClickValueCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
//@property (nonatomic, copy) NSDictionary *dataDic;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) UIImageView   *choiceImageView;
@end 

NS_ASSUME_NONNULL_END
