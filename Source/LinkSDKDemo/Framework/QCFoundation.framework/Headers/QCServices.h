//
//  QCApiConfiguration.h
//  QCApiClient
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface QCServices : NSObject

+ (instancetype)shared;

- (void)setAppKey:(NSString *)appkey;


/// appKey
@property (nonatomic , copy, readonly) NSString *appKey;


/// 打印开关
@property (nonatomic, assign) BOOL logEnable;

@end

NS_ASSUME_NONNULL_END
