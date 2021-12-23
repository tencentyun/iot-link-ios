//
//  TIoTAreaNetDetectionModel.h
//  LinkSDKDemo
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TIoTDetectionParamsModel;

@interface TIoTAreaNetDetectionModel : NSObject
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *clientToken;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, strong) TIoTDetectionParamsModel *params;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *status;
@end

@interface TIoTDetectionParamsModel : NSObject
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *port;
@end

NS_ASSUME_NONNULL_END
