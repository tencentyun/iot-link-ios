//
//  QCObject.h
//  QCDeviceCenter
//
//  Created by Wp on 2019/12/5.
//  Copyright © 2019 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCResult : NSObject

@property (nonatomic,assign) NSInteger code;//code为0成功
@property (nonatomic,copy) NSString *signatureInfo;
@property (nonatomic,copy) NSString *errMsg;

@end

NS_ASSUME_NONNULL_END
