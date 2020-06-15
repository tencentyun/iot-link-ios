//
//  QCRequestBuilder.h
//  QCApiClient
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCRequestBuilder : NSObject

- (instancetype)initWtihAction:(NSString *)action params:(NSDictionary *)params useToken:(BOOL)useToken;

@property (nonatomic, strong, readonly) NSDictionary *build;

@end

NS_ASSUME_NONNULL_END
