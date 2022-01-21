//
//  TIoTXp2pInfoModel.h
//  LinkSDKDemo
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTXp2pDetailModel;
@class TIoTXp2pDevInfoModel;

@interface TIoTXp2pInfoModel : NSObject
@property (nonatomic, strong) NSString *Data;
@end

@interface TIoTXp2pModel : NSObject
@property (nonatomic, strong) TIoTXp2pDetailModel *_sys_cs_days;
@property (nonatomic, strong) TIoTXp2pDetailModel *_sys_cs_status;
@property (nonatomic, strong) TIoTXp2pDetailModel *_sys_cs_type;
@property (nonatomic, strong) TIoTXp2pDetailModel *_sys_xp2p_info;
@property (nonatomic, strong) TIoTXp2pDetailModel *dev_info;
@end

@interface TIoTXp2pDetailModel : NSObject
@property (nonatomic, strong) NSString *LastUpdate;
@property (nonatomic, strong) NSString *Value;
@end

//dev_info 单独处理
@interface TIoTXp2pDevInfoModel : NSObject
@property (nonatomic, strong) NSString *audio_codec;
@property (nonatomic, strong) NSString *video_codec;
@end

NS_ASSUME_NONNULL_END
