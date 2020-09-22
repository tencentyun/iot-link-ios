//
//  TIoTAppUtil.swift
//  LinkApp
//
//  Created by eagleychen on 2020/9/22.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
import YYModel

typealias TIoTWeatherType = String

class TIoTAppUtil: NSObject {
    
    //天气类型
    public static var WeatherTypeSunny = "WeatherTypeSunny" //"用枚举后，oc无法调用"
    public static var WeatherTypeCloud = "WeatherTypeCloud"
    public static var WeatherTypeRain = "WeatherTypeRain"
    public static var WeatherTypeSnow = "WeatherTypeSnow"
    
    //获取实时天气
    class func getWeatherType(location: String, completion: @escaping (TIoTWeatherType) -> Void) {
        
        
        self.getSesssionDataTask(location: location){ (textType) in
            
            var weatherType = TIoTAppUtil.WeatherTypeSunny
            
            if textType.contains("晴") {
                weatherType = TIoTAppUtil.WeatherTypeSunny
            }else if textType.contains("阴") || textType.contains("云") {
                weatherType = TIoTAppUtil.WeatherTypeCloud
            }else if textType.contains("雨") {
                weatherType = TIoTAppUtil.WeatherTypeRain
            }else if textType.contains("雪") {
                weatherType = TIoTAppUtil.WeatherTypeSnow
            }
            
            completion(weatherType)
        }
    }
    
    private class func getSesssionDataTask(location: String, completion: @escaping (String) -> Void)  {
     
        let appModel = TIoTAppConfig.loadLocalConfigList()
        let urlStr = "https://api.heweather.net/v7/weather/now?location=\(location)&key=\(appModel.hEweatherKey)"
        let sess = URLSession.shared;
        let urls:NSURL=NSURL.init(string: urlStr)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest
        let task = sess.dataTask(with: request) { (data, res, error) in
            if(error == nil){
                if let model = TIoTWeatherModel.yy_model(withJSON: data as Any) {
                    print("resut--> \(String(describing: model.now?.text))")
                    if let weatherType = model.now?.text {
                        completion(weatherType)
                        return
                    }
                }
            }
            completion("")
        }
        task.resume()
    }
}


@objcMembers
class TIoTWeatherNowModel: NSObject {
    var obsTime: String = ""
    var temp: String = ""
    var feelsLike:String = ""
    var icon: String = ""
    var text: String = ""
    var wind360:String = ""
    var windDir: String = ""
    var windScale: String = ""
    var windSpeed:String = ""
    var humidity: String = ""
    var precip: String = ""
    var pressure:String = ""
    var vis: String = ""
    var cloud: String = ""
    var dew:String = ""
}

    
@objcMembers
class TIoTWeatherModel: NSObject {
    var code: String = ""
    var updateTime: String = ""
    var fxLink: String = ""
    var now: TIoTWeatherNowModel?
    
    class func modelContainerPropertyGenericClass() -> [String: Any]? {
        return ["now": [TIoTWeatherNowModel.classForCoder()]]
    }
}
