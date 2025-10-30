//
//  DeviceManager.swift
//  LinkSDKDemo
//
//  设备管理器 - 桥接 OC 设备绑定逻辑
//

import Foundation
import UIKit

/// 设备管理器 - 封装原有 OC 设备绑定逻辑
/// 注意：实际的绑定逻辑在 DeviceAPIBridge.m 中实现
@objc class DeviceManager: NSObject {
    
    // 单例
    @objc static let shared = DeviceManager()
    
    private override init() {
        super.init()
    }
    
    /// 绑定设备（使用设备签名）
    /// - Parameters:
    ///   - signature: 设备签名（扫码或手动输入）
    ///   - completion: 完成回调 (success: Bool, message: String?)
    @objc func bindDevice(withSignature signature: String, completion: @escaping (Bool, String?) -> Void) {
        // 调用 OC 桥接类来执行绑定
        DeviceAPIBridge.bindDevice(withSignature: signature) { success, message in
            completion(success, message)
        }
    }
}
