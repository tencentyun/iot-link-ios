//
//  UIView+StatusCoast.h
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/13.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 这里做各种网络状态下，UI要求的无数据页面的友好提示(断网，网络出错，无数据，H5的等待页面等)
@interface UIView (StatusCoast)

- (void)showLoading;

- (void)showLoadFailureReloadBlock:(void(^)(void))reloadEvent;

- (void)hideStatus;

/**
 展示空数据视图

 @param title 按钮标题（没有按钮则不传）
 @param desc 描述文本
 @param image 图片
 @param block 按钮点击回调
 */
- (void)showEmpty:(NSString *)title desc:(NSString *)desc image:(UIImage *)image block:(void(^)(void))block;
- (void)showEmpty2:(NSString *)title desc:(NSString *)desc image:(UIImage *)image block:(void(^)(void))block;

@end




@interface XDPLoadingStatusView : UIView

- (void)startLoading;

- (void)stopLoading;

@property (nonatomic , copy) NSString *text;


@end

@interface XDPLoadFailureView : UIView

@property (nonatomic , copy) void(^reloadEvent)(void);

@property (nonatomic , copy) NSString *text;

@end


@interface XDPEmptyView : UIView

@property (nonatomic , copy) void(^operation)(void);
- (void)showImage:(UIImage *)image desc:(NSString *)desc title:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
