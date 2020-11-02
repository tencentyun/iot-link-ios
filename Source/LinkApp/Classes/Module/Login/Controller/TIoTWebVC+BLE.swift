//
//  TIoTWebVC+BLE.swift
//  LinkApp
//
//  Created by eagleychen on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation

extension TIoTWebVC: BluetoothCentralManagerDelegate {
    public func scanPerpheralsUpdatePerpherals(_ perphersArr: [CBPeripheral]!) {
        
        for onePerpher in perphersArr {
            
            if onePerpher.name == "MyLamp" {
                
                
                //                let blue = BluetoothCentralManager.shareBluetooth()!
                //                blue.connect(onePerpher)
                
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
                            "9BCE9B97-9366-4FEE-8C5F-21875B6E6941"
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
                            "9BCE9B97-9366-4FEE-8C5F-21875B6E6941"
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
    }
    
    public func connectPerpheralSucess() {
        print("sussss")
    }
}
