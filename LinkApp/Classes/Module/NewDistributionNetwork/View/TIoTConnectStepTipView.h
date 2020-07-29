//
//  TIoTConnectStepTipView.h
//  LinkApp
//
//  Created by Sun on 2020/7/30.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTConnectStepTipView : UIView


/// 初始化TIoTConnectStepTipView 标题数据array
/// @param array 标题数据array
- (instancetype)initWithTitlesArray:(NSArray *)array;

///当前处于第几步
@property (nonatomic, assign) NSInteger step;

@end

NS_ASSUME_NONNULL_END
