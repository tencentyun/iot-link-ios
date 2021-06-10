//
//  WCRepeatVC.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>



@interface TIoTRepeatVC : UITableViewController

@property (nonatomic,copy) NSString *days;
@property (nonatomic,strong) void (^repeatResult)(NSArray *repeats);

@end

