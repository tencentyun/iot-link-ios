//
//  TIoTSettingIntelligentNameVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SaveIntelligentNameBlock)(NSString *name);
@interface TIoTSettingIntelligentNameVC : UIViewController
@property (nonatomic, copy) SaveIntelligentNameBlock saveIntelligentNameBlock;
@property (nonatomic, copy) NSString *defaultSceneString;
@end

NS_ASSUME_NONNULL_END
