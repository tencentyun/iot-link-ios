//
//  TIoTChoseFamilyVC.h
//  TIoTLinkKit
//
//  Created by ccharlesren on 2020/12/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 选择家庭页面（落地页扫码后）
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTChoseFamilyVC : UIViewController
@property (nonatomic, copy) NSString *productID; //产品ID
@property (nonatomic, copy) NSString *roomId;
@end

NS_ASSUME_NONNULL_END
