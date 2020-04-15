//
//  WCUploadObj.h
//  TenextCloud
//
//  Created by Wp on 2019/11/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCUploadObj : NSObject

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) QCloudCOSXMLUploadObjectRequest *req;

@end

NS_ASSUME_NONNULL_END
