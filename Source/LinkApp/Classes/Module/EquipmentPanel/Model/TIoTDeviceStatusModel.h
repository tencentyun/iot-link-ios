//
//  TIoTDeviceStatusModel.h
//  LinkApp
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIoTDeviceAudioModel;
@class TIoTDeviceVideoModel;

@interface TIoTDeviceStatusModel : NSObject
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *appConnectNum;
@property (nonatomic, copy) NSString *video_list;
@property (nonatomic, strong) TIoTDeviceVideoModel *video;
@property (nonatomic, strong) TIoTDeviceAudioModel *audio;
@end

@interface TIoTDeviceAudioModel : NSObject
@property (nonatomic, copy) NSString *codecid;
@property (nonatomic, copy) NSString *samplerate;
@property (nonatomic, copy) NSString *channels;
@property (nonatomic, copy) NSString *bitwidth;

//@property (nonatomic, copy) NSInteger bitrate;//可自由设置
//@property (nonatomic, copy) NSInteger channelCount;//可选 1 2
//@property (nonatomic, copy) NSInteger sampleRate;//可选 44100 22050 11025 5500
//@property (nonatomic, copy) NSInteger sampleSize;//可选 16 8

@end

@interface TIoTDeviceVideoModel : NSObject
@property (nonatomic, copy) NSString *codecid;
//@property (nonatomic, copy) NSInteger width;//可选，系统支持的分辨率，采集分辨率的宽
//@property (nonatomic, copy) NSInteger height;//可选，系统支持的分辨率，采集分辨率的高
//@property (nonatomic, copy) NSInteger bitrate;//自由设置
//@property (nonatomic, copy) NSInteger fps;//自由设置
@end

NS_ASSUME_NONNULL_END
