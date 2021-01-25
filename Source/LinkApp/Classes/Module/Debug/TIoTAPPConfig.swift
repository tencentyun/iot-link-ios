//
//  TIoTDebugConfig.swift
//  LinkApp
//
//  Created by eagleychen on 2020/8/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
import KeychainAccess

@objcMembers
class TIoTAPPConfig: NSObject {

    public static var GlobalDebugUin = KCManager.getUUID() //KCManager.getUUID() //"help_center_h5_api"
    
    //app delegate
    public static var iot_appdelegate: TIoTAppDelegate {
        return UIApplication.shared.delegate as! TIoTAppDelegate
    }

    //  UIWindow
    public static var iot_window: UIWindow {
        return iot_appdelegate.window!
    }

    //  Navigation
    public static var iot_navigation: UINavigationController {
        if let navigation = iot_appdelegate.window.rootViewController as? UINavigationController {
            return navigation
        }
        return UINavigationController.init()
    }
    
    // visiable
    public static var iot_topController: UIViewController {
        if let navigation = iot_appdelegate.window.rootViewController as? UINavigationController {
            return navigation.visibleViewController ?? navigation.topViewController ?? navigation
        }
        return iot_appdelegate.window.rootViewController ?? UIViewController()
    }
    
    //isDebug
    public static var isDebug: Bool {
        return iot_appdelegate.isDebug
    }
    
    // static config list
    public static var regionlistString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/37/config1.js"
    }
    
    public static var intelligentSceneImageList: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/39/config2.js"
    }
    
    // static config
    public static var opensourceLicenseString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config5.js"
    }
    
    // static config
    public static var privacyPolicyEnglishString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config4.js"
    }
    
    // static config
    public static var serviceAgreementEnglishString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config3.js"
    }
}


class KCManager: NSObject {
    
    class func getUUID() -> String {
        
        let keychain = Keychain(service: "com.tencent.iot.explorer").accessibility(.alwaysThisDeviceOnly)
        
        let uuidkey = "com.tencent.iot.uuidkey"
        
        if let uuidres = keychain[uuidkey] {
            return uuidres
        }else{
            let uuidres = NSUUID().uuidString
            keychain["com.tencent.iot.uuidkey"] = uuidres
            return uuidres
        }
    }
}
