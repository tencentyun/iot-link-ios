//
//  TIoTConfigResultViewController.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTConfigResultViewController : UIViewController


/// 初始化TIoTConfigResultViewController
/// @param configHardwareStyle 配网类型
/// @param success 配网成功or失败
- (instancetype)initWithConfigHardwareStyle:(TIoTConfigHardwareStyle)configHardwareStyle success:(BOOL)success devieceData:(NSDictionary *)devieceData;

@end

NS_ASSUME_NONNULL_END
