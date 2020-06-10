//
//  WCPanelVC.h
//  TenextCloud
//
//  Created by Wp on 2020/1/2.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface WCCollectionView : UICollectionView

@end

NS_ASSUME_NONNULL_BEGIN

@interface WCPanelVC : UIViewController

@property (nonatomic, copy) NSString *productId;
@property (nonatomic, copy) NSString *deviceName;

@property (nonatomic, strong) NSMutableDictionary *deviceDic;

@property (nonatomic) BOOL isOwner;//是否所有者


@end

NS_ASSUME_NONNULL_END
