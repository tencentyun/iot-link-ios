//
//  WCRepeatVC.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>



@interface TIoTCoreRepeatVC : UITableViewController

@property (nonatomic,copy) NSString *days;
@property (nonatomic,strong) void (^repeatResult)(NSArray *repeats);

@end

