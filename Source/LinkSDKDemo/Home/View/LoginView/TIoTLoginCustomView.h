//
//  TIoTLoginCustomView.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/24.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTLoginCustomView : UIView
//AccessID
@property (nonatomic, strong) UITextField *accessID;
//AccessToken
@property (nonatomic, strong) UITextField *accessToken;
//ProductID
@property (nonatomic, strong) UITextField *productID;

@property (nonatomic, strong) NSString *secretIDString;
@property (nonatomic, strong) NSString *secretKeyString;
@property (nonatomic, strong) NSString *productIDString;
@end

NS_ASSUME_NONNULL_END
