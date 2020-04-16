//
//  WCEnumItem.h
//  TenextCloud
//
//  Created by Wp on 2019/12/31.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCEnumItem : UICollectionViewCell

@property (nonatomic) BOOL isSelected;
@property (nonatomic,copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
