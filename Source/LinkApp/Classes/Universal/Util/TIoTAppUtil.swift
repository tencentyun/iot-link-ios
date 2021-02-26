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
typealias TIoTWeatherHumidityType = String

class TIoTAppUtil: NSObject {
    
    //天气类型
    public static var WeatherTypeSunny = "WeatherTypeSunny" //"用枚举后，oc无法调用"
    public static var WeatherTypeCloud = "WeatherTypeCloud"
    public static var WeatherTypeRain = "WeatherTypeRain"
    public static var WeatherTypeSnow = "WeatherTypeSnow"

    //湿度类型
    public static var WeatherTypeDry = NSLocalizedString("weatherType_dry", comment: "干燥")
    public static var WeatherTypeComfort = NSLocalizedString("weatherType_comfort", comment: "舒适")
    public static var WeatherTypeWet = NSLocalizedString("weatherType_moist", comment: "潮湿")
    
    //获取实时天气
    @objc class func getWeatherType(location: String, completion: @escaping (String,TIoTWeatherType,String,String,TIoTWeatherHumidityType) -> Void) {
        
        self.getSesssionDataTask(location: location){ (temperature,textType,windDirection,weatherHumidity) in
            
            var weatherType = TIoTAppUtil.WeatherTypeSunny
            
            if textType.contains(NSLocalizedString("day_sunny", comment: "晴")) || textType.contains(NSLocalizedString("night_Clear", comment: "晴")) {
                weatherType = TIoTAppUtil.WeatherTypeSunny
            }else if textType.contains(NSLocalizedString("Overcast", comment: "阴")) || textType.contains(NSLocalizedString("Cloudy", comment: "云")) {
                weatherType = TIoTAppUtil.WeatherTypeCloud
            }else if textType.contains(NSLocalizedString("Rain", comment: "雨")) || textType.contains(NSLocalizedString("Storm", comment: "雨")) || textType.contains(NSLocalizedString("Sleet", comment: "雨夹雪")) || textType.contains(NSLocalizedString("Thundershower", comment: "雷阵雨")) {
                weatherType = TIoTAppUtil.WeatherTypeRain
            }else if textType.contains(NSLocalizedString("Snow", comment: "雪")) {
                weatherType = TIoTAppUtil.WeatherTypeSnow
            }
            
            var humidityType = TIoTAppUtil.WeatherTypeDry
            
            if let humidityValue = Float(weatherHumidity) {
                if humidityValue>0 && humidityValue<=40 {
                    humidityType = TIoTAppUtil.WeatherTypeDry
                }else if humidityValue>40 && humidityValue<=70 {
                    humidityType = TIoTAppUtil.WeatherTypeComfort
                }else {
                    humidityType = TIoTAppUtil.WeatherTypeWet
                }
            }
            
            completion(temperature,weatherType,windDirection,textType,humidityType)
        }
    }
    
    private class func getSesssionDataTask(location: String, completion: @escaping (String, String, String, String) -> Void)  {
     
        let appModel = TIoTAppConfig.loadLocalConfigList()
        var urlStr: String?
        let isEn:Bool = languageIsEn()
        if isEn {
            urlStr = "https://api.heweather.net/v7/weather/now?location=\(location)&key=\(appModel.hEweatherKey)&lang=en"
        }else {
            urlStr = "https://api.heweather.net/v7/weather/now?location=\(location)&key=\(appModel.hEweatherKey)"
        }
        
        let sess = URLSession.shared;
        let urls:NSURL=NSURL.init(string: urlStr!)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest
        let task = sess.dataTask(with: request) { (data, res, error) in
            if(error == nil){
                if let model = TIoTWeatherModel.yy_model(withJSON: data as Any) {
                    if let weatherType = model.now?.text, let temp = model.now?.temp, let windDir = model.now?.windDir, let humidity = model.now?.humidity{
                        completion(temp,weatherType,windDir,humidity)
                        return
                    }
                }
            }
            completion("","","","")
        }
        task.resume()
    }
    
    ///获取城市信息
    @objc class func getWeatherCityDataTask (location:String, completion: @escaping (String) -> Void) {
        let appModel = TIoTAppConfig.loadLocalConfigList()
        var urlStr: String?
        let isEn:Bool = languageIsEn()
        if isEn {
            urlStr = "https://geoapi.qweather.com/v2/city/lookup?location=\(location)&key=\(appModel.hEweatherKey)&lang=en"
        }else {
            urlStr = "https://geoapi.qweather.com/v2/city/lookup?location=\(location)&key=\(appModel.hEweatherKey)"
        }
        
        let session = URLSession.shared;
        let urls:NSURL=NSURL.init(string: urlStr!)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest
        let task = session.dataTask(with: request) { (data, res, error) in
            if error == nil {
                if let model = TIoTWeatherModel.yy_model(withJSON: data as Any) {
                    if let cityModel = model.location {
                        completion(cityModel[0].name)
                        return
                    }
                }
            }
            completion("")
        }
        task.resume()
    }
    
    ///获取生活指数信息
    @objc class func getWeatherDailyTask (location: String, completion: @escaping (String) -> Void) {
        let appModel = TIoTAppConfig.loadLocalConfigList()
        var urlStr: String?
        let isEn:Bool = languageIsEn()
        if isEn {
            urlStr = "https://api.qweather.com/v7/indices/1d?location=\(location)&key=\(appModel.hEweatherKey)&type=\(8)lang=en"
        }else {
            urlStr = "https://api.qweather.com/v7/indices/1d?location=\(location)&key=\(appModel.hEweatherKey)&type=\(8)"
        }
        
        let session = URLSession.shared;
        let urls:NSURL=NSURL.init(string: urlStr!)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest
        let task = session.dataTask(with: request) {(data, res, error) in
            if error == nil {
                if let model = TIoTWeatherModel.yy_model(withJSON: data as Any) {
                    if let dailyModel = model.daily {
                        completion(dailyModel[0].category)
                        return
                    }
                }
            }
            completion("")
        }
        task.resume()
    }
    
    private class func languageIsEn() -> Bool {
        
        let currLanguage = Locale.preferredLanguages[0]
        if currLanguage == "en" || currLanguage == "en-US" || currLanguage == "en-CA" || currLanguage == "en-GB" || currLanguage == "en-CN"{
            return true
        }else {
            return false
        }
        
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
class TIoTWeatherCityModel: TIoTBaseModel {
    var name: String = ""
    var id: String = ""
    var lat: String = ""
    var lon: String = ""
    var adm2: String = ""
    var adm1: String = ""
    var country: String = ""
    var tz: String = ""
    var utcOffset: String = ""
    var isDst: String = ""
    var type: String = ""
    var rank: String = ""
    var fxLink: String = ""
}

@objcMembers
class TIoTWeatherDailyModel: TIoTBaseModel {
    var date: String = ""
    var type: String = ""
    var name: String = ""
    var level: String = ""
    var category: String = ""
    var text: String = ""
}

@objcMembers
class TIoTWeatherModel: NSObject {
    var code: String = ""
    var updateTime: String = ""
    var fxLink: String = ""
    var now: TIoTWeatherNowModel?
    var location: Array<TIoTWeatherCityModel>?
    var daily: Array<TIoTWeatherDailyModel>?
    
     class func modelContainerPropertyGenericClass() -> [String: Any]? {
        return ["now": TIoTWeatherNowModel.classForCoder(),
                "location": TIoTWeatherCityModel.classForCoder(),
                "daily":TIoTWeatherDailyModel.classForCoder()]
    }
}
