//
//  TIoTExploreOrVideoDeviceModel.h
//  LinkSDKDemo
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTExploreOrVideoDeviceModel : NSObject


/// VideoDeviceListModel
@property (nonatomic, copy) NSString *ActiveTime;
@property (nonatomic, copy) NSString *DeviceName;
@property (nonatomic, copy) NSString *Disabled;
@property (nonatomic, copy) NSString *IotModel;
@property (nonatomic, copy) NSString *LastOnlineTime;
@property (nonatomic, copy) NSString *LastUpdateTime;
@property (nonatomic, copy) NSString *Online;
@property (nonatomic, copy) NSString *OtaVersion;
@property (nonatomic, copy) NSString *StreamStatus;
@property (nonatomic, copy) NSString *Tid;
@property (nonatomic, strong) NSString *isSelected; //本地维护

/// NVR 子设备model
@property (nonatomic, copy) NSString *Channel;

/// ExploreDeviceListModel
@property (nonatomic, copy) NSString *AppKey;
@property (nonatomic, copy) NSString *AppSKey;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, copy) NSString *DevAddr;
@property (nonatomic, copy) NSString *DevEUI;
@property (nonatomic, copy) NSString *DeviceCert;
//@property (nonatomic, copy) NSString *DeviceName;
@property (nonatomic, copy) NSString *DevicePsk;
@property (nonatomic, copy) NSString *FirstOnlineTime;
@property (nonatomic, copy) NSString *LogLevel;
@property (nonatomic, copy) NSString *LoginTime;
@property (nonatomic, copy) NSString *NwkSKey;
@property (nonatomic, copy) NSString *Status;
@property (nonatomic, copy) NSString *Version;
@end

NS_ASSUME_NONNULL_END
