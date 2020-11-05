//  Created by chenying

@objcMembers
class TIoTLogTask: NSObject {
    static func awake() {
        TIoTLogTask.taskDidLoad
    }
        
    private static let taskDidLoad: Void = {
        // 启动任务管理
    }()
}
