//
//  DeviceListView.swift
//  TEST_UI
//
//  设备列表页面 - 严格遵循 HTML/CSS 原型图
//

import SwiftUI

struct DeviceListView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var deviceViewModel:DeviceViewModel// = DeviceViewModel()
    @ObservedObject var navigationBridge: NavigationBridge
    
    @State private var showAddDevice = false
    @State private var showUserProfile = false
    @State private var showDeleteAlert = false
    @State private var deviceToDelete: Device?
    @State private var isDeleting = false
    
    // 新增：多选框相关状态
    @State private var showChannelSelector = false
    @State private var selectedChannels: Set<Int> = [0] // 默认选择通道0
    @State private var selectedDevice: Device?
    // 初始化方法
    init(navigationBridge: NavigationBridge = NavigationBridge()) {
        self.navigationBridge = navigationBridge
        self.selectedDevice = nil
    }
    
    // 网格布局 - 2列
    let columns = [
        GridItem(.flexible(), spacing: 24),
//        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            // 背景色
            Color.bgColor.ignoresSafeArea()
            
            if deviceViewModel.isLoading && deviceViewModel.devices.isEmpty {
                // 加载状态
                loadingView
            } else if deviceViewModel.devices.isEmpty {
                // 空状态 - CSS: .empty-state
                emptyStateView
            } else {
                // 设备网格
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(deviceViewModel.devices) { device in
                            DeviceCardView(device: device, onUnbindAction: { device in
                                showDeleteConfirmation(for: device)
                            },onTapAction: { device in
                                showChannelSelector(for: device)
                            })
                        }
                    }
                    .padding(24)
                }
                .refreshable {
                    // 下拉刷新
                    await refreshDeviceList()
                }
            }
        }
        .navigationTitle("我的设备")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 右上角按钮
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // 添加设备按钮
                    Button(action: { showAddDevice = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.primaryColor)
                    }
                    
                    // 用户中心按钮
                    Button(action: { showUserProfile = true }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.primaryColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddDevice) {
            AddDeviceView(deviceViewModel: _deviceViewModel)
        }
        .sheet(isPresented: $showUserProfile) {
            UserProfileView()
        }
        .sheet(isPresented: $showChannelSelector) {
            // 修复：确保正确处理Optional类型的Device参数
            if let device = self.selectedDevice {
                ChannelSelectorView(
                    device: device,
                    selectedChannels: $selectedChannels,
                    onConfirm: { channels in
                        print("✅ ChannelSelectorView确认回调，设备: \(device.name), 通道: \(channels)")
                        showChannelSelector = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {   
                            navigateToDeviceDetail(with: channels)
                        }
                    },
                    onCancel: {
                        print("❌ ChannelSelectorView取消回调")
                        showChannelSelector = false
                        selectedChannels = [0]
                    }
                )
            } else {
                // 如果selectedDevice为nil，显示一个空的视图或错误提示
                VStack {
                    Text("Error 设备信息加载中...")
                        .font(.system(size: 16))
                        .foregroundColor(.textSecondary)
                    
                    Button("关闭") {
                        showChannelSelector = false
                    }
                    .padding()
                }
            }
        }
        .alert("解绑设备", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {
                deviceToDelete = nil
            }
            Button("解绑", role: .destructive) {
                if let device = deviceToDelete {
                    deleteDevice(device)
                }
            }
            .disabled(isDeleting)
        } message: {
            if let device = deviceToDelete {
                if isDeleting {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("正在解绑设备...")
                            .font(.caption)
                    }
                } else {
                    Text("确定要解绑设备 \"\(device.name)\" 吗？此操作不可撤销。")
                }
            }
        }
    }
    
    // 加载视图
    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryColor))
            
            Text("加载设备列表中...")
                .font(.system(size: 16))
                .foregroundColor(.textSecondary)
        }
    }
    
    // 空状态视图
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.slash")
                .font(.system(size: 80))
                .foregroundColor(.textDisabled)
            
            Text("暂无设备")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.textSecondary)
            
            Text("点击右上角 + 添加您的第一台设备")
                .font(.system(size: 14))
                .foregroundColor(.textDisabled)
            
            Button(action: { showAddDevice = true }) {
                Text("添加设备")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 140, height: 44)
                    .background(Color.primaryColor)
                    .cornerRadius(22)
            }
            .padding(.top, 10)
        }
    }
    
    // 刷新设备列表
    private func refreshDeviceList() async {
        await withCheckedContinuation { continuation in
            deviceViewModel.loadDevicesFromAPI()
            // 等待一小段时间确保数据加载完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                continuation.resume()
            }
        }
    }
    
    // 显示解绑确认对话框
    private func showDeleteConfirmation(for device: Device) {
        deviceToDelete = device
        showDeleteAlert = true
    }
    
    // 新增：显示多选框
    private func showChannelSelector(for device: Device) {
        print("🔄 showChannelSelector被调用，设备: \(device.name), ID: \(device.id)")
        
        // 先重置状态
        self.selectedDevice = device
        deviceViewModel.selectedDevice = device
        selectedChannels = [0]
        print("✅ selectedDevice已赋值: \(self.selectedDevice?.name ?? "nil")")
        
        self.showChannelSelector = true
    }
    
    // 新增：跳转到设备详情页面
    private func navigateToDeviceDetail(with channels: Set<Int>) {
        // 确保selectedDevice不为nil
        guard let device = selectedDevice else {
            print("❌ navigateToDeviceDetail: selectedDevice为nil，无法跳转")
            return
        }
        
        // 将Set转换为Array并排序
        let channelList = Array(channels).sorted()
        
        print("🎯 准备跳转到设备详情，设备: \(device.name), 通道: \(channelList)")
        
        // 创建DeviceDetailView并传递channelList参数
        if let navigationController = SwiftUIHelper.navigationController {
            let detailVC = SwiftUIHelper.createDeviceDetailViewController(
                device: device, 
                channelList: channelList
            )
            navigationController.pushViewController(detailVC, animated: true)
            
        } else {
            print("❌ 无法获取navigationController，跳转失败")
        }
    }
    
    // 执行设备解绑操作
    private func deleteDevice(_ device: Device) {
        isDeleting = true
        
        deviceViewModel.unbindDevice(device) { success, errorMessage in
            DispatchQueue.main.async {
                self.isDeleting = false
                
                if success {
                    // 解绑成功，可以显示成功提示
                    print("设备解绑成功: \(device.name)")
                } else {
                    // 解绑失败，显示错误信息
                    let errorMsg = errorMessage ?? "解绑失败"
                    print("设备解绑失败: \(errorMsg)")
                    
                    // 这里可以添加错误提示UI
                }
                
                self.deviceToDelete = nil
            }
        }
    }
}

// 设备卡片视图 - CSS: .device-card
struct DeviceCardView: View {
    let device: Device
    var onUnbindAction: (Device) -> Void
    var onTapAction: (Device) -> Void
    @State private var showMenu = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部图标区域 - CSS: .device-icon
            ZStack(alignment: .topTrailing) {
                // 渐变背景
                Rectangle()
                    .fill(Color.deviceGradient)
                    .frame(height: 120)
                
                // 摄像头图标
                Image(systemName: "video.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 在线状态指示器 - CSS: .device-status
                HStack(spacing: 4) {
                    Circle()
                        .fill(device.isOnline ? Color.successColor : Color.textDisabled)
                        .frame(width: 8, height: 8)
                    
                    Text(device.statusText)
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .padding(8)
            }
            .frame(height: 120)
            
            // 设备信息区域
            VStack(alignment: .leading, spacing: 8) {
                // 设备名称 - CSS: .device-name
                Text(device.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                // 设备位置 - CSS: .device-location
                if !device.location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        
                        Text(device.location)
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                // 设备详情 - CSS: .device-info
                HStack(spacing: 12) {
                    // 产品ID
                    HStack(spacing: 4) {
                        Image(systemName: "barcode")
                            .font(.system(size: 10))
                            .foregroundColor(.textDisabled)
                        
                        Text(device.id)
                            .font(.system(size: 11))
                            .foregroundColor(.textDisabled)
                    }
                    
                    Spacer()
                    
//                    // 信号强度
//                    HStack(spacing: 4) {
//                        Image(systemName: "wifi")
//                            .font(.system(size: 10))
//                            .foregroundColor(.textDisabled)
//                        
//                        Text("\(device.signalStrength)%")
//                            .font(.system(size: 11))
//                            .foregroundColor(.textDisabled)
//                    }.offset(x: 8, y: 8)
                    
                    // 更多操作按钮（右下角）
                    Menu {
                        Button(role: .destructive) {
                            // 触发解绑操作
                            onUnbindAction(device)
                        } label: {
                            Label("解绑设备", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .offset(x: 8, y: 8)
                }
            }
            .padding(12)
        }
        .background(Color.cardBg)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onTapAction(device)
        }
    }
}

// 新增：多选框视图组件
struct ChannelSelectorView: View {
    var device: Device
    @Binding var selectedChannels: Set<Int>
    let onConfirm: (Set<Int>) -> Void
    let onCancel: () -> Void
    
    // 修改初始化方法，不再接受Optional设备参数
    init(device: Device, selectedChannels: Binding<Set<Int>>, onConfirm: @escaping (Set<Int>) -> Void, onCancel: @escaping () -> Void) {
        self.device = device
        self._selectedChannels = selectedChannels
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        print("🎯 ChannelSelectorView初始化，传入设备: \(device.name)")
    }
    
    // 可选的通道列表（可以根据设备类型动态调整）
    private let availableChannels = [0, 1, 2, 3]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 标题区域
                VStack(spacing: 8) {
                    Text("选择视频通道")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    // 显示设备信息
                    Text("设备：\(device.productId)/\(device.deviceName)")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                .onAppear {
                    print("🎯 ChannelSelectorView显示，设备: \(device.name)")
                }
                
                // 通道选择区域
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                        ForEach(availableChannels, id: \.self) { channel in
                            ChannelOptionView(
                                channel: channel,
                                isSelected: selectedChannels.contains(channel),
                                onToggle: { toggleChannel(channel) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // 底部按钮区域
                VStack(spacing: 12) {
                    // 确定按钮
                    Button(action: {
                        onConfirm(selectedChannels)
                    }) {
                        Text("确定")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.primaryColor)
                            .cornerRadius(8)
                    }
                    
                    // 取消按钮
                    Button(action: {
                        onCancel()
                    }) {
                        Text("取消")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.bgColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.borderColor, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.cardBg)
            }
            .background(Color.bgColor.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    private func toggleChannel(_ channel: Int) {
        if selectedChannels.contains(channel) {
            selectedChannels.remove(channel)
        } else {
            selectedChannels.insert(channel)
        }
    }
}

// 新增：通道选项视图
struct ChannelOptionView: View {
    let channel: Int
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.primaryColor : Color.cardBg)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.primaryColor : Color.borderColor, lineWidth: 2)
                        )
                    
                    Text("通道\(channel)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .white : .textPrimary)
                }
                
                Text("通道 \(channel)")
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .primaryColor : .textSecondary)
            }
            .padding(8)
            .background(Color.cardBg)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

// 用户中心视图（简化版）
struct UserProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.bgColor.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // 用户头像
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.primaryColor)
                        .padding(.top, 40)
                    
                    // 用户名
                    Text(userManager.currentUsername)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // 退出登录按钮
                    Button(action: {
                        userManager.logout()
                        dismiss()
                    }) {
                        Text("退出登录")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.dangerColor)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("个人中心")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}



#Preview {
    DeviceListView()
        .environmentObject(UserManager())
        .environmentObject(DeviceViewModel())
}
