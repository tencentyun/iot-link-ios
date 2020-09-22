//
//  TIoTAppUtil.swift
//  LinkApp
//
//  Created by eagleychen on 2020/9/22.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation

typealias TIoTWeatherType = String

class TIoTAppUtil: NSObject {
    
    //天气类型
    public static var WeatherTypeSunny = "WeatherTypeSunny" //"用枚举后，oc无法调用"
    public static var WeatherTypeCloud = "WeatherTypeCloud"
    public static var WeatherTypeRain = "WeatherTypeRain"
    public static var WeatherTypeSnow = "WeatherTypeSnow"
    
    //获取实时天气
    class func getWeatherType(location: String) -> TIoTWeatherType {
        
        var weatherType = TIoTAppUtil.WeatherTypeSunny
        
        self.getSesssionDataTask()
        
        return weatherType
    }
    
    class func getSesssionDataTask()  {
     
        let urlStr = "https://api.heweather.net/v7/weather/now?location=116.41,39.92&key=XXX"
        let sess = URLSession.shared;
        let urls:NSURL=NSURL.init(string: urlStr)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest
        let task = sess.dataTask(with: request) { (data, res, error) in
            if(error == nil){

                do {
                    let dict  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    print(dict)
                } catch {
                    
                }
                
            }
        }
        task.resume()
    }
}
