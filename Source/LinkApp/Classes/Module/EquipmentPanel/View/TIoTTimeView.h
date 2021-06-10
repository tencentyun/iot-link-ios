//
//  WCTimeView.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTimeView : UIView

@property (nonatomic, copy) void (^updateData)(NSDictionary *dataDic);
@property (nonatomic, copy) NSDictionary *dic;
- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
