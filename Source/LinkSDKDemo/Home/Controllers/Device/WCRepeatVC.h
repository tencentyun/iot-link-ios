//
//  WCRepeatVC.h
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface WCRepeatVC : UITableViewController

@property (nonatomic,copy) NSString *days;
@property (nonatomic,strong) void (^repeatResult)(NSArray *repeats);

@end

