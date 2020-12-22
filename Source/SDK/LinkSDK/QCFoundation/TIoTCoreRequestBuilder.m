//
//  QCRequestBuilder.m
//  QCApiClient
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "TIoTCoreRequestBuilder.h"
#import "TIoTCoreAppEnvironment.h"

@implementation TIoTCoreRequestBuilder

- (instancetype)initWtihAction:(NSString *)action params:(NSDictionary *)params useToken:(BOOL)useToken
{
    self = [super init];
    if (self) {
        _build = @{@"useToken":@(useToken),@"action":action,@"params":params};
    }
    return self;
}
@end
