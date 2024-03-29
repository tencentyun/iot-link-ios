//
//  TIoTDebugConfig.swift
//  LinkApp
//
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
    
    // static config 美国地区英文-开源软件信息 （开源软件信息只有美国区有）
    public static var opensourceLicenseString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config5.js"
    }
    
    // static config 美国地区中文-开源软件信息 （开源软件信息只有美国区有）
    public static var opensourceLicenseChineseString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config11.js"
    }
    
    // static config 美国地区-隐私政策英文
    public static var privacyPolicyEnglishString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config4.js"
    }
    
    // static config 美国地区-用户协议英文
    public static var serviceAgreementEnglishString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config3.js"
    }
    
    // static config 英文-注销协议 （注销协议不分地区，根据系统语言切换中英文）
    public static var logoffAccountEnglisthString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config6.js"
    }
    
    // static config 美国地区-用户协议中文
    public static var userProtocolUSChineseString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config7.js"
    }
    
    // static config 美国地区-隐私政策中文
    public static var userPrivacyPolicyUSChineseString: NSString {
//        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config8.js"
        return "https://privacy.qq.com/document/preview/0da010f1b4944e88bf78520d88642513"
    }
    
    // static config 中国区-隐私政策英文
    public static var userPrivacyPolicyChEnglishString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config10.js"
    }
    
    // static config 中国区-用户协议英文
    public static var userProtocolChEnglishString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config9.js"
    }
    
    // static config 中国区-第三方sdk目录
    public static var userThridSDKChChineseString: NSString {
//        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config12.js"
        return "https://privacy.qq.com/document/preview/bd3470c6063f4ac6831900edcb60c9bd"
    }
    
    // static config 中国区-第三方sdk目录英文
    public static var userThridSDKChEnglishString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config13.js"
    }
    
    // static config 中国区-个人信息目录英文
    public static var userPersonInfoUSZHString: NSString {
//        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config14.js"
        return "https://privacy.qq.com/document/preview/278bbbbbdd5748999fce491cfa6dd424"
    }
    
    // static config 中国区-个人信息目录英文
    public static var userPersonInfoUSENString: NSString {
        return "https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/42/config15.js"
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
