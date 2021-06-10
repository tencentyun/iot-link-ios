//
//  TIoTProductWelComeConfigModel.h
//  TIoTLinkKit
//
//

#import <Foundation/Foundation.h>
/**
 扫码落地页面返回信息model
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTProductWelComeConfigModel : NSObject
@property (nonatomic, copy) NSString *AddDeviceHintMsg;
@property (nonatomic, copy) NSString *IconUrlAdvertise;
@property (nonatomic, copy) NSString *ChipPackage;
@property (nonatomic, copy) NSString *customizeControl;
@end

NS_ASSUME_NONNULL_END
