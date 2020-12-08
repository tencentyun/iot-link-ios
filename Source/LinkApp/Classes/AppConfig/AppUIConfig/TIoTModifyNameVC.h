//
//  TIoTModifyNameVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/12/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ModifyType) {
    ModifyTypeNickName,
    ModifyTypeDeviceName,
    ModifyTypeFamilyName, //修改家庭名称
};

typedef void(^ModifyNameBlock)(NSString *name);

@interface TIoTModifyNameVC : UIViewController
@property (nonatomic, strong)NSString * titleText;
@property (nonatomic, strong)NSString * defaultText;
@property (nonatomic, assign)ModifyType modifyType;
@property (nonatomic, copy) ModifyNameBlock modifyNameBlock;
@end

NS_ASSUME_NONNULL_END
