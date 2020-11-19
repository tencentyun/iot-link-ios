//
//  TIoTAutoIntelligentModel.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AutoIntelliConditionDeviceProperty;
@class AutoIntelliConditionTimerProperty;

@interface TIoTAutoIntelligentModel : NSObject

@property (nonatomic, strong) NSString *type;  //自动智能- 本地自行构建  添加条件 （ 0 设备状态变化 1 定时）；任务（2 设备控制，3 延时，4 选择手动，5 发送通知）

//条件
@property (nonatomic, strong) NSString *CondId; //条件ID，保证在一个联动下唯一即可
@property (nonatomic, assign) NSInteger CondType;  //条件类型 0：设备属性值条件  1：定时条件
@property (nonatomic, strong) AutoIntelliConditionDeviceProperty *Property; //添加条件设备中Property
@property (nonatomic ,strong) AutoIntelliConditionTimerProperty *Timer; //添加条件中延时Timer
@property (nonatomic, strong) TIoTPropertiesModel *propertyModel; //本地添加 设备面板属性模型

//任务
@property (nonatomic, assign) NSInteger ActionType; // 0： 则为设备动作，具体参数设置为Data   0 ：设备动作  1：延时 2:场景 3：通知
@property (nonatomic, strong) NSString *ProductId;
@property (nonatomic, strong) NSString *DeviceName;
@property (nonatomic, strong) NSString *Data;  //"{\"brightness\": 25}" ActionType为 0 ：设备动作参数  为1：延时时间单位秒 2：执行场景Id 3:通知内容
@property (nonatomic, strong) NSString *AliasName;
@property (nonatomic, strong) NSString *IconUrl;

@property (nonatomic, strong) NSString *propertName; //本地添加 data 属性名
@property (nonatomic, strong) NSString *dataValueString; //本地添加 data 解析后对应的value
@property (nonatomic, strong) NSString *sceneName; //本地添加 场景名称
@property (nonatomic, strong) NSString *delayTime; //本地添加 延时时间 加汉字
@property (nonatomic, strong) NSString *delayTimeFormat; //本地添加 延时时间 00:00
@property (nonatomic, assign) NSInteger isSwitchTuron; //本地添加 通知开关 1 开 0 关

//生效时间段
@property (nonatomic, strong) NSString *EffectiveBeginTime; //# 【两个新增参数，用来表示开始和结束时间
@property (nonatomic, strong) NSString *EffectiveEndTime;
@property (nonatomic, strong) NSString *EffectiveDays; // # 由0和1组成的7位数字，0表示不执行，1表示执行，第1位为周日，依次表示周一至周六
@end

/**
 添加条件设备中Property
 */
@interface AutoIntelliConditionDeviceProperty : NSObject
@property (nonatomic, strong) NSString *ProductId;
@property (nonatomic, strong) NSString *DeviceName;
@property (nonatomic, strong) NSString *AliasName;
@property (nonatomic, strong) NSString *IconUrl;
@property (nonatomic, strong) NSString *PropertyId; //设备的属性Id
@property (nonatomic, strong) NSString *Op; //条件操作符  eq 等于  ne 不等于  gt 大于  lt 小于  ge 大等于  le 小等于
@property (nonatomic, strong) NSNumber *Value;//比较的值

@property (nonatomic, strong) NSString *conditionTitle;//本地添加 conditiontitle name
@property (nonatomic, copy) NSString *conditionContentString;//本地添加 condition 所选item 内容
@end

/**
 添加条件中延时Timer
 */
@interface AutoIntelliConditionTimerProperty : NSObject
@property (nonatomic, strong) NSString *Days; // 由0和1组成的7位数字，0表示不执行，1表示执行，第1位为周日，依次表示周一至周六 （执行一次 0000000）
@property (nonatomic, strong) NSString *TimePoint; // 触发时间，24小时制，比如"14:00"
@property (nonatomic, strong) NSString *timerKindSring;  //本地自行构建
@property (nonatomic, assign) NSInteger choiceRepeatTimeNumner;//本地自建  定时中-重复类型
@end


NS_ASSUME_NONNULL_END
