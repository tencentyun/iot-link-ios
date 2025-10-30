//
//  ColorExtension.swift
//  TEST_UI
//
//  严格遵循 CSS 变量定义的颜色
//

import SwiftUI

extension Color {
    // CSS: --primary-color: #1890ff
    static let primaryColor = Color(red: 0.098, green: 0.565, blue: 1.0)
    
    // CSS: --success-color: #52c41a
    static let successColor = Color(red: 0.322, green: 0.769, blue: 0.102)
    
    // CSS: --warning-color: #faad14
    static let warningColor = Color(red: 0.980, green: 0.678, blue: 0.078)
    
    // CSS: --danger-color: #ff4d4f
    static let dangerColor = Color(red: 1.0, green: 0.302, blue: 0.310)
    
    // CSS: --bg-color: #f5f5f5
    static let bgColor = Color(red: 0.96, green: 0.96, blue: 0.96)
    
    // CSS: --card-bg: #ffffff
    static let cardBg = Color.white
    
    // CSS: --text-primary: #333333
    static let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    // CSS: --text-secondary: #666666
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)
    
    // CSS: --text-disabled: #999999
    static let textDisabled = Color(red: 0.6, green: 0.6, blue: 0.6)
    
    // CSS: --border-color: #d9d9d9
    static let borderColor = Color(red: 0.85, green: 0.85, blue: 0.85)
    
    // CSS: --wechat-green: #07c160
    static let wechatGreen = Color(red: 0.027, green: 0.757, blue: 0.376)
    
    // 渐变色 - 用于设备卡片图标
    static let deviceGradient = LinearGradient(
        colors: [Color.primaryColor, Color.primaryColor.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
