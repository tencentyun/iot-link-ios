//
//  WCSlideView.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/23.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCSlider : UISlider

@end

@interface WCSlideView : UIView

@property (nonatomic) BOOL isAction;//控制删除动作按钮
@property (nonatomic, copy) void (^deleteTap)(void);

@property (nonatomic, copy) NSString *showValue;
@property (nonatomic, copy) NSDictionary *dic;
@property (nonatomic, copy) void (^updateData)(NSDictionary *dataDic);
- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
