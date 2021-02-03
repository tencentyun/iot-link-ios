//
//  TIoTAlertCustomView.h
//  LinkApp
//
//  Created by ccharlesren on 2021/1/26.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/*
 自定义alertView 弹框
 */
typedef NS_ENUM(NSInteger, TIoTAlertCustomViewContentType) {
    TIoTAlertViewContentTypeDatePick,
    TIoTAlertCustomViewContentTypeText,
};

///弹框取消按钮block
typedef void(^TIoTAlertCustomViewCancelBlock)(void);
///弹框确定按钮block
typedef void(^TIoTAlertCustomViewConfirmBlock)(NSString *timeString);
///TIoTAlertCustomViewContentTypeText类型下，隐私政策点击跳转block
typedef void(^TIoTAlertCustomViewPrivatePolicyBlock)(void);

@interface TIoTAlertCustomView : UIView

/// 取消按钮block
@property (nonatomic, copy) TIoTAlertCustomViewCancelBlock cancelBlock;

/// 确认按钮block
@property (nonatomic, copy) TIoTAlertCustomViewConfirmBlock confirmBlock;

/// 隐私政策跳转block
@property (nonatomic, copy) TIoTAlertCustomViewPrivatePolicyBlock privatePolicyBlock;


/// 设置弹框类型和消失手势
/// @param contentType 弹框类型
/// @param hideTap 隐藏弹框手势
- (void)alertContentType:(TIoTAlertCustomViewContentType)contentType isAddHideGesture:(BOOL)hideTap;

/// 设置弹框内容
/// @param titleString title 内容
/// @param cancelTitle 取消按钮 内容
/// @param confirmTitle  确认按钮 内容
- (void)alertCustomViewTitleMessage:(NSString *)titleString cancelBtnTitle:(NSString *)cancelTitle confirmBtnTitle:(NSString *)confirmTitle; 
@end

NS_ASSUME_NONNULL_END
