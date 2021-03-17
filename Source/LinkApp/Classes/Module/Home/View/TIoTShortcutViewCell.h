//
//  TIoTShortcutViewCell.h
//  LinkApp
//
//  Created by ccharlesren on 2021/3/15.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTShortcutViewCell : UICollectionViewCell
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, copy) NSString *iconURLString;
@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *propertyValue;
@end

NS_ASSUME_NONNULL_END
