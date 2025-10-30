//
//  QRCodeScannerView.swift
//  LinkSDKDemo
//
//  二维码扫描器视图 - 使用系统相机扫描二维码
//

import SwiftUI
import AVFoundation

// MARK: - 二维码扫描器视图
struct QRCodeScannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var onScanSuccess: (String) -> Void
    
    var body: some View {
        ZStack {
            // 相机预览层
            QRCodeScannerViewController(onScanSuccess: { result in
                onScanSuccess(result)
                dismiss()
            }, onError: { error in
                alertMessage = error
                showAlert = true
            })
            .edgesIgnoringSafeArea(.all)
            
            // 扫描框和提示
            VStack {
                Spacer()
                
                // 扫描框
                ZStack {
                    // 半透明遮罩
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // 扫描区域（透明）
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 250, height: 250)
                        .background(Color.clear)
                    
                    // 四个角的装饰
                    VStack {
                        HStack {
                            ScannerCorner(position: .topLeft)
                            Spacer()
                            ScannerCorner(position: .topRight)
                        }
                        Spacer()
                        HStack {
                            ScannerCorner(position: .bottomLeft)
                            Spacer()
                            ScannerCorner(position: .bottomRight)
                        }
                    }
                    .frame(width: 250, height: 250)
                }
                .frame(width: 250, height: 250)
                
                // 提示文字
                Text("将二维码放入框内，即可自动扫描")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                Spacer()
            }
            
            // 顶部导航栏
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("返回")
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    
                    Spacer()
                }
                .background(Color.black.opacity(0.3))
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) {
                dismiss()
            }
        }
    }
}

// MARK: - 扫描框角装饰
struct ScannerCorner: View {
    enum Position {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    let position: Position
    
    var body: some View {
        ZStack {
            switch position {
            case .topLeft:
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle().fill(Color.green).frame(width: 30, height: 4)
                    Rectangle().fill(Color.green).frame(width: 4, height: 30)
                }
            case .topRight:
                VStack(alignment: .trailing, spacing: 0) {
                    Rectangle().fill(Color.green).frame(width: 30, height: 4)
                    Rectangle().fill(Color.green).frame(width: 4, height: 30)
                }
            case .bottomLeft:
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle().fill(Color.green).frame(width: 4, height: 30)
                    Rectangle().fill(Color.green).frame(width: 30, height: 4)
                }
            case .bottomRight:
                VStack(alignment: .trailing, spacing: 0) {
                    Rectangle().fill(Color.green).frame(width: 4, height: 30)
                    Rectangle().fill(Color.green).frame(width: 30, height: 4)
                }
            }
        }
    }
}

// MARK: - UIKit 相机控制器包装
struct QRCodeScannerViewController: UIViewControllerRepresentable {
    var onScanSuccess: (String) -> Void
    var onError: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.onScanSuccess = onScanSuccess
        controller.onError = onError
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        // 不需要更新
    }
}

// MARK: - 实际的相机扫描控制器
class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onScanSuccess: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.stopRunning()
            }
        }
    }
    
    func setupCamera() {
        // 检查相机权限
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.onError?("需要相机权限才能扫描二维码")
                    }
                }
            }
        case .denied, .restricted:
            onError?("相机权限被拒绝，请在设置中开启")
        @unknown default:
            onError?("未知的相机权限状态")
        }
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            onError?("无法访问相机")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            onError?("无法创建视频输入：\(error.localizedDescription)")
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            onError?("无法添加视频输入")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            onError?("无法添加元数据输出")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // 震动反馈
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // 回调扫描结果
            onScanSuccess?(stringValue)
        }
    }
}
