//
//  TIOTTRTCModel.h
//  TIoTLinkKit.default-TRTC
//
//  Created by eagleychen on 2020/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOTTRTCModel : NSObject
@property (nonatomic, strong) NSString *SdkAppId;
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *UserSig;
@property (nonatomic, strong) NSString *RoomId;
@end

NS_ASSUME_NONNULL_END
