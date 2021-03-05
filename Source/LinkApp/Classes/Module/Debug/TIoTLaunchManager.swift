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
        }
        TIoTVercheckTask.awake()
    }()
        
    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching.
        UIApplication.runOnce
        return super.next
    }
}
