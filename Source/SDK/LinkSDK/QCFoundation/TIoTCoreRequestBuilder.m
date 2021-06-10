//
//  QCRequestBuilder.m
//  QCApiClient
//
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
