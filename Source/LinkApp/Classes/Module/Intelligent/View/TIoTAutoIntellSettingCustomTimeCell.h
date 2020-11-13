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

@interface TIoTAutoIntellSettingCustomTimeCell : UICollectionViewCell
@property (nonatomic, copy) NSString *itemString;
@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
