//
//  XDPRefreshFooter.h
//  SEEXiaodianpu
//
//

#import "MJRefreshAutoFooter.h"
#define kXDPRefreshFooterFailure NSLocalizedString(@"loadFailure_reload", @"加载失败，点击重新加载")
NS_ASSUME_NONNULL_BEGIN

@interface TIoTRefreshFooter : MJRefreshAutoFooter

- (void)showFailStatus;

- (void)setTitle:(NSString *)title forState:(MJRefreshState)state;

- (NSString *)titleForState:(MJRefreshState)state;

@end

NS_ASSUME_NONNULL_END
