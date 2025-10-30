//
//  DeviceDetailView.swift
//  TEST_UI
//
//  设备详情页面 - 严格遵循 HTML/CSS 原型图
//  包含视频播放区域、云台控制面板
//

import SwiftUI
import Combine
import IoTVideoCloud
import AVFoundation
import TXLiteAVSDK_TRTC

// 新增：专门处理IoTVideoCloudDelegate协议的ViewModel类
class DeviceDetailViewModel: NSObject, ObservableObject, IoTVideoCloudDelegate {
    let device: Device
    let channelList: [Int]
    
    @Published var currentTime = Date()
    @Published var isMuted = false
    @Published var videoQuality = "自动" // 自动/标清/高清
    @Published var showPTZControl = false // 显示云台控制面板
    @Published var ptzMessage = ""
    @Published var showPTZMessage = false
    
    // 修改：支持多设备远程视频状态
    @Published var remoteVideoDevices: [String: Bool] = [:] // deviceId -> isAvailable
    
    // 新增：存储多个预览视图及其对应的设备ID
    @Published var previewViewMap: [String: UIView] = [:] // deviceId -> UIView
    
    // 新增：维护视图创建顺序
    @Published var previewViewOrder: [String] = [] // 按创建顺序存储deviceId
    
    // 新增：本地预览视图
    @Published var localPreviewView = UIView()
    
    // 新增：对讲相关状态
    @Published var isTalking = false
    @Published var showLocalPreview = false
    @Published var localPreviewPosition = CGPoint(x: 100, y: 100) // 默认位置
    
    // 定时器 - 更新时间戳
    private var timer: Timer?
    
    // 回调闭包
    var onJoinRoomSuccess: (() -> Void)?
    var onJoinRoomFailed: ((String) -> Void)?
    var onUserVideoAvailable: ((String) -> Void)?
    
    init(device: Device, channelList: [Int]) {
        self.device = device
        self.channelList = channelList
        super.init()
        
        // 设置代理
        IoTVideoCloud.sharedInstance().delegate = self
    }
    
    deinit {
        previewViewMap.removeAll()
        timer?.invalidate()
    }
    
    // MARK: - IoTVideoCloudDelegate
    
    func joinRoomSuccess() {
        print("视频通话启动成功")
        onJoinRoomSuccess?()
    }
    
    func joinRoomFailed(_ errmsg: String) {
        print("视频通话启动失败，错误信息：\(errmsg)")
        onJoinRoomFailed?(errmsg)
    }
    
    func onUserVideoAvailable(_ channel: NSNumber, device deviceId: String, available: Bool) {
        handleVideoAvailable(channel, deviceId: deviceId, available: available)
    }
    
    private func handleVideoAvailable(_ channel: NSNumber, deviceId: String, available: Bool) {
        // 更新设备状态
        self.remoteVideoDevices[deviceId] = available
        
        if available {
            // 如果该设备已有预览视图，先清理旧的
            if let existingView = previewViewMap[deviceId] {
                // 从TRTC停止远程视图
                let trtcInstance = IoTVideoCloud.sharedInstance().getTRTCInstance(forDevice: channel)
                trtcInstance.stopRemoteView(deviceId, streamType: .big)
                
                // 从映射中移除
                previewViewMap.removeValue(forKey: deviceId)
                previewViewOrder.removeAll { $0 == deviceId }
                print("设备 \(deviceId) 已有预览视图，先清理旧的")
            }
            
            // 为设备创建新的预览视图
            let previewView = UIView()
            previewView.backgroundColor = .black
            
            // 存储到映射和顺序数组中
            previewViewMap[deviceId] = previewView
            previewViewOrder.append(deviceId)
            
            // 使用正确的TRTC实例启动远程视图
            let trtcInstance = IoTVideoCloud.sharedInstance().getTRTCInstance(forDevice: channel)
            trtcInstance.startRemoteView(deviceId, streamType: .big, view: previewView)
            
            print("设备 \(deviceId) 视频可用，创建预览视图，当前共有\(previewViewMap.count)个预览视图")
        } else {
            // 视频不可用时，精确清理该设备的预览视图
            if let existingView = previewViewMap[deviceId] {
                // 从TRTC停止远程视图
                let trtcInstance = IoTVideoCloud.sharedInstance().getTRTCInstance(forDevice: channel)
                trtcInstance.stopRemoteView(deviceId, streamType: .big)
                
                // 从映射和顺序数组中移除
                previewViewMap.removeValue(forKey: deviceId)
                previewViewOrder.removeAll { $0 == deviceId }
                
                print("设备 \(deviceId) 视频不可用，精确清理预览视图，剩余\(previewViewMap.count)个预览视图")
            }
        }
        
        // 通知View更新
        self.onUserVideoAvailable?(deviceId)
    }
    
    // MARK: - 视频通话相关方法
    
    func startVideoCall() {
        // 创建IoTVideoParams对象
        let videoparams = IoTVideoParams()
        
        // 设置必需参数
        videoparams.openId = TIoTCoreUserManage.shared().userId ?? "" // 用户系统userid，如微信授权的openid
        videoparams.productId = device.productId
        videoparams.deviceName = device.deviceName
        videoparams.avType = "video" // audio: 单音频 - video: 音视频
        videoparams.sessionId = "12jjelsodfx" // 会话ID
        videoparams.channelList = self.channelList // 通道列表[0, 1, 2]
        
        // 启动视频服务
        let videoEncParam = TRTCVideoEncParam()
        videoEncParam.videoResolution = ._320_240 //TRTCVideoResolution_320_240
        videoEncParam.videoFps = 15
        videoEncParam.videoBitrate = 250
        videoEncParam.resMode = .portrait
        videoEncParam.enableAdjustRes = true
        TRTCCloud.sharedInstance().setVideoEncoderParam(videoEncParam)
        
        IoTVideoCloud.sharedInstance().startApp(with: videoparams)
    }
    
    // MARK: - 对讲功能
    
    func startTalking() {
        isTalking = true
        showLocalPreview = true
        
        // 启动本地预览（需要在View中调用）
        print("开始对讲，显示本地预览窗口")
    }
    
    func stopTalking() {
        isTalking = false
        showLocalPreview = false
        
        // 停止本地预览（需要在View中调用）
        print("停止对讲，隐藏本地预览窗口")
    }
    
    func updateLocalPreviewPosition(_ position: CGPoint) {
        localPreviewPosition = position
    }
    
    // MARK: - 其他业务方法
    
    func cycleVideoQuality() {
        switch videoQuality {
        case "自动":
            videoQuality = "标清"
        case "标清":
            videoQuality = "高清"
        case "高清":
            videoQuality = "自动"
        default:
            videoQuality = "自动"
        }
    }
    
    func handlePTZControl(_ direction: String) {
        ptzMessage = "云台\(direction)"
        showPTZMessage = true
        
        // 2秒后隐藏提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showPTZMessage = false
        }
    }
    
    // 修改：获取所有可用的预览视图（按创建顺序）
    func getAvailablePreviewViews() -> [UIView] {
        return previewViewOrder.compactMap { previewViewMap[$0] }
    }
}

struct DeviceDetailView: View {
    let device: Device
    let channelList: [Int]
    // 使用StateObject管理ViewModel
    @StateObject private var viewModel: DeviceDetailViewModel
    
    // 修改：移除单个预览视图，使用ViewModel管理的多个视图
    
    init(device: Device, channelList: [Int]) {
        self.device = device
        self._viewModel = StateObject(wrappedValue: DeviceDetailViewModel(device: device, channelList: channelList))
        
        self.channelList = channelList
    }
    
    var body: some View {
        ZStack {
            Color.bgColor.ignoresSafeArea(edges: .bottom)
            
            VStack(spacing: 0) {
                // 视频播放区域 - CSS: .video-container (height: 280px)
                videoPlayerView
                    .frame(height: 280)
                
                // 底部控制栏 - CSS: .control-bar
                controlBar
                    .padding(.vertical, 16)
                
                // 云台控制面板（可展开/收起）
                if viewModel.showPTZControl {
                    ptzControlPanel
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                
                // 底部操作按钮
                bottomActionButtons
                    .padding(.bottom, 20)
            }
            
            // 新增：可拖动的本地预览窗口
            if viewModel.showLocalPreview {
                DraggableLocalPreviewView(
                    position: viewModel.localPreviewPosition,
                    localPreviewView: $viewModel.localPreviewView,
                    onPositionChanged: { newPosition in
                        viewModel.updateLocalPreviewPosition(newPosition)
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle(device.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 设置回调闭包
            viewModel.onJoinRoomSuccess = {
                // 处理进房成功逻辑
                print("DeviceDetailView: 视频通话启动成功")
            }
            
            viewModel.onJoinRoomFailed = { errorMessage in
                // 处理进房失败逻辑
                print("DeviceDetailView: 视频通话启动失败 - \(errorMessage)")
            }
            
            viewModel.onUserVideoAvailable = { deviceId in
                // 视频可用性回调，View会自动更新
                print("设备 \(deviceId) 视频可用，UI已更新")
            }
            
            viewModel.startVideoCall()
        }
        .onDisappear {
            IoTVideoCloud.sharedInstance().stopAppService("")
        }
        .overlay(
            // PTZ 操作提示
            Group {
                if viewModel.showPTZMessage {
                    Text(viewModel.ptzMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .transition(.opacity)
                }
            }
        )
    }
    
    // 视频播放器视图 - 支持多设备显示
    var videoPlayerView: some View {
        ZStack {
            // 显示所有可用的预览视图
            Color.black
            
            if viewModel.getAvailablePreviewViews().isEmpty {
                // 没有可用视频时显示占位符
                Image(systemName: "video.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white.opacity(0.3))
            } else {
                // 显示多个预览视图
                MultiPreviewView(previewViews: viewModel.getAvailablePreviewViews())
            }
            
            // 顶部信息栏 - CSS: .video-header
            VStack {
                HStack {
                    // 设备名称（居中）
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("\(device.productId)/\(device.deviceName)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                        
                        // 状态显示
                        Text(viewModel.getAvailablePreviewViews().isEmpty ? "等待连接" : "\(viewModel.getAvailablePreviewViews().count)个设备在线")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.3))
                
                Spacer()
            }
            
            // 右侧悬浮控制按钮 - CSS: .video-controls
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // 电源按钮
                        CircleButton(icon: "power", color: .white.opacity(0.9)) {
                            // 电源控制 - 启动视频通话
//                            viewModel.startVideoCall()
                        }
                        
                        // 声音按钮
                        CircleButton(icon: viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill", color: .white.opacity(0.9)) {
                            viewModel.isMuted.toggle()
                        }
                        
                        // 画质按钮
                        CircleButton(text: viewModel.videoQuality, color: .white.opacity(0.9)) {
                            viewModel.cycleVideoQuality()
                        }
                        
                        // 全屏按钮
                        CircleButton(icon: "arrow.up.left.and.arrow.down.right", color: .white.opacity(0.9)) {
                            // 全屏功能
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 60)
                }
                
                Spacer()
            }
        }
    }
    
    // 底部控制栏 - 4个功能按钮
    var controlBar: some View {
        HStack(spacing: 0) {
            // 对讲按钮
            ControlButton(icon: viewModel.isTalking ? "mic.fill" : "mic.slash.fill", 
                         title: viewModel.isTalking ? "对讲中" : "对讲", 
                         isActive: viewModel.isTalking) {
                if viewModel.isTalking {
                    // 停止对讲
                    viewModel.stopTalking()
                    TRTCCloud.sharedInstance().stopLocalPreview()
                } else {
                    // 开始对讲
                    viewModel.startTalking()
                    TRTCCloud.sharedInstance().muteLocalVideo(.big, mute: false)
                    TRTCCloud.sharedInstance().stopLocalPreview()
                    
                    TRTCCloud.sharedInstance().startLocalPreview(true, view: viewModel.localPreviewView)
                    TRTCCloud.sharedInstance().startLocalAudio(.speech)
                }
            }
            
            // 截图按钮
            ControlButton(icon: "camera.fill", title: "截图") {
                // 截图功能
            }
            
            // 录像按钮
            ControlButton(icon: "video.fill", title: "录像") {
                // 录像功能
            }
            
            // 云台按钮
            ControlButton(icon: "arrow.up.and.down.and.arrow.left.and.right", title: "云台", isActive: viewModel.showPTZControl) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.showPTZControl.toggle()
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // 云台控制面板 - CSS: .ptz-control
    var ptzControlPanel: some View {
        VStack(spacing: 20) {
            Text("云台控制")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textPrimary)
                .padding(.top, 20)
            
            // 圆形控制盘 - CSS: width: 280px, height: 280px
            ZStack {
                // 背景圆
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 280, height: 280)
                
                // 外圈边框
                Circle()
                    .stroke(Color.borderColor, lineWidth: 2)
                    .frame(width: 280, height: 280)
                
                // 5个控制点
                // 上方控制点 (top: 15%)
                PTZControlPoint(icon: "chevron.up", position: .top) {
                    viewModel.handlePTZControl("向上")
                    TRTCCloud.sharedInstance().sendCustomCmdMsg(1, data: "ptz_up".data(using: .utf8)!, reliable: true, ordered: true)
                }
                .offset(y: -280 * 0.35)
                
                // 下方控制点 (top: 85%)
                PTZControlPoint(icon: "chevron.down", position: .bottom) {
                    viewModel.handlePTZControl("向下")
                    TRTCCloud.sharedInstance().sendCustomCmdMsg(1, data: "ptz_down".data(using: .utf8)!, reliable: true, ordered: true)
                }
                .offset(y: 280 * 0.35)
                
                // 左侧控制点 (left: 15%)
                PTZControlPoint(icon: "chevron.left", position: .left) {
                    viewModel.handlePTZControl("向左")
                    TRTCCloud.sharedInstance().sendCustomCmdMsg(1, data: "ptz_left".data(using: .utf8)!, reliable: true, ordered: true)
                }
                .offset(x: -280 * 0.35)
                
                // 右侧控制点 (left: 85%)
                PTZControlPoint(icon: "chevron.right", position: .right) {
                    viewModel.handlePTZControl("向右")
                    TRTCCloud.sharedInstance().sendCustomCmdMsg(1, data: "ptz_right".data(using: .utf8)!, reliable: true, ordered: true)
                }
                .offset(x: 280 * 0.35)
                
                // 中心复位按钮
                PTZControlPoint(icon: "scope", position: .center) {
                    viewModel.handlePTZControl("复位")
                    TRTCCloud.sharedInstance().sendCustomCmdMsg(1, data: "ptz_reset".data(using: .utf8)!, reliable: true, ordered: true)
                }
            }
            .frame(width: 280, height: 280)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.cardBg)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    // 底部操作按钮
    var bottomActionButtons: some View {
        HStack(spacing: 20) {
            // 回看按钮
            ActionButton(icon: "play.circle.fill", title: "回看", color: .primaryColor) {
                // 回看功能
            }
            
            // 分享按钮
            ActionButton(icon: "square.and.arrow.up", title: "分享", color: .primaryColor) {
                // 分享功能
            }
        }
        .padding(.horizontal, 20)
    }
    
    // 时间字符串
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: viewModel.currentTime)
    }
}

// 新增：多预览视图组件
struct MultiPreviewView: View {
    let previewViews: [UIView]

    var body: some View {
        GeometryReader { geometry in
            if previewViews.isEmpty {
                // 没有预览视图时显示占位符
                Color.black
                    .overlay(
                        Image(systemName: "video.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.3))
                    )
            } else if previewViews.count == 1 {
                // 单个设备：全屏显示
                let view = previewViews.first!
                TRTCPreviewView(trtcPreviewView: .constant(view))
                    .id("preview_single")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 多个设备：网格布局
                let columns = min(previewViews.count, 2)
                let rows = (previewViews.count + columns - 1) / columns
                
                VStack(spacing: 2) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<columns, id: \.self) { column in
                                let index = row * columns + column
                                if index < previewViews.count {
                                    let view = previewViews[index]
                                    TRTCPreviewView(trtcPreviewView: .constant(view))
                                        .id("preview_\(index)")
                                        .frame(
                                            width: geometry.size.width / CGFloat(columns) - 2,
                                            height: geometry.size.height / CGFloat(rows) - 2
                                        )
                                } else {
                                    // 填充空白区域
                                    Color.black
                                        .frame(
                                            width: geometry.size.width / CGFloat(columns) - 2,
                                            height: geometry.size.height / CGFloat(rows) - 2
                                        )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// 新增：可拖动的本地预览窗口组件
struct DraggableLocalPreviewView: View {
    @State private var position: CGPoint
    @Binding var localPreviewView: UIView
    let onPositionChanged: (CGPoint) -> Void
    
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    init(position: CGPoint, localPreviewView: Binding<UIView>, onPositionChanged: @escaping (CGPoint) -> Void) {
        self._position = State(initialValue: position)
        self._localPreviewView = localPreviewView
        self.onPositionChanged = onPositionChanged
    }
    
    var body: some View {
        ZStack {
            // 本地预览视图
            LocalPreviewView(localPreviewView: $localPreviewView)
                .frame(width: 120, height: 160)
                .background(Color.black)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // 关闭本地预览
                        onPositionChanged(CGPoint(x: 100, y: 100)) // 重置位置
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(4)
                }
                Spacer()
            }
        }
        .frame(width: 120, height: 160)
        .position(position)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    dragOffset = value.translation
                    position = CGPoint(
                        x: value.startLocation.x + value.translation.width,
                        y: value.startLocation.y + value.translation.height
                    )
                }
                .onEnded { value in
                    isDragging = false
                    dragOffset = .zero
                    onPositionChanged(position)
                }
        )
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }
}

// 新增：本地预览视图包装器
struct LocalPreviewView: UIViewRepresentable {
    @Binding var localPreviewView: UIView
    
    func makeUIView(context: Context) -> UIView {
        localPreviewView.backgroundColor = .black
        return localPreviewView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 视图更新逻辑
    }
}

// 新增：TRTC预览视图包装器
struct TRTCPreviewView: UIViewRepresentable {
    @Binding var trtcPreviewView: UIView
    
    func makeUIView(context: Context) -> UIView {
        print(" TRTCPreviewView makeUIView被调用，视图: \(trtcPreviewView)")
        if trtcPreviewView.superview != nil {
            print("⚠️ 警告：UIView已经有父视图，创建新的容器视图")
        }
        trtcPreviewView.backgroundColor = .black
        return trtcPreviewView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 视图更新逻辑
        print(" TRTCPreviewView updateUIView被调用")
    }
}


// 圆形按钮组件
struct CircleButton: View {
    var icon: String = ""
    var text: String = ""
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 44, height: 44)
                
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                } else {
                    Text(text)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(color)
                }
            }
        }
    }
}

// 控制按钮组件
struct ControlButton: View {
    let icon: String
    let title: String
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isActive ? .primaryColor : .textSecondary)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isActive ? .primaryColor : .textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// 云台控制点组件
struct PTZControlPoint: View {
    let icon: String
    let position: PTZPosition
    let action: () -> Void
    
    enum PTZPosition {
        case top, bottom, left, right, center
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(position == .center ? Color.primaryColor : Color.white)
                    .frame(width: 50, height: 50)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(position == .center ? .white : .primaryColor)
            }
        }
    }
}

// 操作按钮组件
struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(color)
            .cornerRadius(8)
        }
    }
}

// 圆角扩展
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationView {
        DeviceDetailView(device: Device.sampleDevices[0], channelList: [0,1])
    }
}
