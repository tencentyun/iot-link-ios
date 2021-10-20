//
//  TIoTFirmwareModel.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTFirmwareModel : NSObject
@property (nonatomic, copy) NSString *CurrentVersion;
@property (nonatomic, copy) NSString *DstVersion;
@end

@interface TIoTFirmwareUpdateStatusModel : NSObject
@property (nonatomic, copy) NSString *DstVersion;
@property (nonatomic, copy) NSString *ErrMsg;
@property (nonatomic, copy) NSString *OriVersion;
@property (nonatomic, copy) NSString *Percent;
@property (nonatomic, copy) NSString *Status;
@end

@interface TIoTFirmwareOTAInfoModel : NSObject
@property (nonatomic, copy) NSString *FirmwareURL;
@property (nonatomic, copy) NSString *TargetVersion; //新version
@property (nonatomic, copy) NSString *UploadVersion; //原始version
@end
NS_ASSUME_NONNULL_END
