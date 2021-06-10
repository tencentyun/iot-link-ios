//
//  WCUploadObj.h
//  TenextCloud
//
//

#import <Foundation/Foundation.h>
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTUploadObj : NSObject

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) QCloudCOSXMLUploadObjectRequest *req;

@end

NS_ASSUME_NONNULL_END
