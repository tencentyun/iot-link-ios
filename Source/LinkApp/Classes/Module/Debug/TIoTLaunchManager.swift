//
//  File.swift
//
//  Created by chenying
//

import UIKit

extension UIApplication {
    public static let runOnce: Void = {
        let appdelegate = UIApplication.shared.delegate as! TIoTAppDelegate
        if appdelegate.isDebug {
            TIoTDebugtools.awake()
            TIoTLogTask.awake()
            
            //调试天气数据
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
                TIoTAppUtil.getSesssionDataTask()
            }
        }
    }()
        
    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching.
        UIApplication.runOnce
        return super.next
    }
}
