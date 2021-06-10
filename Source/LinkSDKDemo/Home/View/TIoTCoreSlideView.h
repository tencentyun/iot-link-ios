//
//  WCSlideView.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreSlider : UISlider

@end

@interface TIoTCoreSlideView : UIView

@property (nonatomic) BOOL isAction;//控制删除动作按钮
@property (nonatomic, copy) void (^deleteTap)(void);

@property (nonatomic, copy) NSString *showValue;
@property (nonatomic, copy) NSDictionary *dic;
@property (nonatomic, copy) void (^updateData)(NSDictionary *dataDic);
- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
