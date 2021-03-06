//
//  TIoTAutoAddManualIntellListCell.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

/**
 自动智能-添加任务中-选择手动cell
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTAutoAddManualIntellListCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSString *manualNameString;
@property (nonatomic, assign) BOOL isChoosed;
@property (nonatomic, assign) bool isEditType;
@end

NS_ASSUME_NONNULL_END
