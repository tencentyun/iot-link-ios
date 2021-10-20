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

NS_ASSUME_NONNULL_END
