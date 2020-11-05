//
//  TIoTVercheckTask.swift
//  LinkApp
//
//  Created by eagleychen on 2020/11/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation

@objcMembers
class TIoTVercheckTask: NSObject {
    static func awake() {
        TIoTVercheckTask.taskDidLoad
    }
    
    deinit {
        print("ThirdAccount---\(#column)+\(#file)+\(#function)+\(#line)")
    }
    
    private static let taskDidLoad: Void = {
        // 启动任务管理
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TIoTHomeViewController.checkNewVersion()
        }
    }()
}
