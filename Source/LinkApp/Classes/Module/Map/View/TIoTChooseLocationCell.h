//
//  TIoTChooseLocationCell.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
#import "TIoTMapLocationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTChooseLocationCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) TIoTPoisModel *locationModel;
@property (nonatomic, assign) BOOL isChoosed;
@end

NS_ASSUME_NONNULL_END
