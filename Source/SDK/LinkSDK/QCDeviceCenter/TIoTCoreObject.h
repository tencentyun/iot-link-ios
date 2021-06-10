//
//  QCObject.h
//  QCDeviceCenter
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreResult : NSObject

@property (nonatomic,assign) NSInteger code;//code为0成功
@property (nonatomic,copy) NSString *signatureInfo;
@property (nonatomic,copy) NSString *errMsg;

@end

NS_ASSUME_NONNULL_END
