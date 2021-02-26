//
//  TIoTWeatherVC.swift
//  LinkApp
//
//  Created by ccharlesren on 2021/2/23.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import Lottie

class TIoTWeatherVC: NSObject {
    var view = AnimationView()
    
    @objc func weatherAnimation(jsName: String, animationFrame frame:CGRect) -> AnimationView {
        view.frame = frame
        view.loopMode = .loop
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor.clear
        view.animation = Animation.named(jsName)
        view.play()
        return view
    }
    
    @objc func switchWeatherAnimation(jsName: String) {
        view.animation = Animation.named(jsName)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
