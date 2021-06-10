//
//  WCMessageChildVC.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>
#import "TIoTRefreshHeader.h"


@interface TIoTMessageChildVC : UIViewController

@property (nonatomic, strong) UITableView *tableView;
- (void)beginRefreshWithCategory:(NSUInteger)category;

@end

