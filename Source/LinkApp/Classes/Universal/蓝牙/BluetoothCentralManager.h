//
//  BluetoothCentralManager.h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BluetoothCentralManagerDelegate <NSObject>
@optional
//实时扫描外设（目前扫描10s）
- (void)scanPerpheralsUpdatePerpherals:(NSArray<CBPeripheral *> *)perphersArr;
//连接外设成功
- (void)connectPerpheralSucess;
//发送数据后，蓝牙回调
- (void)updateData:(NSString *)data;

@end

@interface BluetoothCentralManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id<BluetoothCentralManagerDelegate>delegate;

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
- (void)connectPeripheral:(CBPeripheral *)peripheral;


/**
 停止扫描设备
 */
- (void)stopScan;

/**
 断开设备连接
 */
- (void)disconnectPeripheral;

/**
 给蓝牙发送数据
*/
- (void)writeDataToBLE:(NSString *)context;
    

@end
