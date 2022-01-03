//
//  TIoTDeviceDataModel.swift
//  LinkApp
//
//

import Foundation

@objcMembers
class TIoTDeviceDataModel: TIoTBaseModel {
    let _action = "AppGetDeviceData"
    
    var brightness: TIoTDeviceValueModel?
    var color: TIoTDeviceValueModel?
    var switch_on: TIoTDeviceValueModel?
    var light_switch: TIoTDeviceValueModel?
    var name: TIoTDeviceValueModel?
    
    //TRTC设备的属性
    var _sys_audio_call_status: TIoTDeviceValueModel?
    var _sys_video_call_status: TIoTDeviceValueModel?
    var _sys_userid: TIoTDeviceValueModel?
    var _sys_caller_id: TIoTDeviceValueModel?
    var _sys_called_id: TIoTDeviceValueModel?
    
    
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["brightness": TIoTDeviceValueModel.classForCoder(),
                "color": TIoTDeviceValueModel.classForCoder(),
                "switch_on": TIoTDeviceValueModel.classForCoder(),
                "light_switch": TIoTDeviceValueModel.classForCoder(),
                "name": TIoTDeviceValueModel.classForCoder(),
                
                "_sys_audio_call_status": TIoTDeviceValueModel.classForCoder(),
                "_sys_video_call_status": TIoTDeviceValueModel.classForCoder(),
                "_sys_userid": TIoTDeviceValueModel.classForCoder()]
    }
    
    class func modelCustomPropertyMapper() -> [String : Any]? {
        return ["switch_on" :"switch"]
    }
}

@objcMembers class TIoTDeviceValueModel: TIoTBaseModel {
    var Value: String?
    var LastUpdate: String?
}
