//
//  TIoTVideoDistributionNetModel.h
//  Alamofire
//
//  Created by ccharlesren on 2020/12/17.
//

#import <Foundation/Foundation.h>
/*
 Video 配网model
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTVideoDistributionNetModel : NSObject
@property (nonatomic, copy) NSString *bssid;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *pwd;
@property (nonatomic, copy) NSString *token;
@end

NS_ASSUME_NONNULL_END
