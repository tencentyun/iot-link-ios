//
//  TIoTAutoIntellSettingCustomTimeCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 自定义时间item
 */
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AutoRepeatTimeType) {
    AutoRepeatTimeTypeTimerCustom,
    AutoRepeatTimeTypeTimePeriod,
};

@interface TIoTAutoIntellSettingCustomTimeCell : UICollectionViewCell
@property (nonatomic, copy) NSString *itemString;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) AutoRepeatTimeType autoRepeatTimeType;
@end

NS_ASSUME_NONNULL_END
