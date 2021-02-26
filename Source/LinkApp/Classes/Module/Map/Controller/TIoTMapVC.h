//
//  TIoTMapVC.h
//  LinkApp
//
//  Created by ccharlesren on 2021/3/1.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTBaseMapViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIoTMapAddrssParseBlock)(NSString *address);

@interface TIoTMapVC : TIoTBaseMapViewController
@property (nonatomic, strong) NSString *addressString;
@property (nonatomic, copy) TIoTMapAddrssParseBlock addressBlcok;
@end

NS_ASSUME_NONNULL_END
