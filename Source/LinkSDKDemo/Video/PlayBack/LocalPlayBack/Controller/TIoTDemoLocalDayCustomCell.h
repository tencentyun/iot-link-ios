//
//  TIoTDemoPlaybackCustomCell.h
//  LinkSDKDemo
//
//

#import <UIKit/UIKit.h>
#import "TIoTDemoLocalDayTimeListModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TIoTDemoLocalDayCustomCellDelegate <NSObject>
- (void)downLoadResWithModel:(TIoTDemoLocalFileModel *)model;
@end


@interface TIoTDemoLocalDayCustomCell : UITableViewCell
@property (nonatomic, strong) TIoTDemoLocalFileModel *model;
@property (nonatomic, weak)id<TIoTDemoLocalDayCustomCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
