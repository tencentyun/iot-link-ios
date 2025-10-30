//
//  UserManager.swift
//  TEST_UI
//
//  用户登录状态管理
//

import Foundation
import SwiftUI
import Combine
import IoTVideoCloud

@objc class UserManager: NSObject, ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUsername: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // 登录成功回调 - 供OC调用
    @objc var loginSuccessCallback: (() -> Void)?
    // 注册成功回调 - 供OC调用
    @objc var registerSuccessCallback: (() -> Void)?
    // 微信登录回调 - 供OC调用
    @objc var wechatLoginCallback: (() -> Void)?
    // 退出登录回调 - 供OC调用
    @objc var logoutCallback: (() -> Void)?
    
    private let userDefaultsKey = "currentUser"
    
    override init() {
        super.init()
        // 从 UserDefaults 加载登录状态
        if let username = UserDefaults.standard.string(forKey: userDefaultsKey) {
            self.currentUsername = username
            self.isLoggedIn = true
        }
    }
    
    // 登录 - 真正调用API
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard !username.isEmpty && !password.isEmpty else {
            completion(false, "用户名和密码不能为空")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 判断是手机号还是邮箱登录
        if username.contains("@") {
            // 邮箱登录
            TIoTCoreAccountSet.shared().signIn(withEmail: username, password: password, success: { [weak self] responseObject in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.handleLoginSuccess(username: username)
                    completion(true, nil)
                }
            }, failure: { [weak self] reason, error, dic in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = reason ?? error?.localizedDescription ?? "登录失败"
                    completion(false, self?.errorMessage)
                }
            })
        } else {
            // 手机号登录（默认国家码86）
            TIoTCoreAccountSet.shared().signIn(withCountryCode: "86", phoneNumber: username, password: password, success: { [weak self] responseObject in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.handleLoginSuccess(username: username)
                    completion(true, nil)
                }
            }, failure: { [weak self] reason, error, dic in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = reason ?? error?.localizedDescription ?? "登录失败"
                    completion(false, self?.errorMessage)
                }
            })
        }
    }
    
    // MARK: - 发送验证码
    func sendVerificationCode(username: String, completion: @escaping (Bool, String?) -> Void) {
        guard !username.isEmpty else {
            completion(false, "请输入用户名/手机号")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        if username.contains("@") {
            // 邮箱验证码
            TIoTCoreAccountSet.shared().sendVerificationCode(withEmail: username, success: { [weak self] response in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    completion(true, nil)
                }
            }, failure: { [weak self] reason, error, dic in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    completion(false, reason ?? "验证码发送失败")
                }
            })
        } else {
            // 手机号验证码，默认使用中国区号86
            TIoTCoreAccountSet.shared().sendVerificationCode(withCountryCode: "86", phoneNumber: username, success: { [weak self] response in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    completion(true, nil)
                }
            }, failure: { [weak self] reason, error, dic in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    completion(false, reason ?? "验证码发送失败")
                }
            })
        }
    }
    
    // 注册 - 真正调用API（需要验证码，这里先提供基础框架）
    func register(username: String, password: String, verificationCode: String? = nil, completion: @escaping (Bool, String?) -> Void) {
        // 验证输入
        if username.isEmpty {
            completion(false, "请输入用户名")
            return
        }
        if password.isEmpty {
            completion(false, "请输入密码")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 判断是手机号注册还是邮箱注册
        if username.contains("@") {
            // 邮箱注册（需要验证码）
            if let code = verificationCode, !code.isEmpty {
                TIoTCoreAccountSet.shared().createEmailUser(withEmail: username, verificationCode: code, password: password, success: { [weak self] responseObject in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        self?.handleRegisterSuccess(username: username)
                        completion(true, nil)
                    }
                }, failure: { [weak self] reason, error, dic in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        self?.errorMessage = reason ?? error?.localizedDescription ?? "注册失败"
                        completion(false, self?.errorMessage)
                    }
                })
            } else {
                completion(false, "请输入验证码")
                isLoading = false
            }
        } else {
            // 手机号注册（需要验证码）
            if let code = verificationCode, !code.isEmpty {
                TIoTCoreAccountSet.shared().createPhoneUser(withCountryCode: "86", phoneNumber: username, verificationCode: code, password: password, success: { [weak self] responseObject in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        self?.handleRegisterSuccess(username: username)
                        completion(true, nil)
                    }
                }, failure: { [weak self] reason, error, dic in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        self?.errorMessage = reason ?? error?.localizedDescription ?? "注册失败"
                        completion(false, self?.errorMessage)
                    }
                })
            } else {
                completion(false, "请输入验证码")
                isLoading = false
            }
        }
    }
    
    // 处理登录成功
    private func handleLoginSuccess(username: String) {
        self.currentUsername = username
        self.isLoggedIn = true
        UserDefaults.standard.set(username, forKey: userDefaultsKey)
        
        // 触发回调
        DispatchQueue.main.async {
            self.loginSuccessCallback?()
        }
    }
    
    // 处理注册成功
    private func handleRegisterSuccess(username: String) {
        self.currentUsername = username
        self.isLoggedIn = true
        UserDefaults.standard.set(username, forKey: userDefaultsKey)
        
        // 触发回调
        DispatchQueue.main.async {
            self.registerSuccessCallback?()
        }
    }
    
    // 微信登录
    func wechatLogin() -> Bool {
        // 触发回调，让OC处理微信登录
        DispatchQueue.main.async {
            self.wechatLoginCallback?()
        }
        return true
    }
    
    // OC调用此方法设置登录成功
    @objc func setLoginSuccess(username: String) {
        self.currentUsername = username
        self.isLoggedIn = true
        UserDefaults.standard.set(username, forKey: userDefaultsKey)
    }
    
    // 登出
    func logout() {
        self.isLoggedIn = false
        self.currentUsername = ""
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        
        // 调用OC的清除登录信息方法
        TIoTCoreUserManage.shared().clear()
        
        // 触发回调，跳转到LoginView
        DispatchQueue.main.async {
            self.logoutCallback?()
        }
    }
}
