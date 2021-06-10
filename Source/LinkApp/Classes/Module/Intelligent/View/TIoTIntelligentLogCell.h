//
//  TIoTIntelligentLogCell.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
#import "TIoTIntelligentLogModel.h"

typedef void(^IntelligentLogDetailBlock)(BOOL isShow,NSIndexPath * _Nullable selectedIndex);

NS_ASSUME_NONNULL_BEGIN

@interface TIoTIntelligentLogCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) IntelligentLogDetailBlock logDetailBlock;
@property (nonatomic, strong) NSIndexPath *selectedIndex;

@property (nonatomic, strong) TIoTLogMsgsModel *msgModel;
@property (nonatomic, strong) NSArray *resultListModel;

@end

NS_ASSUME_NONNULL_END
