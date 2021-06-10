//
//  TIoTVercheckTask.swift
//  LinkApp
//
//

import Foundation

@objcMembers
class TIoTVercheckTask: NSObject {
    static func awake() {
        TIoTVercheckTask.taskDidLoad
    }
    
    private static let taskDidLoad: Void = {
        // 启动任务管理
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TIoTAppUtilOC.checkNewVersion()
        }
    }()
}
