//
//  DeviceViewModel.swift
//  TEST_UI
//
//  设备数据管理
//

import Foundation
import SwiftUI
import Combine

@objc class DeviceViewModel: NSObject, ObservableObject {
    @Published var devices: [Device] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedDevice: Device?
    
    // 添加设备成功回调 - 供OC调用
    @objc var addDeviceSuccessCallback: ((_ deviceId: String, _ deviceName: String, _ location: String) -> Void)?
    // 删除设备回调 - 供OC调用
    @objc var deleteDeviceCallback: ((_ deviceId: String) -> Void)?
    
    private let devicesKey = "savedDevices"
    
    override init() {
        super.init()
        // 初始化时从 OC API 加载设备列表
        loadDevicesFromAPI()
    }
    
    /// 从 OC API 加载设备列表
    /// 完整流程：获取家庭列表 → 如果没有则创建家庭 → 获取房间列表 → 获取设备列表
    @objc func loadDevicesFromAPI() {
        isLoading = true
        errorMessage = nil
        
        print("🔄 开始加载设备列表...")
        
        // 第一步：获取家庭列表
        getFamilyList()
    }
    
    // MARK: - 私有方法：完整的加载流程
    
    /// 第一步：获取家庭列表
    private func getFamilyList() {
        DeviceAPIBridge.getFamilyList { [weak self] success, familyList, errorMsg in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success, let familyList = familyList, !familyList.isEmpty {
                    // 有家庭，使用第一个家庭
                    if let firstFamily = familyList.first,
                       let familyId = firstFamily["FamilyId"] as? String {
                        print("✅ 获取到家庭ID: \(familyId)")
                        
                        // 保存家庭ID到用户管理
                        TIoTCoreUserManage.shared().familyId = familyId
                        UserDefaults.standard.set(familyId, forKey: "firstFamilyId")
                        
                        // 第二步：获取房间列表
                        self.getRoomList(familyId: familyId)
                    } else {
                        self.isLoading = false
                        self.errorMessage = "家庭数据格式错误"
                        print("❌ 家庭数据格式错误")
                    }
                } else {
                    // 没有家庭，创建一个
                    print("⚠️ 没有家庭，开始创建...")
                    self.createFamily()
                }
            }
        }
    }
    
    /// 创建家庭（如果没有家庭）
    private func createFamily() {
        let familyName = NSLocalizedString("my_family", comment: "我的家")
        
        DeviceAPIBridge.createFamily(withName: familyName, address: "兰陵") { [weak self] success, familyId, errorMsg in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    print("✅ 创建家庭成功2")
                    
                    
                    // 重新获取家庭列表，然后继续流程
                    self.getFamilyList()
                } else {
                    self.isLoading = false
                    self.errorMessage = errorMsg ?? "创建家庭失败"
                    print("❌ 创建家庭失败2: \(self.errorMessage ?? "")")
                }
            }
        }
    }
    
    /// 第二步：获取房间列表
    private func getRoomList(familyId: String) {
        DeviceAPIBridge.getRoomList(withFamilyId: familyId) { [weak self] success, roomList, errorMsg in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    let roomCount = roomList?.count ?? 0
                    print("✅ 获取到 \(roomCount) 个房间")
                    
                    // 第三步：获取设备列表
                    self.getDeviceList(familyId: familyId)
                } else {
                    // 即使获取房间列表失败，也继续获取设备列表
                    print("⚠️ 获取房间列表失败，继续获取设备列表")
                    self.getDeviceList(familyId: familyId)
                }
            }
        }
    }
    
    /// 第三步：获取设备列表
    private func getDeviceList(familyId: String) {
        DeviceAPIBridge.getDeviceList(withFamilyId: familyId, roomId: "0") { [weak self] success, deviceList, errorMsg in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success, let deviceList = deviceList {
                    // 解析设备列表
                    self.parseDeviceList(deviceList)
                    print("✅ 成功加载 \(self.devices.count) 台设备")
                } else {
                    self.errorMessage = errorMsg ?? "获取设备列表失败"
                    self.devices = []
                    print("❌ 加载设备列表失败: \(self.errorMessage ?? "")")
                }
            }
        }
    }
    
    // 解析设备列表数据
    private func parseDeviceList(_ deviceList: [[AnyHashable: Any]]) {
        var newDevices: [Device] = []
        
        for deviceDict in deviceList {
            // 从字典中提取设备信息
            guard let deviceId = deviceDict["DeviceId"] as? String else {
                continue
            }
            
            let deviceName = deviceDict["AliasName"] as? String ?? deviceDict["DeviceName"] as? String ?? "未命名设备"
            let roomName = deviceDict["RoomName"] as? String ?? ""
            let productId = deviceDict["ProductId"] as? String ?? ""
            let actualDeviceName = deviceDict["DeviceName"] as? String ?? deviceId
            
            // 创建 Device 对象
            let device = Device(id: deviceId, name: deviceName, location: roomName, productId: productId, deviceName: actualDeviceName)
            
            // 可选：解析更多字段
            if let online = deviceDict["Online"] as? Int {
                device.isOnline = (online == 1)
            }
            
            newDevices.append(device)
        }
        
        self.devices = newDevices
        
        // 同时保存到本地缓存
        saveDevices()
    }
    
    // 从 UserDefaults 加载设备列表（作为缓存备用）
    func loadDevices() {
        if let data = UserDefaults.standard.data(forKey: devicesKey),
           let decoded = try? JSONDecoder().decode([Device].self, from: data) {
            self.devices = decoded
        }
    }
    
    // 保存设备列表到 UserDefaults
    func saveDevices() {
        if let encoded = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(encoded, forKey: devicesKey)
        }
    }
    
    // 添加设备
    func addDevice(id: String, name: String, location: String) -> Bool {
        // 检查设备ID是否已存在
        if devices.contains(where: { $0.id == id }) {
            return false
        }
        
        let newDevice = Device(id: id, name: name, location: location)
        devices.append(newDevice)
        saveDevices()
        
        // 触发回调，让OC处理实际的添加设备逻辑
        DispatchQueue.main.async {
            self.addDeviceSuccessCallback?(id, name, location)
        }
        
        return true
    }
    
    // 删除设备
    func deleteDevice(at offsets: IndexSet) {
        for index in offsets {
            let device = devices[index]
            // 触发回调
            DispatchQueue.main.async {
                self.deleteDeviceCallback?(device.id)
            }
        }
        devices.remove(atOffsets: offsets)
        saveDevices()
    }
    
    // 删除指定设备
    @objc func deleteDevice(deviceId: String) {
        if let index = devices.firstIndex(where: { $0.id == deviceId }) {
            devices.remove(at: index)
            saveDevices()
        }
    }
    
    // 解绑设备（调用真正的API）
    func unbindDevice(_ device: Device, completion: @escaping (Bool, String?) -> Void) {
        // 获取家庭ID
//        guard let familyId = TIoTCoreUserManage.shared().familyId, !familyId.isEmpty else {
//            completion(false, "未找到家庭ID")
//            return
//        }
        let familyId = TIoTCoreUserManage.shared().familyId
        
        // 检查必要的参数
        guard !device.productId.isEmpty else {
            completion(false, "设备缺少产品ID")
            return
        }
        
        guard !device.deviceName.isEmpty else {
            completion(false, "设备缺少设备名称")
            return
        }
        
        print("🔄 开始解绑设备: \(device.name), productId: \(device.productId), deviceName: \(device.deviceName)")
        
        // 调用API解绑设备
        DeviceAPIBridge.unbindDevice(withFamilyId: familyId, productId: device.productId, deviceName: device.deviceName) { [weak self] success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    print("✅ 设备解绑成功: \(device.name)")
                    
                    // 从本地列表中移除设备
                    if let index = self?.devices.firstIndex(where: { $0.id == device.id }) {
                        self?.devices.remove(at: index)
                        self?.saveDevices()
                        
                        // 触发回调
                        self?.deleteDeviceCallback?(device.id)
                    }
                    
                    completion(true, nil)
                } else {
                    let errorMsg = errorMessage ?? "设备解绑失败"
                    print("❌ 设备解绑失败: \(device.name) - \(errorMsg)")
                    completion(false, errorMsg)
                }
            }
        }
    }
    
    // 更新设备
    func updateDevice(_ device: Device) {
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index] = device
            saveDevices()
        }
    }
    
    // 获取设备
    func getDevice(by id: String) -> Device? {
        return devices.first(where: { $0.id == id })
    }
    
    // OC调用此方法添加设备
    @objc func addDeviceFromOC(deviceId: String, deviceName: String, location: String, isOnline: Bool) {
        let newDevice = Device(id: deviceId, name: deviceName, location: location)
        devices.append(newDevice)
        saveDevices()
    }
    
    // OC调用此方法更新设备列表
    @objc func updateDevicesFromOC(deviceArray: [[String: Any]]) {
        var newDevices: [Device] = []
        for deviceDict in deviceArray {
            if let deviceId = deviceDict["DeviceId"] as? String,
               let deviceName = deviceDict["AliasName"] as? String {
                let location = deviceDict["RoomName"] as? String ?? ""
                let device = Device(id: deviceId, name: deviceName, location: location)
                newDevices.append(device)
            }
        }
        self.devices = newDevices
        saveDevices()
    }
    
    // 清空设备列表
    @objc func clearDevices() {
        devices.removeAll()
        saveDevices()
    }
}
