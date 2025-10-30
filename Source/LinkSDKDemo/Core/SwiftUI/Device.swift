//
//  Device.swift
//  TEST_UI
//
//  设备数据模型
//

import Foundation

@objc class Device: NSObject, Identifiable, Codable {
    @objc var id: String
    @objc var name: String
    @objc var location: String
    @objc var productId: String // 产品ID，用于解绑设备
    @objc var deviceName: String // 设备名称，用于解绑设备
    @objc var isOnline: Bool
    @objc var signalStrength: Int // 0-100
    @objc var firmwareVersion: String
    var addedDate: Date
    
    // 设备设置
    @objc var motionDetectionEnabled: Bool
    @objc var soundDetectionEnabled: Bool
    @objc var nightVisionEnabled: Bool
    @objc var autoTrackingEnabled: Bool
    @objc var notificationEnabled: Bool
    
    // 初始化方法
    @objc init(id: String, name: String, location: String = "", productId: String = "", deviceName: String = "") {
        self.id = id
        self.name = name
        self.location = location
        self.productId = productId
        self.deviceName = deviceName.isEmpty ? id : deviceName // 如果deviceName为空，使用id作为默认值
        self.isOnline = Bool.random() // 模拟在线状态
        self.signalStrength = Int.random(in: 60...100) // 模拟信号强度
        self.firmwareVersion = "v2.1.0"
        self.addedDate = Date()
        
        // 默认设置
        self.motionDetectionEnabled = true
        self.soundDetectionEnabled = true
        self.nightVisionEnabled = true
        self.autoTrackingEnabled = false
        self.notificationEnabled = true
        
        super.init()
    }
    
    // Codable支持
    enum CodingKeys: String, CodingKey {
        case id, name, location, productId, deviceName, isOnline, signalStrength, firmwareVersion, addedDate
        case motionDetectionEnabled, soundDetectionEnabled, nightVisionEnabled
        case autoTrackingEnabled, notificationEnabled
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(String.self, forKey: .location)
        productId = try container.decode(String.self, forKey: .productId)
        deviceName = try container.decode(String.self, forKey: .deviceName)
        isOnline = try container.decode(Bool.self, forKey: .isOnline)
        signalStrength = try container.decode(Int.self, forKey: .signalStrength)
        firmwareVersion = try container.decode(String.self, forKey: .firmwareVersion)
        addedDate = try container.decode(Date.self, forKey: .addedDate)
        motionDetectionEnabled = try container.decode(Bool.self, forKey: .motionDetectionEnabled)
        soundDetectionEnabled = try container.decode(Bool.self, forKey: .soundDetectionEnabled)
        nightVisionEnabled = try container.decode(Bool.self, forKey: .nightVisionEnabled)
        autoTrackingEnabled = try container.decode(Bool.self, forKey: .autoTrackingEnabled)
        notificationEnabled = try container.decode(Bool.self, forKey: .notificationEnabled)
        super.init()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(location, forKey: .location)
        try container.encode(productId, forKey: .productId)
        try container.encode(deviceName, forKey: .deviceName)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encode(signalStrength, forKey: .signalStrength)
        try container.encode(firmwareVersion, forKey: .firmwareVersion)
        try container.encode(addedDate, forKey: .addedDate)
        try container.encode(motionDetectionEnabled, forKey: .motionDetectionEnabled)
        try container.encode(soundDetectionEnabled, forKey: .soundDetectionEnabled)
        try container.encode(nightVisionEnabled, forKey: .nightVisionEnabled)
        try container.encode(autoTrackingEnabled, forKey: .autoTrackingEnabled)
        try container.encode(notificationEnabled, forKey: .notificationEnabled)
    }
    
    // 获取信号强度描述
    var signalStrengthText: String {
        if signalStrength >= 80 {
            return "信号强"
        } else if signalStrength >= 50 {
            return "信号中"
        } else {
            return "信号弱"
        }
    }
    
    // 获取在线状态文本
    var statusText: String {
        isOnline ? "在线" : "离线"
    }
}

// 示例数据
extension Device {
    static let sampleDevices: [Device] = [
        Device(id: "CAM001", name: "客厅摄像头", location: "客厅", productId: "FIDVWKRYS9", deviceName: "ipc_1"),
        Device(id: "CAM002", name: "卧室摄像头", location: "主卧", productId: "FIDVWKRYS9", deviceName: "ipc_2"),
        Device(id: "CAM003", name: "门口摄像头", location: "大门", productId: "FIDVWKRYS9", deviceName: "ipc_3")
    ]
}
