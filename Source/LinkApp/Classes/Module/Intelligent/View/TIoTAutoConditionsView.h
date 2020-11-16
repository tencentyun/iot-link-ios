//
//  TIoTAutoConditionsView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/15.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AutoChooseConditionBlock)(NSString *conditionContent);

@interface TIoTAutoConditionsView : UIView
@property (nonatomic, copy) AutoChooseConditionBlock chooseConditionBlock;
@end

NS_ASSUME_NONNULL_END
