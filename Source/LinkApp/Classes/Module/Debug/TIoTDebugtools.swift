//
//  QCDDebugtools.swift
//  LinkApp
//
//  Created by eagleychen on 2020/8/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit
import Foundation
import Lottie

class TIoTDebugtools: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    static let singleTon = TIoTDebugtools()
    
    @objc public static func awake() {
        TIoTDebugtools.taskDidLoad
    }
    
    deinit {
        print("debuginit---\(#column)+\(#file)+\(#function)+\(#line)")
    }
    
    private static let taskDidLoad: Void = {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
            print("debugtoolsalloc---")
            //            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let button = UIButton(type: UIButton.ButtonType.custom)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
            button.backgroundColor = UIColor.red
            button.setTitle("D", for: UIControl.State.normal)
            button.addTarget(singleTon, action: #selector(showDebugView), for: UIControl.Event.touchUpInside)
//            singleTon.debugWindow.addSubview(button)
            //LogUI
//            PTEDashboard.shared().show()
        })
    }()
    
    @objc func showDebugView() {
        
//                debugWindow.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.statusBar.rawValue+100)
        debugWindow.frame = CGRect(x: 60, y: 26, width: tableView.frame.size.width, height: tableView.frame.size.height)
        debugWindow.addSubview(tableView)
    }
    
    func hiddenDebugView() {
        
        debugWindow.frame = CGRect(x: 60, y: 26, width: 60, height: 40)
        tableView.removeFromSuperview()
    }
    
    lazy var debugWindow: UIWindow = {
        
        let debugWindow = UIWindow(frame: CGRect(x: 60, y: 26, width: 60, height: 40))
        debugWindow.windowLevel = UIWindow.Level.alert
        debugWindow.backgroundColor = UIColor.clear
        debugWindow.makeKeyAndVisible()
        return debugWindow
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 0, width: 180, height: 200)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 30
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "debugCellID")
        return tableView
    }()
    
    //配置title和执行的方法
    lazy var dataSource: Array = { () -> [Dictionary<String, String>] in
        let dataSource = [["title":"跳转H5", "SEL":"jumpControl"],
//                          ["title":"修改全局uin", "SEL":"changeGlobalUin"],
//                          ["title":"切换至测试环境", "SEL":"changeToDebug"],
//                          ["title":"切换至现网环境", "SEL":"changeToRelease"]
                          ["title":"发送数据到MyLamp", "SEL":"sendBLEData"]
        ]
        return dataSource
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "debugCellID", for: indexPath)
        
        let object: Dictionary<String, String> = dataSource[indexPath.row]
        cell.textLabel?.text = object["title"]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object: Dictionary<String, String> = dataSource[indexPath.row]
        
        
        self.perform(Selector(object["SEL"]!))
        //        self.perform(#selector(self.testCourseData))
        self.hiddenDebugView()
    }
    
    @objc func testDemo() {
        

        //调试天气数据
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
            TIoTAppUtil.getWeatherType(location: "116.41,39.92") { (weatherType) in
                print("天气预报--> \(weatherType)")
            }
        }
    }
    
    @objc func changeGlobalUin() {
        let alert = UIAlertController(title: "输入uin", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "请您输入替换全局uin"
        }
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
            if let text = alert.textFields?.first?.text, text.count > 0 {
                
                TIoTAPPConfig.GlobalDebugUin = text
                MBProgressHUD.showError("全局uin已切换至\(text)", to: TIoTAPPConfig.iot_appdelegate.window)
            }else {
                MBProgressHUD.showError("默认为help_center_h5_api", to: TIoTAPPConfig.iot_appdelegate.window)
            }
            
        }))
        TIoTAPPConfig.iot_topController.present(alert, animated: true, completion: nil)
    }
    
    @objc func changeToDebug() {
        TIoTAPPConfig.iot_appdelegate.isDebug = true
        MBProgressHUD.showError("已切换至测试环境", to: TIoTAPPConfig.iot_appdelegate.window)
        
        TIoTAppEnvironment.share().loginOut()
        let nav = TIoTNavigationController(rootViewController: TIoTVCLoginAccountVC())
        TIoTAPPConfig.iot_window.rootViewController = nav
    }
    
    @objc func changeToRelease() {
        TIoTAPPConfig.iot_appdelegate.isDebug = false
        MBProgressHUD.showError("已切换至现网环境", to: TIoTAPPConfig.iot_appdelegate.window)
        
//        DDLogInfo("测试swiftLog---\(#column)+\(#file)")
        
        TIoTAppEnvironment.share().loginOut()
        let nav = TIoTNavigationController(rootViewController: TIoTVCLoginAccountVC())
        TIoTAPPConfig.iot_window.rootViewController = nav
    }
    
    lazy var swipeAnimationView: AnimationView = {
        let appdelegate = TIoTAPPConfig.iot_appdelegate
        let view = AnimationView(name: "1834-onboarding-congrats")
        view.frame = UIScreen.main.bounds
        view.loopMode = .loop
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor.clear
        appdelegate.window!.addSubview(view)
        appdelegate.window!.backgroundColor = UIColor.red
        return view
    }()

    lazy var blue: BluetoothCentralManager = {
        
        let blue = BluetoothCentralManager.shareBluetooth()!
        blue.delegate = self
        return blue
    }()
    
//    lazy var audio: TRTCCallingAuidoViewController = {
//        let vc = TRTCCallingAuidoViewController(ocUserID: "124")
//    lazy var audio: TRTCCallingVideoViewController = {
//        let vc = TRTCCallingVideoViewController(ocUserID: nil)
//        vc.modalPresentationStyle = .fullScreen
//        return vc
//    }()
    
    @objc func jumpControl() {
//        swipeAnimationView.play()
        
/*        let wxManager = WxManager.shared()
        wxManager?.shareMiniProgramToWXSceneSession(withTitle: "titlet",
                                                    description: "desccc",
                                                    path: "",
                                                    webpageUrl: "http://www.baidu.com", // 兼容微信低版本的url
                                                    userName: "gh_2aa6447f2b7c",
                                                    thumbImage: UIImage(named: "equipmentSelectTabbar"),
                                                    thumbImageUrl: "",
                                                    complete: nil)
*/
        
        
//        blue.scanNearPerpherals()
        
//        audio.resetWithUserList(users: invitedList, isInit: true)
//        audio.OCEnterUser(userID: "123")
        
        
//        let vc = TRTCCallingVideoViewController(ocUserID: nil)
        let vc = TRTCCallingAuidoViewController(ocUserID: "me")
        vc.modalPresentationStyle = .fullScreen
        
        TIoTAPPConfig.iot_topController.present(vc, animated: false, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: {
            vc.OCEnterUser(userID: "friend")
        })
/*
        let alert = UIAlertController(title: "输入URL", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "请输入您的调试URL(http://www.baidu.com)"
        }
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
            
            let vc = TIoTWebVC()
            vc.title = "用户协议";
            if let text = alert.textFields?.first?.text, text.count > 0 {
                vc.urlPath = text
            }else {
                vc.urlPath = "http://www.baidu.com";
            }
            TIoTAPPConfig.iot_navigation.pushViewController(vc, animated: true)
            
        }))
        TIoTAPPConfig.iot_topController.present(alert, animated: true, completion: nil)
 */
    }
    
    @objc func sendBLEData() {
        blue.writeData(toBLE: "color")
    }
}


extension TIoTDebugtools: BluetoothCentralManagerDelegate {
    func scanPerpheralsUpdatePerpherals(_ perphersArr: [CBPeripheral]!) {
        
        for onePerpher in perphersArr {
            
            if onePerpher.name == "MyLamp" {
                blue.connect(onePerpher)
            }
        }    
    }
    
    func connectPerpheralSucess() {
        print("sussss")
    }
}
