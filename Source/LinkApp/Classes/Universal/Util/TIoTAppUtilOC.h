//
//  TIoTAppUtil.h
//  LinkApp
//
//  Created by eagleychen on 2020/11/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTAppUtilOC : NSObject 
+ (void)checkNewVersion;
+ (void)handleOpsenUrl:(NSString *)result;
@end

NS_ASSUME_NONNULL_END
