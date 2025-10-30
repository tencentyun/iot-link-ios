//
//  LoginView.swift
//  TEST_UI
//
//  登录/注册页面 - 严格遵循 HTML/CSS 原型图
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userManager: UserManager
    
    @State private var selectedTab = 0 // 0: 登录, 1: 注册
    
    // 登录表单
    @State private var loginUsername = ""
    @State private var loginPassword = ""
    
    // 注册表单
    @State private var registerUsername = ""
    @State private var registerPassword = ""
    @State private var registerVerificationCode = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 验证码倒计时
    @State private var verificationCodeCountdown = 0
    @State private var verificationCodeTimer: Timer?
    
    var body: some View {
        ZStack {
            // 背景色 - CSS: background-color: var(--bg-color)
            Color.bgColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Logo 和标题区域
                    VStack(spacing: 16) {
                        // Logo 图标 - CSS: .login-logo
                        Image(systemName: "video.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.primaryColor)
                            .padding(.top, 60)
                        
                        // 标题 - CSS: .login-title
                        Text("智能摄像头")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        // 副标题 - CSS: .login-subtitle
                        Text("随时随地，守护家的安全")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.bottom, 40)
                    
                    // 登录卡片 - CSS: .login-card
                    VStack(spacing: 0) {
                        // 标签切换 - CSS: .tab-buttons
                        HStack(spacing: 0) {
                            // 登录标签
                            Button(action: { selectedTab = 0 }) {
                                VStack(spacing: 8) {
                                    Text("登录")
                                        .font(.system(size: 16, weight: selectedTab == 0 ? .semibold : .regular))
                                        .foregroundColor(selectedTab == 0 ? .primaryColor : .textSecondary)
                                    
                                    // 底部指示线
                                    Rectangle()
                                        .fill(selectedTab == 0 ? Color.primaryColor : Color.clear)
                                        .frame(height: 3)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            // 注册标签
                            Button(action: { selectedTab = 1 }) {
                                VStack(spacing: 8) {
                                    Text("注册")
                                        .font(.system(size: 16, weight: selectedTab == 1 ? .semibold : .regular))
                                        .foregroundColor(selectedTab == 1 ? .primaryColor : .textSecondary)
                                    
                                    // 底部指示线
                                    Rectangle()
                                        .fill(selectedTab == 1 ? Color.primaryColor : Color.clear)
                                        .frame(height: 3)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom, 30)
                        
                        // 表单内容
                        if selectedTab == 0 {
                            loginForm
                        } else {
                            registerForm
                        }
                    }
                    .padding(24)
                    .background(Color.cardBg)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                    .padding(.horizontal, 20)
                }
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        }
        .overlay {
            if userManager.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
            }
        }
        .onDisappear {
            // 清理计时器
            verificationCodeTimer?.invalidate()
            verificationCodeTimer = nil
        }
    }
    
    // 登录表单
    var loginForm: some View {
        VStack(spacing: 16) {
            // 用户名输入框 - CSS: .input-group
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .foregroundColor(.textSecondary)
                    .frame(width: 20)
                
                TextField("请输入用户名/手机号", text: $loginUsername)
                    .font(.system(size: 15))
                    .autocapitalization(.none)
            }
            .padding(14)
            .background(Color.bgColor)
            .cornerRadius(8)
            
            // 密码输入框
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.textSecondary)
                    .frame(width: 20)
                
                SecureField("请输入密码", text: $loginPassword)
                    .font(.system(size: 15))
            }
            .padding(14)
            .background(Color.bgColor)
            .cornerRadius(8)
            
            // 登录按钮 - CSS: .login-btn
            Button(action: handleLogin) {
                Text("登录")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.primaryColor)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
            
            // 分隔线 - CSS: .divider
            HStack {
                Rectangle()
                    .fill(Color.borderColor)
                    .frame(height: 1)
                
                Text("或")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 12)
                
                Rectangle()
                    .fill(Color.borderColor)
                    .frame(height: 1)
            }
            .padding(.vertical, 8)
            
            // 微信登录按钮 - CSS: .wechat-login-btn
            Button(action: handleWechatLogin) {
                HStack(spacing: 8) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 18))
                    
                    Text("微信登录")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.wechatGreen)
                .cornerRadius(8)
            }
        }
    }
    
    // 注册表单
    var registerForm: some View {
        VStack(spacing: 16) {
            // 用户名输入框
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .foregroundColor(.textSecondary)
                    .frame(width: 20)
                
                TextField("请输入用户名/手机号", text: $registerUsername)
                    .font(.system(size: 15))
                    .autocapitalization(.none)
            }
            .padding(14)
            .background(Color.bgColor)
            .cornerRadius(8)
            
            // 密码输入框
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.textSecondary)
                    .frame(width: 20)
                
                SecureField("请输入密码", text: $registerPassword)
                    .font(.system(size: 15))
            }
            .padding(14)
            .background(Color.bgColor)
            .cornerRadius(8)
            
            // 验证码输入框和发送按钮
            HStack(spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.textSecondary)
                        .frame(width: 20)
                    
                    SecureField("请输入验证码", text: $registerVerificationCode)
                        .font(.system(size: 15))
                }
                .padding(14)
                .background(Color.bgColor)
                .cornerRadius(8)
                
                // 发送验证码按钮
                Button(action: handleSendVerificationCode) {
                    if verificationCodeCountdown > 0 {
                        Text("\(verificationCodeCountdown)s")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    } else if userManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Text("发送验证码")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 100, height: 48)
                .background(verificationCodeCountdown > 0 ? Color.gray : Color.primaryColor)
                .cornerRadius(8)
                .disabled(userManager.isLoading || verificationCodeCountdown > 0)
            }
            
            // 注册按钮
            Button(action: handleRegister) {
                Text("注册")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.primaryColor)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
    }
    
    // 处理登录
    func handleLogin() {
        userManager.login(username: loginUsername, password: loginPassword) { success, errorMessage in
            if success {
                // 登录成功，自动跳转到设备列表
            } else {
                alertMessage = errorMessage ?? "登录失败"
                showAlert = true
            }
        }
    }
    
    // 处理发送验证码
    func handleSendVerificationCode() {
        guard !registerUsername.isEmpty else {
            alertMessage = "请输入用户名/手机号"
            showAlert = true
            return
        }
        
        userManager.sendVerificationCode(username: registerUsername) { success, errorMessage in
            if success {
                // 开始倒计时
                verificationCodeCountdown = 60
                startVerificationCodeCountdown()
                alertMessage = "验证码已发送，请注意查收"
                showAlert = true
            } else {
                alertMessage = errorMessage ?? "验证码发送失败"
                showAlert = true
            }
        }
    }
    
    // 开始验证码倒计时
    func startVerificationCodeCountdown() {
        verificationCodeTimer?.invalidate()
        verificationCodeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if verificationCodeCountdown > 0 {
                verificationCodeCountdown -= 1
            } else {
                verificationCodeTimer?.invalidate()
                verificationCodeTimer = nil
            }
        }
    }
    
    // 处理注册
    func handleRegister() {
        userManager.register(
            username: registerUsername,
            password: registerPassword,
            verificationCode: registerVerificationCode
        ) { success, errorMessage in
            if success {
                // 注册成功，自动登录
            } else {
                alertMessage = errorMessage ?? "注册失败"
                showAlert = true
            }
        }
    }
    
    // 处理微信登录
    func handleWechatLogin() {
        if userManager.wechatLogin() {
            // 微信登录成功
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserManager())
}
