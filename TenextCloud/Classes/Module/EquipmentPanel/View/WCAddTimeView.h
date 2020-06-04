//
//  WCAddTimeView.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WCAddTimeDelegate <NSObject>

//保存
- (void)saveData;

@end

@interface WCAddTimeView : UIView

@property (nonatomic, weak) id<WCAddTimeDelegate>delegate;

- (void)showView;

@end

NS_ASSUME_NONNULL_END
