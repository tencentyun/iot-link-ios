//
//  TIoTSearchLocationVC.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
@class TIoTPoisModel;

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIoTSearchLocatonBlcok)(TIoTPoisModel *posiModel);

@interface TIoTSearchLocationVC : UIViewController
@property (nonatomic, strong) TIoTSearchLocatonBlcok chooseLocBlcok;
@end

NS_ASSUME_NONNULL_END
