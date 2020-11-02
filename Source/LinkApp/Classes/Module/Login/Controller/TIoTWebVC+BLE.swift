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
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
        }
    }
    @objc public func getBluetoothAdapterState(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                
                let data = ["discovering": 1, "available": 1]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
        
    @objc public func startBluetoothDevicesDiscovery(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
        
            let blue = BluetoothCentralManager.shareBluetooth()
            blue?.delegate = self
            blue?.scanNearPerpherals()
        }
    }
   
    @objc public func stopBluetoothDevicesDiscovery(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
        }
    }
    
    @objc public func getBluetoothDevices(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                let data: Dictionary<String, Any> = [
                    "devices": [
                        [
                            "deviceId": "CF9E3AF0-98FC-4035-A6AA-51B0EBCB6349",
                            "advertisServiceUUIDs": [
                                "21A0C549-7A37-495A-9A3A-2C2D9E504BAA",
                                "5F8B724E-9EF2-4E01-9F39-A588450ADA1E"
                            ],
                            "localName": "dev001",
                            "name": "dev001",
                            "advertisData": ["01", "FA", "34", "68"],
                            "serviceData": [
                                "9BCE9B97-9366-4FEE-8C5F-21875B6E6941": []
                            ],
                            "RSSI": -57
                        ],
                        [
                            "deviceId": "9A4DED58-E97D-4E13-8F4B-955F413FE67F",
                            "advertisServiceUUIDs": [
                                "21A0C549-7A37-495A-9A3A-2C2D9E504BAA",
                                "5F8B724E-9EF2-4E01-9F39-A588450ADA1E"
                            ],
                            "localName": "dev002",
                            "name": "dev002",
                            "advertisData": ["01", "FA", "34", "50"],
                            "serviceData": [
                                "9BCE9B97-9366-4FEE-8C5F-21875B6E6941": []
                            ],
                            "RSSI": -60
                        ]
                    ]
                ]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
    @objc public func getConnectedBluetoothDevices(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                let data: Dictionary<String, Any> = [
                    
                    "devices": [
                        [
                            "name": "dev001",
                            "deviceId": "5F8B724E-9EF2-4E01-9F39-A588450ADA1E"
                        ],
                        [
                            "name": "dev002",
                            "deviceId": "D0A9D9D3-9EF2-4E01-9F39-AB71A6D97856"
                        ]
                    ]
                    
                ]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
    @objc public func getBLEDeviceRSSI(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                let data: Dictionary<String, Any> = [
                    "RSSI": -57
                ]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
    @objc public func createBLEConnection(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
        }
    }
    
    @objc public func closeBLEConnection(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
        }
    }
    
    @objc public func getBLEDeviceServices(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                let data: Dictionary<String, Any> = [
                    "deviceId": "CF9E3AF0-98FC-4035-A6AA-51B0EBCB6349",
                    "services": [
                        [
                            "uuid": "A8BF8F1C-8C04-47D3-82AF-A1BA796A0773",
                            "isPrimary": true,
                        ],
                        [
                            "uuid": "04FB89CB-E938-4179-943C-78A82F6D6870",
                            "isPrimary": false,
                        ]
                    ]
                ]
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId, "data": data], port: "callResult")
            }
        }
    }
    
    @objc public func getBLEDeviceCharacteristics(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                let data: Dictionary<String, Any> = [
                    
                    "deviceId": "23D6EDD2-B04C-4ED7-AACA-4A1B2F54A06A",
                    "serviceId": "A8BF8F1C-8C04-47D3-82AF-A1BA796A0773",
                    "characteristics": [
                        [
                            "properties": [
                                "notify": false,
                                "write": true,
                                "indicate": false,
                                "read": true
                            ],
                            "uuid": "AA3A2347-DBCC-4F37-9BAE-DFCA2C418CDA"
                        ],
                        [
                            "properties": [
                                "notify": true,
                                "write": true,
                                "indicate": false,
                                "read": true
                            ],
                            "uuid": "4979A12A-34FD-48FA-9BC8-138F817A0626"
                        ]
                    ]
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
        }
    }
    
    @objc public func writeBLECharacteristicValue(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
        }
    }
    
    @objc public func notifyBLECharacteristicValueChange(message: WKScriptMessage) {
        if let messBody = message.body as? Dictionary<String, Any> {
            
            if let callbackId = messBody["callbackId"] {
                self.webViewInvokeJavaScript(["result": true, "callbackId": callbackId], port: "callResult")
            }
        }
        
        //注册特征值变化的通知，有变化后走事件
        self.bleCharacteristicValueChange()
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
    
    @objc public func bleCharacteristicValueChange() {
       
        let blueParm: Dictionary<String, Any> = [
            "name": "bleCharacteristicValueChange",
            "payload": [
                "deviceId": "CF9E3AF0-98FC-4035-A6AA-51B0EBCB6349",
                "serviceId": "A8BF8F1C-8C04-47D3-82AF-A1BA796A0773",
                "characteristicId": "AA3A2347-DBCC-4F37-9BAE-DFCA2C418CDA",
                "value": ["0A", "FF", "4C"]
            ]
        ]
        self.webViewInvokeJavaScript(blueParm, port: "emitEvent")
    }
    
    @objc public func bleConnectionStateChange() {
        
        let blueParm: Dictionary<String, Any> = [
            "name": "bleConnectionStateChange",
            "payload": [
                "deviceId": "23D6EDD2-B04C-4ED7-AACA-4A1B2F54A06A",
                "connected": true
            ]
        ]
        self.webViewInvokeJavaScript(blueParm, port: "emitEvent")
    }
    
    @objc public func bluetoothAdapterStateChange() {
        
        let blueParm: Dictionary<String, Any> = [
            "name": "bluetoothAdapterStateChange",
            "payload": [
                "discovering": false,
                "available": true
            ]
        ]
        self.webViewInvokeJavaScript(blueParm, port: "emitEvent")
    }
    
    @objc public func bluetoothDeviceFound() {
        let devices: Array<Dictionary<String, Any>> = [
            [
                "deviceId": "CF9E3AF0-98FC-4035-A6AA-51B0EBCB6349",
                "advertisServiceUUIDs": [
                    "21A0C549-7A37-495A-9A3A-2C2D9E504BAA",
                    "5F8B724E-9EF2-4E01-9F39-A588450ADA1E"
                ],
                "localName": "dev001",
                "name": "dev001",
                "advertisData": ["01", "FA", "34", "68"],
                "serviceData": [
                    "9BCE9B97-9366-4FEE-8C5F-21875B6E6941": []
                ],
                "RSSI": -57
            ],
            [
                "deviceId": "9A4DED58-E97D-4E13-8F4B-955F413FE67F",
                "advertisServiceUUIDs": [
                    "21A0C549-7A37-495A-9A3A-2C2D9E504BAA",
                    "5F8B724E-9EF2-4E01-9F39-A588450ADA1E"
                ],
                "localName": "dev002",
                "name": "dev002",
                "advertisData": ["01", "FA", "34", "50"],
                "serviceData": [
                    "9BCE9B97-9366-4FEE-8C5F-21875B6E6941": []
                ],
                "RSSI": -60
            ]
        ]
        
        let blueParm: Dictionary<String, Any> = [
            "name": "bluetoothDeviceFound",
            "payload": [
                "devices": devices
            ]
        ]
        
        self.webViewInvokeJavaScript(blueParm, port: "emitEvent")
    }
    
}
   
    
    
// delegate---BluetoothCentralManagerDelegate
extension TIoTWebVC: BluetoothCentralManagerDelegate {
    
    public func scanPerpheralsUpdatePerpherals(_ perphersArr: [CBPeripheral]!) {
        
        for onePerpher in perphersArr {
            
            if onePerpher.name == "MyLamp" {
                
                //搜索到设备后，吧设备传如H5
                self.bluetoothDeviceFound()
            }
        }
    }
    
    public func connectPerpheralSucess() {
        print("sussss")
    }
}
