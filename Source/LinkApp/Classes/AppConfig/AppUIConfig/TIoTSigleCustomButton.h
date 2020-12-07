//
//  TIoTSigleCustomButton.h
//  LinkApp
//
//  Created by ccharlesren on 2020/12/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SingleCustomButton) {
    SingleCustomButtonConfirm,
    SingleCustomButtonCenale,
};

typedef void(^SingleButtonActioin)(void);

@interface TIoTSigleCustomButton : UIView

@property (nonatomic, copy)SingleButtonActioin singleAction;
@property (nonatomic, assign) CGFloat kLeftRightPadding;

- (void)singleCustomButtonStyle:(SingleCustomButton)type withTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
