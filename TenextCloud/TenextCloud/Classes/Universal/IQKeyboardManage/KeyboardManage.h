//
//  IQKeyboardManage.h
//  SEEXiaodianpu
//
//  Created by houxingyu on 2019/2/16.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyboardManage : NSObject

/**
 注册全局键盘事件。ps：如果文本框父视图不是scrollview，请禁用。否则可能会导致黑边问题
 */
+ (void)registerIQKeyboard;

/**
 禁用全局键盘事件
 */
+ (void)disableIQKeyboard;

/**
 打开全局键盘事件
 */
+ (void)openIQKeyboard;

@end

NS_ASSUME_NONNULL_END
