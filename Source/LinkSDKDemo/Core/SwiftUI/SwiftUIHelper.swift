//
//  Untitled.swift
//  LinkSDKDemo
//
//  Created by eagleychen on 2025/10/24.
//  Copyright © 2025 Tencent. All rights reserved.
//

import SwiftUI
import UIKit

// 辅助类，暴露给 Objective-C
@objc class SwiftUIHelper: NSObject {
    
    // 导航控制器回调 - 用于SwiftUI跳转到OC页面
    static var navigationController: UINavigationController?
    
    // 创建登录视图控制器
    @objc static func createLoginViewController(userManager: UserManager) -> UIViewController {
        let loginView = LoginView()
            .environmentObject(userManager)
        
        let hostingController = UIHostingController(rootView: loginView)
        // 优化导航栏显示
        hostingController.navigationItem.largeTitleDisplayMode = .never
        return hostingController
    }
    
    // 创建设备列表视图控制器
    @objc static func createDeviceListViewController(userManager: UserManager, deviceViewModel: DeviceViewModel, navigationBridge: NavigationBridge) -> UIViewController {
        let deviceListView = DeviceListView(navigationBridge: navigationBridge)
            .environmentObject(userManager)
            .environmentObject(deviceViewModel)
        
        let hostingController = UIHostingController(rootView: deviceListView)
        // 优化导航栏显示
        hostingController.navigationItem.largeTitleDisplayMode = .never
        return hostingController
    }
    
    // 创建设备详情视图控制器
    @objc static func createDeviceDetailViewController(device: Device, channelList: [Int]) -> UIViewController {
        let deviceDetailView = DeviceDetailView(device: device, channelList: channelList)
        
        let hostingController = UIHostingController(rootView: deviceDetailView)
        // 优化导航栏显示
        hostingController.navigationItem.largeTitleDisplayMode = .never
        return hostingController
    }
    
    // 创建添加设备视图控制器
    @objc static func createAddDeviceViewController(deviceViewModel: DeviceViewModel) -> UIViewController {
        let addDeviceView = AddDeviceView()
            .environmentObject(deviceViewModel)
        return UIHostingController(rootView: addDeviceView)
    }
    
    // 原有方法保留兼容性
    @objc static func createHostingController() -> UIViewController {
        let swiftUIView = AddDeviceView().environmentObject(DeviceViewModel())
        return UIHostingController(rootView: swiftUIView)
    }
    
    // 设置导航控制器
    @objc static func setNavigationController(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

// 导航桥接类 - 用于SwiftUI中触发OC页面跳转
@objc class NavigationBridge: NSObject, ObservableObject {
    @Published var shouldNavigateToDeviceDetail = false
    @Published var selectedDeviceInfo: [String: Any]?
}
