//
//  TIoTAccessIDPickerView.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/24.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIotPickerAccessIDBlock)(NSString *accessIDString);

@interface TIoTAccessIDPickerView : UIView

@property (nonatomic, copy) TIotPickerAccessIDBlock accessIDStringBlock;
- (void)removeView;
@end

NS_ASSUME_NONNULL_END
