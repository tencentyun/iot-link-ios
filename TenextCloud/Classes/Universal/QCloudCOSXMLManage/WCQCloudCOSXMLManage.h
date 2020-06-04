//
//  WCQCloudCOSXMLManage.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/9.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ggBlock)(NSArray *);

@interface WCQCloudCOSXMLManage : NSObject

- (void)getSignature:(NSArray<UIImage *> *)images com:(ggBlock)block;

@end

NS_ASSUME_NONNULL_END
