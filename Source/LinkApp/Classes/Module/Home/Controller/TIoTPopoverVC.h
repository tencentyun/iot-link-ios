//
//  WCPopoverVC.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

@interface TIoTPopoverVC : UIViewController

@property (nonatomic,copy) NSArray *families;

@property (nonatomic,strong) void(^update)(NSInteger index);

@end
