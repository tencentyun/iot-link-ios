//
//  TIoTLLSyncDeviceCell.h
//  LinkApp
//
//  Created by eagleychen on 2021/7/20.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface TIoTLLSyncDeviceCell : UICollectionViewCell
@property (nonatomic, copy) NSString *itemString;
@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
