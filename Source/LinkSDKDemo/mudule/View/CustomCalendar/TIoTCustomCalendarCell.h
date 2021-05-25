//
//  TIoTCustomCalendarCell.h
//  LinkApp
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCustomCalendarCell : UICollectionViewCell
@property (nonatomic, strong) UIView *todayBackCircle; //标记
@property (nonatomic, strong) UILabel *todayLabel; //标记日期label
@end

NS_ASSUME_NONNULL_END
