//
//  WCMessageChildVC.h
//  TenextCloud
//
//  Created by Wp on 2020/3/2.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCRefreshHeader.h"


@interface WCMessageChildVC : UIViewController

@property (nonatomic, strong) UITableView *tableView;
- (void)beginRefreshWithCategory:(NSUInteger)category;

@end

