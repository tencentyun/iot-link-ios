//
//  QCDDebugtools.swift
//  LinkApp
//
//  Created by eagleychen on 2020/8/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit
import Foundation

class QCDebugtools: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    static let singleTon = QCDebugtools()
    
    @objc public static func awake() {
        QCDebugtools.taskDidLoad
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
            //            appdelegate.window?.addSubview(button)
            singleTon.debugWindow.addSubview(button)
            
            //LogUI
            //                PTEDashboard.shared().show()
        })
    }()
    
    @objc func showDebugView() {
        
        //        debugWindow.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.statusBar.rawValue+100)
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
        let dataSource = [["title":"我要成为VIP", "SEL":"setCurrentToVIP"],
                          ["title":"清除模版并重启", "SEL":"jumpCuxiao"],
                          ["title":"调试课程1", "SEL":"testDemo"],
                          ["title":"跳转Contol", "SEL":"jumpControl"],
                          ["title":"compressImageTo500", "SEL":"compressImageTo500"],
                          ["title":"testLoadImage", "SEL":"testLoadImage"],
                          ["title":"GIF合成到视频里面", "SEL":"gifToVideo"],
                          ["title":"toast自定义", "SEL":"customToast"]
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object: Dictionary<String, String> = dataSource[indexPath.row]
        
        
        self.perform(Selector(object["SEL"]!))
        //        self.perform(#selector(self.testCourseData))
        self.hiddenDebugView()
    }
    
    
    //#mark ---test func-------------------------------
    //    lazy var swipeAnimationView: AnimationView = {
    //        let appdelegate = UIApplication.shared.delegate as! AppDelegate
    ////        blur_guider_data
    //        let view = AnimationView(name: "1834-onboarding-congrats")
    //        view.frame = UIScreen.main.bounds
    //        view.loopMode = .loop
    //        view.isUserInteractionEnabled = false
    //        view.contentMode = .scaleAspectFit
    //        view.backgroundColor = UIColor.clear
    //        appdelegate.window!.addSubview(view)
    //        appdelegate.window!.backgroundColor = UIColor.red
    //        return view
    //    }()
    
    @objc func testDemo() {
        
        var prorororo = 0.1
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            
            prorororo = prorororo + 0.1
        }
        
        
    }
    
    @objc func jumpControl() {
//        uf_navigation.pushViewController(UFPhotoEditViewController(), animated: true)
    }
    
    @objc func testLoadImage() {
        let targetUrl = "https://static01.versa-ai.com/images/detect/2019/11/07/c3ad3072-0140-11ea-988d-0a58ac1a3a48.png"
        let imageUrl = URL(string: targetUrl)
        let imageData = try? Data(contentsOf: imageUrl!)
        let resultImage = UIImage(data: imageData!)
        
        
        let appdelegate = UIApplication.shared.delegate as! TIoTAppDelegate
        
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.image = resultImage
        //        view.frame = UIScreen.main.bounds
        
        //        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor.clear
        
        appdelegate.window!.addSubview(view)
    }
    
    @objc func gifToVideo() {
        
    }
    
    @objc func customToast()  {
    }
    
    @objc func setCurrentToVIP()  {
    }
}
