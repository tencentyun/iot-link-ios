//  Created by chenying

@_exported import CocoaLumberjack

@objcMembers
class TIoTLogTask: NSObject {
    static func awake() {
        TIoTLogTask.taskDidLoad
    }
    
    deinit {
        print("ThirdAccount---\(#column)+\(#file)+\(#function)+\(#line)")
    }
    
    private static let taskDidLoad: Void = {
        
        DDLog.add(DDOSLogger.sharedInstance) // TTY = Xcode console
        DDLog.add(DDOSLogger.sharedInstance) // ASL = Apple System Logs

        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
#if DEBUG
        DDLog.add(fileLogger, with: DDLogLevel.debug)
#else
        DDLog.add(fileLogger, with: DDLogLevel.info)
#endif
        print("logpath---\(String(describing: fileLogger.currentLogFileInfo?.filePath))")
    }()
}
