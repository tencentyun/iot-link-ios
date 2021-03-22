//
//  BluetoothCentralManager.m
//
#import "BluetoothCentralManager.h"
//服务UUID
#define kServiceUUID    @"serviceUUID"
//特征UUID
#define kCharacteristicUUID    @"FFE1"


@interface BluetoothCentralManager ()

/** 中心设备管理者 */
@property (nonatomic, strong) CBCentralManager *centralManager;
/** 连接的外围设备 */
@property (nonatomic, strong) CBPeripheral *peripheral;
/** 所有的设备数组 */
@property (nonatomic, strong) NSMutableArray *deviceList;
/** 链接蓝牙设备后 service 特征数组 */
@property (nonatomic, strong, readwrite) NSMutableArray <CBPeripheral *>*connectPeripheralArray;   //和业务挂钩
/** 搜索蓝牙设备 peripheral 数组 */
@property (nonatomic, strong) NSMutableArray *peripheralArray;   //和业务挂钩

/** 已连接蓝牙设备的所有服务service*/
@property (nonatomic, strong,readwrite) CBPeripheral *deviceServicePeripheral;


@property (nonatomic, strong, readwrite) CBPeripheral *servicePeripheral;
 
@property (nonatomic, assign) NSInteger maxValue;

@property (nonatomic, strong,readwrite) CBPeripheral *notifiPeripheral;

@property (nonatomic, strong,readwrite) CBService *notifiService;

@property (nonatomic, strong) NSString *senderServiceUUID;

/** 特征z */
@property (nonatomic, strong) CBCharacteristic *characteristic;

@end

@implementation BluetoothCentralManager

#pragma mark lifeCircle
+ (instancetype)shareBluetooth {
    static BluetoothCentralManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/**
 初始化 centralManager
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.isScanDevice = self.centralManager.isScanning;//NO;
        
    }
    return self;
}

#pragma mark publicMethods
/**
 扫描周周的设备
 */
- (void)scanNearPerpherals{
    WCLog(@"开始扫描四周的设备");
    
    self.maxValue = 0;
    
    [self.deviceList removeAllObjects];
    
    [self.peripheralArray removeAllObjects];
    
    self.isScanDevice = self.centralManager.isScanning;
    /**
     1.第一个参数为Services的UUID(外设端的UUID) 不能为nil
     2.第二参数的CBCentralManagerScanOptionAllowDuplicatesKey为已发现的设备是否重复扫描，如果是同一设备会多次回调
     */
//    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO}];
    

    if (self.centralManager.state == CBManagerStatePoweredOn) {
        //扫描10秒停止扫描
        [self performSelector:@selector(stopScan) withObject:nil afterDelay:5.0];
        
        // 这里已确认蓝牙已打开才开始扫描周围的外设。第一个参数nil就是扫描周围所有的外设。
        [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    }
}

/**
 停止扫描设备
 */
- (void)stopScan{
    WCLog(@"停止扫描四周的设备");
    [self.centralManager stopScan];
    
    self.isScanDevice = self.centralManager.isScanning;
    
    [HXYNotice postBluetoothScanStop];
    
    
}

/// 连接指定的设备
- (void)connectBluetoothPeripheral:(CBPeripheral *)peripheral {
    self.peripheral = peripheral;
    WCLog(@"----尝试连接设备----\n%@", peripheral);
    [self.centralManager connectPeripheral:peripheral
                                   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

/**
 断开设备连接
 */
- (void)disconnectPeripheral{
    WCLog(@"断开已连接的设备");
    if (self.peripheral) {
       
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        
    }
}

/**
 退出H5页面后，清楚连接设备数据
 */
- (void)clearConnectedDevices {
    [self.connectPeripheralArray removeAllObjects];
    [self stopScan];
    [self disconnectPeripheral];
}

#pragma mark privateMethods
- (void)readDataBleWith:(NSString *)serverUUID characteristic:(CBCharacteristic *)characteristic {
    self.senderServiceUUID = serverUUID;
    if (characteristic) {
        self.characteristic = characteristic;
    }
    [self.peripheral readValueForCharacteristic:characteristic];
}


//MARK:设置一条数据给蓝牙发送数据
- (void)writeDataToBLE:(NSString *)context
{
    // 发送下行指令(发送一条)
    if (self.characteristic) {
        NSData *data = [context dataUsingEncoding:NSUTF8StringEncoding];
        [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}

//MARK:设置最大阈值 分段给蓝牙发送数据
- (void)writeDataToBluetoothWith:(NSString *)context sendCharacteristic:(CBCharacteristic *)characteristic serviceUUID:(NSString *)serviceUUID{
    
    self.senderServiceUUID = serviceUUID;
    
    NSData *data = [NSString convertHexStrToData:context?:@""];
    
    // 写入字节的最大长度
    NSInteger maxValue = self.maxValue;
    if (maxValue == 0) {
        maxValue = [self.peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse];
    }
    
    for (int i = 0; i < data.length; i += maxValue) {
        // 预加载最大包长度，如果小于总数据长度，可取最大包数据大小
        if ((i + maxValue) < data.length) {
            NSString *rangeString = [NSString stringWithFormat:@"%i,%li", i, (long)maxValue];
            NSData *segmentData = [data subdataWithRange:NSRangeFromString(rangeString)];
            [self sendDataToBluetoothWith:segmentData sendCharacteristic:characteristic];
            // 做相应延时
            usleep(20000);
        }
        else {
            NSString *rangeString = [NSString stringWithFormat:@"%i,%i", i, (int)([data length] - i)];
            NSData *segmentData = [data subdataWithRange:NSRangeFromString(rangeString)];
            [self sendDataToBluetoothWith:segmentData sendCharacteristic:characteristic];
            // 做相应延时
            usleep(20000);
        }
    }
}

-(void)sendDataToBluetoothWith:(NSData *)data sendCharacteristic:(CBCharacteristic *)characteristic{
    if(characteristic){
        self.characteristic = characteristic;
        [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}

//MARK:设置蓝牙最大传输单元
- (void)setMacTransValue:(NSInteger)maxValue {
    self.maxValue = maxValue;
}

/** 订阅特征后 指定的 service 和 设备*/
- (void)notififationWith:(CBPeripheral *)peripheral service:(CBService *)service {
    self.notifiPeripheral = peripheral;
    self.notifiService = service;
}

#pragma mark ------------------------扫描发现蓝牙设备 CBCentralManagerDelegate
/**
 检查App设备蓝牙是否可用
 
 @param central 中心设备管理器
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state){
        case CBManagerStatePoweredOn:{
            //蓝牙已打开,开始扫描外设
            [self scanNearPerpherals];
        }
            break;
            
        case CBManagerStateUnsupported:
            [MBProgressHUD showError:NSLocalizedString(@"bluetooth_unqualified", @"您的设备不支持蓝牙或蓝牙4.0")];
            break;
            
        case CBManagerStateUnauthorized:
            [MBProgressHUD showError:NSLocalizedString(@"unauthorized_bluetooth", @"未授权打开蓝牙")];
            break;
            
        case CBManagerStatePoweredOff://蓝牙未打开，系统会自动提示打开，所以不用自行提示
            
        default:
            break;
    }
}

/**
 发现外围设备的代理
 
 @param central 中心设备
 @param peripheral 外围设备
 @param advertisementData 特征数据
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"\n"];
    [nsmstring appendString:@"----发现外设----\n"];
    [nsmstring appendString:@"Peripheral Info:\n"];
    [nsmstring appendFormat:@"NAME: %@\n",peripheral.name];
    [nsmstring appendFormat:@"UUID(identifier): %@\n",peripheral.identifier];
    [nsmstring appendFormat:@"RSSI: %@\n",RSSI];
    [nsmstring appendFormat:@"adverisement:%@\n",advertisementData];
    WCLog(@"%@",nsmstring);
    
    NSMutableDictionary *peripheralDic = [NSMutableDictionary new];
    if (![NSString isNullOrNilWithObject:peripheral.name]) {
        [peripheralDic setValue:peripheral.name forKey:@"name"];
    }
    
    if (![NSString isNullOrNilWithObject:peripheral.identifier]) {    //uuid
        [peripheralDic setValue:[NSString stringWithFormat:@"%@",peripheral.identifier] forKey:@"deviceId"];
    }
    
    if (![NSString isNullOrNilWithObject:peripheral.identifier]) {    //uuid
        [peripheralDic setValue:[NSString stringWithFormat:@"%@",peripheral.identifier] forKey:@"UUID"];
    }
    
    if (![NSString isNullOrNilWithObject:RSSI]) {
        [peripheralDic setValue:RSSI forKey:@"RSSI"];
    }
    if ([advertisementData.allKeys containsObject:@"kCBAdvDataManufacturerData"]) {
        
        NSString *hexstr = [NSString transformStringWithData:advertisementData[@"kCBAdvDataManufacturerData"]];
        NSString *macStr = [NSString macAddressWith:hexstr];
        NSMutableArray *macArr = [NSMutableArray new];
        NSArray *tempArr = [macStr componentsSeparatedByString:@":"];
        for (NSString *hexUnit in tempArr) {
            [macArr addObject:hexUnit];
        }
        [peripheralDic setValue:macArr forKey:@"advertisData"];
    }
    if ([advertisementData.allKeys containsObject:@"kCBAdvDataServiceUUIDs"]) {
        
        NSMutableArray *uuidArray = [NSMutableArray array];
        
        NSArray *uuidArr = [NSArray arrayWithArray:advertisementData[@"kCBAdvDataServiceUUIDs"]];
        
        for (id uuidItem in uuidArr) {
            NSString *uuidString = [NSString stringWithFormat:@"%@",uuidItem];
            NSString *keyUUID = @"";
            if (uuidString.length == 4) {
                keyUUID = [NSString stringWithFormat:@"0000%@%@",uuidString,@"-0000-1000-8000-00805F9B34FB"];
            }else {
                keyUUID = uuidString;
            }
            
            [uuidArray addObject:keyUUID];
        }
        [peripheralDic setValue:uuidArray forKey:@"advertisServiceUUIDs"];
    }
    if ([advertisementData.allKeys containsObject:@"kCBAdvDataLocalName"]) {
        [peripheralDic setValue:advertisementData[@"kCBAdvDataLocalName"] forKey:@"localName"];
    }
    if ([advertisementData.allKeys containsObject:@"kCBAdvDataServiceData"]) {
        NSDictionary *serviceDataDic = [NSDictionary dictionaryWithDictionary:advertisementData[@"kCBAdvDataServiceData"]];
        
        NSMutableDictionary *dataDic = [NSMutableDictionary new];
        for (int i = 0; i < serviceDataDic.allKeys.count; i++) {
            
            NSString *keyString = [NSString stringWithFormat:@"%@",serviceDataDic.allKeys[i]];
            NSString *keyUUID = @"";
            if (keyString.length == 4) {
                keyUUID = [NSString stringWithFormat:@"0000%@%@",keyString,@"-0000-1000-8000-00805F9B34FB"];
            }else {
                keyUUID = keyString;
            }
            
            NSString *hexstr = [NSString transformStringWithData:serviceDataDic.allValues[i]];
            NSString *macStr = [NSString macAddressWith:hexstr];
            NSMutableArray *macArr = [NSMutableArray new];
            NSArray *tempArr = [macStr componentsSeparatedByString:@":"];
            for (NSString *hexUnit in tempArr) {
                [macArr addObject:hexUnit];
            }
            
            [dataDic setValue:macArr forKey:keyUUID];
            
        }
        
        [peripheralDic setValue:dataDic forKey:@"serviceData"];
    }
    
//    if (advertisementData != nil) {
//        [peripheralDic setValue:advertisementData forKey:@"adverisement"];
//    }
    
    //4.如果数组里没有这个外围设备再添加进数组，避免重复添加相同的外围设备
    if(![self.deviceList containsObject:peripheral])
    {
        //设备名长度大于0添加
        if (peripheral.identifier.UUIDString.length > 0) {
            [self.deviceList addObject:peripheral];
        }
        
    }
    
    NSString *uuidStr = [NSString stringWithFormat:@"%@",peripheral.identifier];
    NSMutableArray *uuidsAllArray = [NSMutableArray new];
    for (NSMutableDictionary *tempPeriphearDic in self.peripheralArray) {
        if ([tempPeriphearDic.allKeys containsObject:@"deviceId"]) {
            [uuidsAllArray addObject:tempPeriphearDic[@"deviceId"]];
        }
    }
    
    if (![uuidsAllArray containsObject:uuidStr]&&advertisementData != nil) {
        if ([advertisementData.allKeys containsObject:@"kCBAdvDataLocalName"]) {
            [self.peripheralArray addObject:peripheralDic];
        }
        
    }
    
//    if (self.deviceList.count > 0) {
        
        if ([self.delegate respondsToSelector:@selector(scanPerpheralsUpdatePerpherals:peripheralInfo:)]) {
            [self.delegate scanPerpheralsUpdatePerpherals:self.deviceList.copy peripheralInfo:self.peripheralArray];
        }
//    }

//    NSArray *serviceUUIDArr = advertisementData[@"kCBAdvDataServiceUUIDs"];
//    
//    for (CBUUID *serviceUUID in serviceUUIDArr) {
//        // 判断外设是否有需要的服务（是否是当前APP对应的外设）<此项目应该判断外设的名字>
//        if ([serviceUUID.UUIDString isEqualToString:kServiceUUID]) {
//            //发现符合条件的周边外设通知
//            [[NSNotificationCenter defaultCenter] postNotificationName: SLDidFoundPeripheralNotification object:peripheral];
//            [self connectPeripheral:peripheral];
//        }
//    }
}

/// 连接外设成功的代理方法
#pragma mark ------------------------连接成功、失败、终端
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self stopScan];
    
    [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"bluetoothDevice", @"蓝牙设备"),NSLocalizedString(@"connected", @"已连接"),peripheral.name]];
    
    // 设置设备代理
    [peripheral setDelegate:self];
    //查找外围设备中的所有服务
    [peripheral discoverServices:nil];
    
    //添加连接蓝牙设备成功后的设备数组
    if(![self.connectPeripheralArray containsObject:peripheral])
    {
        //设备名长度大于0添加
        if (peripheral.identifier.UUIDString.length > 0) {
            [self.connectPeripheralArray addObject:peripheral];
        }
        
    }
    
    if ([self.delegate respondsToSelector:@selector(connectBluetoothDeviceSucessWithPerpheral:withConnectedDevArray:)]) {
        [self.delegate connectBluetoothDeviceSucessWithPerpheral:peripheral withConnectedDevArray:self.connectPeripheralArray];
    }
}

///连接外设失败的代理方法
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    WCLog(@"%@连接失败",peripheral.name);
}

///连接外设中断的代理方法
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    if ([self.connectPeripheralArray containsObject:peripheral]) {
        [self.connectPeripheralArray removeObject:peripheral];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(disconnectBluetoothDeviceWithPerpheral:)]) {
        [self.delegate disconnectBluetoothDeviceWithPerpheral:peripheral];
    }
    [MBProgressHUD showError:NSLocalizedString(@"connected_interrupt", @"连接中断")];
}


#pragma mark -------------外部蓝牙设备的服务，有了服务才能写数据 CBPeripheralDelegate
/// 获取外设服务的代理
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        WCLog(@"%@获取服务失败:%@",peripheral.name,error.localizedDescription);
        return;
    }
    
    //这种连接的设备没有服务
    if(peripheral.services.count == 0)
    {
      WCLog(@"蓝牙设备无服务服务");
    }
    
    
    NSLog(@"=====>%@",peripheral.services);
    for (CBService *service in peripheral.services) {
//        // 找到对应服务
//        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
//            //服务中找特征
//            [service.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
//        }
        
        //扫描服务中的所有特征
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
    if ([self.peripheral.identifier.UUIDString isEqual:peripheral.identifier.UUIDString]) {
        self.deviceServicePeripheral = peripheral;
    }
}

///在获取外设服务的代理的方法中如果没有error，可以调用discoverCharacteristics方法请求周边去寻找它的服务所列出的特征，它会响应下面的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        WCLog(@"%@获取指定特征失败:%@",peripheral.name,error.localizedDescription);
        return;
    }
    
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"\n"];
    [nsmstring appendFormat:@"------在服务: %@ 中发现 %lu 个特征 ------\n",service.UUID,(unsigned long)service.characteristics.count];
    //这种连接的设备特征值
    if(service.characteristics.count == 0)
    {
        WCLog(@"蓝牙设备无特征值");
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        [nsmstring appendFormat:@"%@\n",characteristic];
        [nsmstring appendFormat:@"\n"];
        WCLog(@"------characteristic--->>>%@",nsmstring);
  
        CBCharacteristicProperties p = characteristic.properties;
        
        if (p & CBCharacteristicPropertyWrite) {
            WCLog(@"Write---扫描服务：%@的特征值为：%@",service.UUID,characteristic.UUID);
            // 订阅, 实时接收
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            /*
            // 获取特征值发送数据（用于测试，正式可以注释下面两行代码）
            // 发送下行指令(发送一条)
            NSData *data = [@"蓝牙初始化数据" dataUsingEncoding:NSUTF8StringEncoding];
            // 将指令写入蓝牙
            [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
              */
        }
        
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
    
    if ([self.peripheral.identifier.UUIDString isEqual:peripheral.identifier.UUIDString]) {
        self.deviceServicePeripheral = peripheral;
    }
}

// 写入数据后的回调方法
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        [MBProgressHUD showError:NSLocalizedString(@"transferFailure", @"传输数据失败")];
        return;
    }
    
    WCLog(@"写入数据成功:%@",characteristic);
    [peripheral readValueForCharacteristic:characteristic];
}

/// 获取到特征的值时回调 -- 获取回调数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    WCLog(@"特征UUID:%@，数据：%@", characteristic.UUID.UUIDString,characteristic.value);
    if (error) {
        WCLog(@"特征UUID:%@回调数据错误:%@", characteristic.UUID.UUIDString,error.localizedDescription);
        return;
    }
    
    
    if ([self.deviceServicePeripheral.identifier.UUIDString isEqualToString: peripheral.identifier.UUIDString]) {
        
        
        NSString *hexstr = [NSString transformStringWithData:characteristic.value];
        NSString *macStr = [NSString macAddressWith:hexstr];
        NSMutableArray *macArr = [NSMutableArray new];
        NSArray *tempArr = [macStr componentsSeparatedByString:@":"];
        for (NSString *hexUnit in tempArr) {
            [macArr addObject:hexUnit];
        }
        //传递hex 2位一个字符串的数组
        if ([self.delegate respondsToSelector:@selector(updateData:withCharacteristic:pheropheralUUID:serviceUUID:)]) {
            [self.delegate updateData:macArr withCharacteristic:characteristic pheropheralUUID:peripheral.identifier.UUIDString serviceUUID:self.senderServiceUUID];
        }
    }
    WCLog(@"特征UUID:%@，数据：%@", characteristic.UUID.UUIDString,characteristic.value);
}

#pragma mark - 中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{

    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
    } else {
        WCLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        WCLog(@"%@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
        
        if ([self.deviceServicePeripheral.identifier.UUIDString isEqualToString: peripheral.identifier.UUIDString]) {
            
            
            NSString *hexstr = [NSString transformStringWithData:characteristic.value];
            NSString *macStr = [NSString macAddressWith:hexstr];
            NSMutableArray *macArr = [NSMutableArray new];
            NSArray *tempArr = [macStr componentsSeparatedByString:@":"];
            for (NSString *hexUnit in tempArr) {
                [macArr addObject:hexUnit];
            }
            //传递hex 2位一个字符串的数组
            if ([self.delegate respondsToSelector:@selector(updateData:withCharacteristic:pheropheralUUID:serviceUUID:)]) {
                [self.delegate updateData:macArr withCharacteristic:characteristic pheropheralUUID:peripheral.identifier.UUIDString serviceUUID:self.senderServiceUUID];
            }
        }
        
        //[self.centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    WCLog(@"特征描述(%@)",descriptor.description);
}

//发现外设的特征数组
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    WCLog(@"--->%@",characteristic);
    // 读取特征数据
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        WCLog(@"发现外设的特征descriptor(%@)",descriptor);
        [peripheral readValueForDescriptor:descriptor];
    }
}

#pragma mark setter or getter
-(NSMutableArray *)deviceList{
    if (!_deviceList) {
        _deviceList = [NSMutableArray array];
    }
    
    return _deviceList;
}

- (NSMutableArray *)peripheralArray {
    if (!_peripheralArray) {
        _peripheralArray = [NSMutableArray array];
    }
    return _peripheralArray;
}

- (NSMutableArray *)connectPeripheralArray {
    if (!_connectPeripheralArray) {
        _connectPeripheralArray = [NSMutableArray array];
    }
    return _connectPeripheralArray;
}

@end
