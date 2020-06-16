//
//  QCRequestBuilder.m
//  QCApiClient
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "QCRequestBuilder.h"
#import "WCAppEnvironment.h"

@implementation QCRequestBuilder

- (instancetype)initWtihAction:(NSString *)action params:(NSDictionary *)params useToken:(BOOL)useToken
{
    self = [super init];
    if (self) {
        _build = @{@"useToken":@(useToken),@"action":action,@"params":params};
    }
    return self;
}
@end
