//
//  TIoTWebVC+BLE.swift
//  LinkApp
//
//  Created by eagleychen on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation

extension TIoTWebVC {

// ----------蓝牙bridge部分
    @objc public func openBluetoothWithMessage(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                if self.bluetoothAvailable {
                    self.adapterAvailable = true;
                    self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
                }else {
                    self.adapterAvailable = false;
                    
                    let errorDic: Dictionary<String,Any> = [
                        "errCode":10001,
                        "errMsg" : "openBluetoothAdapter: fail not available"]
                    
                    self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId,"data":errorDic], port: "callResult")
                }
                
            }
        }
    }
    @objc public func getBluetoothAdapterState(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                
                let blue = BluetoothCentralManager.shareBluetooth()
                let isScan:Bool = ((blue?.isScanDevice) != nil)
                
                let data : [NSString:Bool] = ["discovering": isScan, "available": self.adapterAvailable]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
        
    @objc public func startBluetoothDevicesDiscovery(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
        
            let blue = BluetoothCentralManager.shareBluetooth()
            blue?.delegate = self
            blue?.scanNearPerpherals()
            self.bluetoothAdapterStateChange()
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
        
        }
    }
   
    @objc public func stopBluetoothDevicesDiscovery(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            let blue = BluetoothCentralManager.shareBluetooth()
            blue?.stopScan()
            self.bluetoothAdapterStateChange()
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
        }
    }
    
    @objc public func getBluetoothDevices(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                let data: Dictionary<String, Any> = [
                    "devices": self.peripheralInfoArray
                ]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
    @objc public func getConnectedBluetoothDevices(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            var devicesArray = [[String:String]]()
            
            let blue = BluetoothCentralManager.shareBluetooth()
            let connectedArray:[CBPeripheral] = blue?.connectPeripheralArray as! [CBPeripheral]
            
            
            //对比deviceID 从已连接设备中查找
            if let servicesArray =  messBody["services"] as? Array<Any>{
                for serviceItem in servicesArray  {
                    
                    for periphInfo in connectedArray {
//                        if let item = periphInfo as? Dictionary<NSString, Any> {
                        if serviceItem as? String == periphInfo.identifier.uuidString {
                                let deviceDic: Dictionary<String,String> = [
                                    "name":periphInfo.name!,
                                    "deviceId":serviceItem as! String]
                                devicesArray.append(deviceDic)
                            }
//                        }
                    }
                }
            }
            
            if let callbackId = messBody["callbackId"] {
                let data: Dictionary<String, Any> = [
                    "devices":devicesArray
                    
                ]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
    @objc public func getBLEDeviceRSSI(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            var rssiString : NSNumber?
            
            for periphInfo in self.peripheralInfoArray {
                if let item = periphInfo as? Dictionary<NSString, Any> {
                    if messBody["deviceId"] as? String == item["deviceId"] as? String {
                        rssiString = item["RSSI"] as? NSNumber
                    }
                }
            }
            
            
            if let callbackId = messBody["callbackId"] {
                let data: Dictionary<String, Any> = [
                    "RSSI": rssiString ?? NSNumber(0)
                ]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
    @objc public func createBLEConnection(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                for item in self.peripheralDeviceArray {
                    if let deviceID = messBody["deviceId"] {
                        if deviceID as! String == item.identifier.uuidString {
                            let blue = BluetoothCentralManager.shareBluetooth()
                            blue?.connectBluetoothPeripheral(item)
                            
                            self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    @objc public func closeBLEConnection(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
            let blue = BluetoothCentralManager.shareBluetooth()
            blue?.disconnectPeripheral()
        }
    }
    
    @objc public func getBLEDeviceServices(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            let blue = BluetoothCentralManager.shareBluetooth()
            
            /* 需要连接后 获取service UUID*/
            if let callbackId = messBody["callbackId"] {
                
                var servicesArray = [[String:Any]]()
                if let deviceServicePeripheral = blue?.deviceServicePeripheral {
                    if messBody["deviceId"] as? String == deviceServicePeripheral.identifier.uuidString {
                        for periphInfo in deviceServicePeripheral.services! {
                            
                            //0000FFE0-0000-1000-8000-00805F9B34FB
                            let bluetoothStandard = "-0000-1000-8000-00805F9B34FB"
                            
                            var uuidString = periphInfo.uuid.uuidString
                            
                            if periphInfo.uuid.uuidString.count == 4 {
                                uuidString = "0000\(periphInfo.uuid.uuidString)\(bluetoothStandard)"
                            }
                            if periphInfo.uuid.uuidString.count == 8 {
                                uuidString = "\(periphInfo.uuid.uuidString)\(bluetoothStandard)"
                            }
                            
                            let serviceDic: [String : Any] = ["uuid" : uuidString,"isPrimary":periphInfo.isPrimary];
                            servicesArray.append(serviceDic)
                        }
                    }
                }
                
                
                let data: Dictionary<String, Any> = [
                    "deviceId": messBody["deviceId"] ?? "",
                    "services": servicesArray
                ]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
    @objc public func getBLEDeviceCharacteristics(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            let blue = BluetoothCentralManager.shareBluetooth()
            var servicesArray = [[String:Any]]()

            
            if let serviceId = messBody["serviceId"] as? String , let diviceId = messBody["deviceId"] as? String{
                
                if let deviceServicePeripheral:CBPeripheral = blue?.deviceServicePeripheral {
                    if diviceId == deviceServicePeripheral.identifier.uuidString {
                        
                        for serviceItem in deviceServicePeripheral.services! {
                            
                            //0000FFE0-0000-1000-8000-00805F9B34FB
                            let bluetoothStandard = "-0000-1000-8000-00805F9B34FB"
                            
                            var serviceUuid128bit = serviceItem.uuid.uuidString
                            
                            if serviceId.count == 4 { //16bit
                                
                            }else {                   //128bit
                                if serviceItem.uuid.uuidString.count == 4 {
                                    serviceUuid128bit = "0000\(serviceItem.uuid.uuidString)\(bluetoothStandard)"
                                }
                                if serviceItem.uuid.uuidString.count == 8 {
                                    serviceUuid128bit = "\(serviceItem.uuid.uuidString)\(bluetoothStandard)"
                                }
                            }
                            
                            if serviceId == serviceUuid128bit {
                                for characteristicItem in serviceItem.characteristics! {
                                    
                                    let propertiesItem:CBCharacteristicProperties = characteristicItem.properties
                                    
                                    var characteristicUUID = characteristicItem.uuid.uuidString
                                    
                                    if  characteristicUUID.count == 4 {
                                        characteristicUUID = "0000\(characteristicUUID)\(bluetoothStandard)"
                                    }else {
                                        characteristicUUID = "\(characteristicUUID)\(bluetoothStandard)"
                                    }
                                    
                                    let characterDic:[String:Any] = ["properties":["notify":propertiesItem == CBCharacteristicProperties.notify,"write":propertiesItem == CBCharacteristicProperties.write,"indicate":propertiesItem == CBCharacteristicProperties.indicate,"read":propertiesItem == CBCharacteristicProperties.read],
                                                                     "uuid":characteristicUUID]
                                    
                                    servicesArray.append(characterDic)
                                }
                                
                                
                                
                            }
                        }
                        
                    }
                }
                
            }
            
            if let callbackId = messBody["callbackId"] {
                let data: Dictionary<String, Any> = [
                    "deviceId": messBody["deviceId"] as? String ?? "",
                    "serviceId": messBody["serviceId"] as? String ?? "",
                    "characteristics": servicesArray
                ]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
    @objc public func readBLECharacteristicValue(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
            
            
            let blue = BluetoothCentralManager.shareBluetooth()

            if let serviceId = messBody["serviceId"] as? String , let diviceId = messBody["deviceId"] as? String{
                
                if let deviceServicePeripheral:CBPeripheral = blue?.deviceServicePeripheral {
                    if diviceId == deviceServicePeripheral.identifier.uuidString {
                        
                        for serviceItem in deviceServicePeripheral.services! {
                            
                            //0000FFE0-0000-1000-8000-00805F9B34FB
                            let bluetoothStandard = "-0000-1000-8000-00805F9B34FB"
                            
                            var serviceUuid128bit = serviceItem.uuid.uuidString
                            
                            if serviceId.count == 4 { //16bit
                                
                            }else {                   //128bit
                                if serviceItem.uuid.uuidString.count == 4 {
                                    serviceUuid128bit = "0000\(serviceItem.uuid.uuidString)\(bluetoothStandard)"
                                }
                                if serviceItem.uuid.uuidString.count == 8 {
                                    serviceUuid128bit = "\(serviceItem.uuid.uuidString)\(bluetoothStandard)"
                                }
                            }
                            
                            if serviceId == serviceUuid128bit {
                                for characteristicItem in serviceItem.characteristics! {
                                    
                                    var characteristicUUID = characteristicItem.uuid.uuidString
                                    
                                    if  characteristicUUID.count == 4 {
                                        characteristicUUID = "0000\(characteristicUUID)\(bluetoothStandard)"
                                    }else {
                                        characteristicUUID = "\(characteristicUUID)\(bluetoothStandard)"
                                    }
                                    
                                    if let  characteristicId = messBody["characteristicId"]{
                                        if characteristicId as! String == characteristicUUID {
                                            
                                            var macArr = Array<String>()
                                            
                                            if let value = characteristicItem.value {
                                                 let hexstr = self.transformString(with: value)
                                                let macStr = self.macAddress(with: hexstr)
                                                
                                                let tempArr = macStr.components(separatedBy: ":")
                                                for hexUnit:String in tempArr {
                                                    macArr.append(hexUnit)
                                                }
                                                
                                            }
                                            
                                            let characterDic:[String : Any] = ["deviceId":diviceId,"serviceId":serviceId,"characteristicId":characteristicUUID,"value":macArr]
                                            
                                            self.bleCharacteristicValueChange(characteristicDic: characterDic)
                                            
                                        }
                                    }

                                }
                                
                            }
                        }
                        
                    }
                }
                
            }
        }
    }
    
    @objc public func writeBLECharacteristicValue(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
            
            let blue = BluetoothCentralManager.shareBluetooth()

            if let serviceId = messBody["serviceId"] as? String , let diviceId = messBody["deviceId"] as? String{
                
                if let deviceServicePeripheral:CBPeripheral = blue?.deviceServicePeripheral {
                    if diviceId == deviceServicePeripheral.identifier.uuidString {
                        
                        for serviceItem in deviceServicePeripheral.services! {
                            
                            //0000FFE0-0000-1000-8000-00805F9B34FB
                            let bluetoothStandard = "-0000-1000-8000-00805F9B34FB"
                            
                            var serviceUuid128bit = serviceItem.uuid.uuidString
                            
                            if serviceId.count == 4 { //16bit
                                
                            }else {                   //128bit
                                if serviceItem.uuid.uuidString.count == 4 {
                                    serviceUuid128bit = "0000\(serviceItem.uuid.uuidString)\(bluetoothStandard)"
                                }
                                if serviceItem.uuid.uuidString.count == 8 {
                                    serviceUuid128bit = "\(serviceItem.uuid.uuidString)\(bluetoothStandard)"
                                }
                            }
                            
                            if serviceId == serviceUuid128bit {
                                for characteristicItem in serviceItem.characteristics! {
                                    
                                    var characteristicUUID = characteristicItem.uuid.uuidString
                                    
                                    if  characteristicUUID.count == 4 {
                                        characteristicUUID = "0000\(characteristicUUID)\(bluetoothStandard)"
                                    }else {
                                        characteristicUUID = "\(characteristicUUID)\(bluetoothStandard)"
                                    }
                                    
                                    if let  characteristicId = messBody["characteristicId"]{
                                        if characteristicId as! String == characteristicUUID {
                                            
                                            if let value = messBody["value"] as? String {
//                                                blue?.writeDataToBluetooth(with: value, send: characteristicItem)
                                                blue?.writeDataToBluetooth(with: value, send: characteristicItem, serviceUUID: serviceId)
                                            }
                                            
                                        }
                                    }

                                }
                                
                            }
                        }
                        
                    }
                }
                
            }
            
        }
    }
    
    @objc public func notifyBLECharacteristicValueChange(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
            
            let blue = BluetoothCentralManager.shareBluetooth()

            if let serviceId = messBody["serviceId"] as? String , let diviceId = messBody["deviceId"] as? String{
                
                if let deviceServicePeripheral:CBPeripheral = blue?.deviceServicePeripheral {
                    if diviceId == deviceServicePeripheral.identifier.uuidString {
                        
                        for serviceItem in deviceServicePeripheral.services! {
                            
                            //0000FFE0-0000-1000-8000-00805F9B34FB
                            let bluetoothStandard = "-0000-1000-8000-00805F9B34FB"
                            
                            var serviceUuid128bit = serviceItem.uuid.uuidString
                            
                            if serviceId.count == 4 { //16bit
                                
                            }else {                   //128bit
                                if serviceItem.uuid.uuidString.count == 4 {
                                    serviceUuid128bit = "0000\(serviceItem.uuid.uuidString)\(bluetoothStandard)"
                                }
                                if serviceItem.uuid.uuidString.count == 8 {
                                    serviceUuid128bit = "\(serviceItem.uuid.uuidString)\(bluetoothStandard)"
                                }
                            }
                            
                            if serviceId == serviceUuid128bit {
                                for characteristicItem in serviceItem.characteristics! {
                                    
                                    var characteristicUUID = characteristicItem.uuid.uuidString
                                    
                                    if  characteristicUUID.count == 4 {
                                        characteristicUUID = "0000\(characteristicUUID)\(bluetoothStandard)"
                                    }else {
                                        characteristicUUID = "\(characteristicUUID)\(bluetoothStandard)"
                                    }
                                    
                                    if let  characteristicId = messBody["characteristicId"]{
                                        if characteristicId as! String == characteristicUUID {
                                            
                                            if let value = messBody["state"] as? Bool {
                                                if characteristicItem.properties == CBCharacteristicProperties.notify {
                                                    blue?.deviceServicePeripheral.setNotifyValue(value, for: characteristicItem)
                                                    blue?.notififation(with: deviceServicePeripheral, service: serviceItem)
                                                    
                                                }
                                                
                                            }
                                        }
                                    }

                                }
                                
                            }
                        }
                        
                    }
                }
                
            }
        }
        
    }
    
    @objc public func setBLEMTU(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
            
            let blue = BluetoothCentralManager.shareBluetooth()
            if let value = messBody["mtu"] {
                blue?.setMacTransValue(value as! Int)
            }
                
            
        }
    }
    
    
    @objc public func registerBluetoothDevice(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                
                let data: Dictionary<String, Any> = ["code":0] //失败的返回 {"code":"InvalidParameterValue", "msg":"无效参数值:DeviceName参数错误"}
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
    @objc public func bindBluetoothDevice(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                let data: Dictionary<String, Any> = ["code":0] //失败的返回 {"code":"InvalidParameterValue", "msg":"无效参数值:DeviceName参数错误"}
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
}
    
    
// ----------蓝牙事件部分
extension TIoTWebVC {
    
    @objc public func bleCharacteristicValueChange(characteristicDic:Dictionary<String,Any>) {
       
        let blueParm: Dictionary<String, Any> = [
            "name": "bleCharacteristicValueChange",
            "payload":characteristicDic
        ]
        self.webViewInvokeJavaScript(blueParm, port: "emitEvent")
    }
    
    @objc public func bleConnectionStateChange(perpheral:CBPeripheral) {
        
        let stateNum:Int = perpheral.state.rawValue
        
        let blueParm: Dictionary<String, Any> = [
            "name": "bleConnectionStateChange",
            "payload": [
                "deviceId": perpheral.identifier.uuidString,
                "connected": stateNum.boolValue
            ]
        ]
        self.webViewInvokeJavaScript(blueParm, port: "emitEvent")
    }
    
    @objc public func bluetoothAdapterStateChange() {
        
        let blue = BluetoothCentralManager.shareBluetooth()
        let isScan:Bool = ((blue?.isScanDevice) != nil)
        
        let blueParm: Dictionary<String, Any> = [
            "name": "bluetoothAdapterStateChange",
            "payload": [
                "discovering": isScan,
                "available": self.bluetoothAvailable
            ]
        ]
        self.webViewInvokeJavaScript(blueParm, port: "emitEvent")
    }
    
    @objc public func bluetoothDeviceFound(peripheralInfoArray:NSMutableArray) {
        
        let blueParm: Dictionary<String, Any> = [
            "name": "bluetoothDeviceFound",
            "payload": [
                "devices": peripheralInfoArray
            ]
        ]
        
        self.webViewInvokeJavaScript(blueParm, port: "emitEvent")
    }
    
}

///MARK: 自建extension
extension Int {
    var boolValue: Bool { return self != 0 }
}
    
extension Data {
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
}

// delegate---BluetoothCentralManagerDelegate
extension TIoTWebVC: BluetoothCentralManagerDelegate {
    
    
    public func scanPerpheralsUpdatePerpherals(_ perphersArr: [CBPeripheral]!, peripheralInfo: NSMutableArray!) {
        
        for _ in perphersArr {
            
//            self.peripheralInfoArray = peripheralInfo.mutableCopy() as! NSMutableArray
            
//            //搜索到设备后，把设备传如H5
//            self.bluetoothDeviceFound(peripheralInfoArray: peripheralInfo)
        }

        self.peripheralDeviceArray = [CBPeripheral](perphersArr)
        
        self.peripheralInfoArray = peripheralInfo.mutableCopy() as! NSMutableArray
        //搜索到设备后，把设备传如H5
        self.bluetoothDeviceFound(peripheralInfoArray: peripheralInfo)
        
    }
    
    /// 连接成功回调
    public func connectBluetoothDeviceSucess(withPerpheral connectedPerpheral: CBPeripheral!, withConnectedDevArray connectedDevArray: [CBPeripheral]!) {
        
//        self.connectedArray = [CBPeripheral](connectedDevArray)
        
        //透传事件
        self.bleConnectionStateChange(perpheral: connectedPerpheral)
    }
    
    /// 断开连接回调
    public func disconnectBluetoothDevice(withPerpheral disconnectedPerpheral: CBPeripheral!) {
        
        //透传事件
        self.bleConnectionStateChange(perpheral: disconnectedPerpheral)
    }
    
    public func updateData(_ dataHexArray: [Any]!, with characteristic: CBCharacteristic!, pheropheralUUID: String!, serviceUUID serviceString: String!) {
        let characterDic:[String : Any] = ["deviceId":pheropheralUUID ?? "","serviceId":serviceString ?? "","characteristicId":characteristic.uuid.uuidString,"value":dataHexArray ?? []]

        self.bleCharacteristicValueChange(characteristicDic: characterDic)
    }
    
}
