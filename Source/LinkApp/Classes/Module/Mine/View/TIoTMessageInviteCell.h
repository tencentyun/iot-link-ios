//
//  WCMessageInviteCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>


@interface TIoTMessageInviteCell : UITableViewCell

@property (nonatomic,strong) NSDictionary *msgData;

@property (nonatomic,strong) void (^rejectEvent) (void);

@end

