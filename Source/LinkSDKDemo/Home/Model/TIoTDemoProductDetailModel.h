//
//  TIoTDemoProductDetailModel.h
//  LinkSDKDemo
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 产品详情model
 */
@class TIoTDemoProductDetailData;

@interface TIoTDemoProductDetailModel : NSObject
@property (nonatomic, strong) TIoTDemoProductDetailData *Data;
@end


@interface TIoTDemoProductDetailData: NSObject
@property (nonatomic, copy) NSString *ProductId;
@property (nonatomic, copy) NSString *ProductName;
@property (nonatomic, copy) NSString *DeviceType;
@property (nonatomic, copy) NSString *EncryptionType;
@property (nonatomic, strong) NSArray *Features;
@property (nonatomic, copy) NSString *ChipOs;
@property (nonatomic, copy) NSString *ChipManufactureId;
@property (nonatomic, copy) NSString *ChipId;
@property (nonatomic, copy) NSString *ProductDescription;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, copy) NSString *UpdateTime;
@end


NS_ASSUME_NONNULL_END
