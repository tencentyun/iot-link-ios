//
//  TIoTConfigInputView.h
//  LinkApp
//
//  Created by Sun on 2020/7/29.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTConfigInputView : UIView


/// 初始化TIoTConfigInputView 左侧标题 右侧是否有按钮
/// @param title 左侧标题
/// @param placeholder 如果可以输入的占位字符
/// @param haveButton 右侧是否有按钮
- (instancetype)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder haveButton:(BOOL)haveButton;

/// 输入文本内容
@property (nonatomic, strong) NSString *inputText;

/// 右侧按钮响应事件
@property (nonatomic, copy) void (^buttonAction)(void);
/// 文本框输入响应事件
@property (nonatomic, copy) void (^textChangedAction)(NSString *changedText);

@end

NS_ASSUME_NONNULL_END
