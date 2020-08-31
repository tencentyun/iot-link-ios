//  Created by chenying

@objcMembers
class TIoTLogTask: NSObject {
    static func awake() {
        TIoTLogTask.taskDidLoad
    }
    
    deinit {
        print("ThirdAccount---\(#column)+\(#file)+\(#function)+\(#line)")
    }
    
    private static let taskDidLoad: Void = {
        // 启动任务管理
    }()
}
