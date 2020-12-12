//
//  TIoTProductWelComeConfigModel.h
//  TIoTLinkKit
//
//  Created by ccharlesren on 2020/12/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 扫码落地页面返回信息model
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTProductWelComeConfigModel : NSObject
@property (nonatomic, copy) NSString *HintMsg;
@property (nonatomic, copy) NSString *Icon;
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *RequestId;
@end

NS_ASSUME_NONNULL_END
