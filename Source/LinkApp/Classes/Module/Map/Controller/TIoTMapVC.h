//
//  TIoTMapVC.h
//  LinkApp
//
//

#import "TIoTBaseMapViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIoTMapAddrssParseBlock)(NSString *address, NSString *addressJson);

@interface TIoTMapVC : TIoTBaseMapViewController
@property (nonatomic, strong) NSString *addressString;
@property (nonatomic, copy) TIoTMapAddrssParseBlock addressBlcok;
@end

NS_ASSUME_NONNULL_END
