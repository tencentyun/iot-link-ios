//
//  WCRoomsVC.h
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCRoomsVC : UIViewController

@property (nonatomic,copy) NSString *familyId;
@property (nonatomic) BOOL isOwner;//是否所有者

@end

NS_ASSUME_NONNULL_END
