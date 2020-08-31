//
//  WCOptionalView.h
//  TenextCloud
//
//  Created by Wp on 2020/1/16.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTOptionalView : UIView

@property (nonatomic, copy) void (^selected)(NSInteger index);
@property (nonatomic, copy) void (^doneAction)(void);
@property (nonatomic, copy) NSString *currentValue;//当前选中
@property (nonatomic,copy) NSArray *titles;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
