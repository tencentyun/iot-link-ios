//
//  BluetoothCentralManager.h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BluetoothCentralManagerDelegate <NSObject>
@optional
//实时扫描外设（目前扫描10s）
- (void)scanPerpheralsUpdatePerpherals:(NSArray<CBPeripheral *> *)perphersArr peripheralInfo:(NSMutableArray *)peripheralInfoArray;
//连接外设成功
- (void)connectBluetoothDeviceSucessWithPerpheral:(CBPeripheral *)connectedPerpheral withConnectedDevArray:(NSArray <CBPeripheral *>*)connectedDevArray;
//断开外设
- (void)disconnectBluetoothDeviceWithPerpheral:(CBPeripheral *)disconnectedPerpheral;

//发送数据后，蓝牙回调
- (void)updateData:(NSArray *)dataHexArray withCharacteristic:(CBCharacteristic *)characteristic pheropheralUUID:(NSString *)pheropheralUUID serviceUUID:(NSString *)serviceString;

@end

@interface BluetoothCentralManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id<BluetoothCentralManagerDelegate>delegate;

@property (nonatomic, assign) BOOL isScanDevice;

/**
 *  链接蓝牙设备后 service 特征数组
 */
@property (nonatomic, strong, readonly) NSMutableArray <CBPeripheral *>*connectPeripheralArray;   //和业务挂钩

/**
 *  已连接蓝牙设备的所有服务Service Peripheral
 */
@property (nonatomic, strong, readonly) CBPeripheral *deviceServicePeripheral;

/**
 * 单例构造方法
 * @return Bluetooth共享实例
 */
+ (instancetype)shareBluetooth;

/**
 * 开始扫描周边设备
 */
- (void)scanNearPerpherals;

/** 连接设备 */
- (void)connectBluetoothPeripheral:(CBPeripheral *)peripheral;


/**
 停止扫描设备
 */
- (void)stopScan;

/**
 断开设备连接
 */
- (void)disconnectPeripheral;

/**
 设置最大阈值 分段给蓝牙发送数据
 */
- (void)writeDataToBluetoothWith:(NSString *)context sendCharacteristic:(CBCharacteristic *)characteristic serviceUUID:(NSString *)serviceUUID;

/**
读取特征值
 */
- (void)readDataBleWith:(NSString *)serverUUID characteristic:(CBCharacteristic *)characteristic;

/**
 设置蓝牙最大传输单元
 */
- (void)setMacTransValue:(NSInteger)maxValue;

/**
 订阅特征后 指定的 service 和 设备
 */
- (void)notififationWith:(CBPeripheral *)peripheral service:(CBService *)service;

/**
 退出H5页面后，清楚连接设备数据
 */
- (void)clearConnectedDevices;
@end
