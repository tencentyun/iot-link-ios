//
//  WCQCloudCOSXMLManage.h
//  TenextCloud
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ggBlock)(NSArray *);

@interface TIoTQCloudCOSXMLManage : NSObject

- (void)getSignature:(NSArray<UIImage *> *)images com:(ggBlock)block;

@end

NS_ASSUME_NONNULL_END
