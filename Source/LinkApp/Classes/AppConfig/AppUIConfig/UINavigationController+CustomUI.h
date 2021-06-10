//
//  UINavigationController+CustomUI.h
//  SEEXiaodianpu
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (CustomUI)<UINavigationControllerDelegate,UIGestureRecognizerDelegate>


// 边缘右滑手势
- (UIScreenEdgePanGestureRecognizer *)xdpPopGes;

@end

NS_ASSUME_NONNULL_END
