//
//  TIoTDemoCloudStoreFullVideoUrl.h
//  LinkSDKDemo
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDemoCloudStoreFullVideoUrl : NSObject
@property (nonatomic, copy) NSString *SignedVideoURL;
@end


@interface TIoTDemoCloudStoreMJPEGUrl : NSObject
@property (nonatomic, copy) NSString *AudioStream;
@property (nonatomic, copy) NSString *VideoStream;
@property (nonatomic, copy) NSString *StartTime;
@end
NS_ASSUME_NONNULL_END
