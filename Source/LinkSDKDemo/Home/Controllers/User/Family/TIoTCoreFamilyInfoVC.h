//
//  WCFamilyInfoVC.h
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCFamilyInfoVC : UIViewController

@property (nonatomic,copy) NSDictionary *familyInfo;
@property (nonatomic)  NSInteger familyCount;//家庭数量，最后一个家庭不可删除

@end

NS_ASSUME_NONNULL_END
