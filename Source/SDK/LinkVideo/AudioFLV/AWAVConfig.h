#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "aw_sw_faac_encoder.h"

@interface AWAudioConfig : NSObject<NSCopying>
@property (nonatomic, unsafe_unretained) NSInteger bitrate;//可自由设置
@property (nonatomic, unsafe_unretained) NSInteger channelCount;//可选 1 2
@property (nonatomic, unsafe_unretained) NSInteger sampleRate;//可选 44100 22050 11025 5500
@property (nonatomic, unsafe_unretained) NSInteger sampleSize;//可选 16 8

@property (nonatomic, readonly, unsafe_unretained) aw_faac_config faacConfig;
@end
