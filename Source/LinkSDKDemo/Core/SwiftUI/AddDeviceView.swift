//
//  AddDeviceView.swift
//  TEST_UI
//
//  添加设备页面 - 严格遵循 HTML/CSS 原型图
//

import SwiftUI

struct AddDeviceView: View {
    @EnvironmentObject var deviceViewModel: DeviceViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var deviceSignature = ""  // 改为设备签名（扫码或手动输入）
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showScanner = false  // 控制扫描器显示
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color.bgColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 扫描二维码区域 - CSS: .scan-area
                        VStack(spacing: 16) {
                            ZStack {
                                // 虚线边框
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                                    .foregroundColor(.borderColor)
                                    .frame(height: 200)
                                
                                VStack(spacing: 12) {
                                    // 二维码图标
                                    Image(systemName: "qrcode")
                                        .font(.system(size: 64))
                                        .foregroundColor(.primaryColor)
                                    
                                    Text("点击扫描设备二维码")
                                        .font(.system(size: 15))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .onTapGesture {
                                // 打开扫描器
                                showScanner = true
                            }
                        }
                        .padding(.top, 20)
                        
                        // 分隔线 - CSS: .divider
                        HStack {
                            Rectangle()
                                .fill(Color.borderColor)
                                .frame(height: 1)
                            
                            Text("或手动输入")
                                .font(.system(size: 13))
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal, 12)
                            
                            Rectangle()
                                .fill(Color.borderColor)
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        // 手动输入表单 - CSS: .form-group
                        VStack(spacing: 16) {
                            // 设备签名输入框
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 4) {
                                    Text("设备签名")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.textPrimary)
                                    
                                    Text("*")
                                        .foregroundColor(.dangerColor)
                                }
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "barcode")
                                        .foregroundColor(.textSecondary)
                                        .frame(width: 20)
                                    
                                    TextField("请输入设备签名或扫描二维码", text: $deviceSignature)
                                        .font(.system(size: 15))
                                        .autocapitalization(.none)
                                        .disabled(isLoading)
                                }
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.borderColor, lineWidth: 1)
                                )
                            }
                            
                            // 提示信息
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.textSecondary)
                                    .font(.system(size: 14))
                                
                                Text("设备签名可通过扫描设备二维码获取，或手动输入")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        // 添加按钮 - CSS: .add-btn
                        Button(action: handleAddDevice) {
                            HStack(spacing: 8) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isLoading ? "绑定中..." : "添加设备")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(isLoading ? Color.primaryColor.opacity(0.6) : Color.primaryColor)
                            .cornerRadius(8)
                        }
                        .disabled(isLoading)
                        .padding(.top, 16)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("添加设备")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("确定", role: .cancel) {
                    if alertMessage.contains("成功") {
//                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                QRCodeScannerView { scanResult in
                    handleScanResult(scanResult)
                }
            }
        }
    }
    
    // 处理扫描结果 - 解析 JSON 并提取 Signature
    func handleScanResult(_ scanResult: String) {
        // 尝试解析 JSON
        if let jsonData = scanResult.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    // 提取 Signature 字段
                    if let signature = json["Signature"] as? String {
                        deviceSignature = signature
                        
                        // 可选：显示提取成功的提示
                        alertMessage = "扫描成功！已自动填入设备签名"
                        showAlert = true
                    } else {
                        alertMessage = "二维码格式错误：未找到 Signature 字段"
                        showAlert = true
                    }
                } else {
                    alertMessage = "二维码格式错误：无法解析 JSON"
                    showAlert = true
                }
            } catch {
                alertMessage = "二维码格式错误：\(error.localizedDescription)"
                showAlert = true
            }
        } else {
            alertMessage = "二维码数据无效"
            showAlert = true
        }
    }
    
    // 处理添加设备 - 调用原有OC业务逻辑
    func handleAddDevice() {
        // 验证输入
        guard !deviceSignature.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "请输入设备签名或扫描二维码"
            showAlert = true
            return
        }
        
        // 开始加载
        isLoading = true
        
        // 调用 OC 的设备绑定方法
        DeviceManager.shared.bindDevice(
            withSignature: deviceSignature.trimmingCharacters(in: .whitespacesAndNewlines)
        ) { [self] success, message in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    self.alertMessage = message ?? "设备添加成功！"
                    self.showAlert = true
                    
                    // 从 OC API 重新加载设备列表
                    self.deviceViewModel.loadDevicesFromAPI()
                    
                    dismiss()
                } else {
                    self.alertMessage = message ?? "设备添加失败，请重试"
                    self.showAlert = true
                }
            }
        }
    }
}

#Preview {
    AddDeviceView()
        .environmentObject(DeviceViewModel())
}
