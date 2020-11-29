//
//  TIoTDeviceModel.swift
//  LinkApp
//
//  Created by eagleychen on 2020/10/22.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation

@objcMembers
class TIoTProductsConfigModel: TIoTBaseModel {
    let _action = "AppGetProductsConfig"
    
    var ProductId: String?
    var Config: TIoTProductConfigModel?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["Config": TIoTProductConfigModel.classForCoder()]
    }
}

@objcMembers class TIoTProductConfigModel: TIoTBaseModel {
    var profile: TIoTProfileModel?
    var Global: TIoTGlobalModel?
    var DeviceInfo: TIoTDeviceInfoModel?
    var Panel: TIoTPanelModel?
    var ShortCut: TIoTShortCutModel?
    var WifiSoftAP: TIoTWifiSoftAPModel?
    var WifiSmartConfig: TIoTWifiSmartConfigModel?

    var WifiConfTypeList: Dictionary<String, Any>?
    var WifiSimpleConfig: Dictionary<String, Any>?
    var WifiAirkiss: Dictionary<String, Any>?
    var WifiBle: Dictionary<String, Any>?
    var AppAutomation: Dictionary<String, Any>?
    var SubDeviceBinding: Dictionary<String, Any>?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["profile": TIoTProfileModel.classForCoder(),
                "Global": TIoTGlobalModel.classForCoder(),
                "DeviceInfo": TIoTDeviceInfoModel.classForCoder(),
                "Panel": TIoTPanelModel.classForCoder(),
                "ShortCut": TIoTShortCutModel.classForCoder(),
                "WifiSoftAP": TIoTWifiSoftAPModel.classForCoder(),
                "WifiSmartConfig": TIoTWifiSmartConfigModel.classForCoder()]
    }
}

@objcMembers class TIoTProfileModel: TIoTBaseModel {
    var ProductId: String?
    var CategoryId: String?
}

@objcMembers class TIoTGlobalModel: TIoTBaseModel {
    var IconUrl: String?
    var IconUrlGrid: String?
    var ChipPackage: String?
    
    var customizeControl: String?
    var trtc: String?
}

@objcMembers class TIoTDeviceInfoModel: TIoTBaseModel {
    var ManufacturerName: String?
    var ProductModel: String?
    var ProductPicture: String?
    var TestUrl: String?
}

@objcMembers class TIoTPanelModel: TIoTBaseModel {
    var enableForAllSubProducts: String?
    var type: String?
    var standard:TIoTStandardModel?
    var h5:TIoTH5Model?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["standard": TIoTStandardModel.classForCoder(),
                "h5": TIoTH5Model.classForCoder()]
    }
}

@objcMembers class TIoTStandardModel: TIoTBaseModel {
    var theme: String?
    var bgImgId: String?
    var navBar: TIoTNavBarModel?
    var properties: TIoTPropertiesModel?
    var timingProject: String?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["properties": TIoTPropertiesModel.classForCoder(),
                "navBar": TIoTNavBarModel.classForCoder()]
    }
}

@objcMembers class TIoTNavBarModel: TIoTBaseModel {
    var visible: String?
}

@objcMembers class TIoTH5Model: TIoTBaseModel {
    var releaseModel: TIoTreleaseModel?
    var url: String?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["release": TIoTreleaseModel.classForCoder()]
    }
    
    class func modelCustomPropertyMapper() -> [String : Any]? {
        return ["releaseModel" :"release"]
    }
}

@objcMembers class TIoTreleaseModel: TIoTBaseModel {
    var bgColor: String?
    var frontColor: String?
    var navBarBgColor: String?
    var scripts: Array<String>?
    var styles: Array<String>?
    var textStyle: String?
}

@objcMembers class TIoTShortCutModel: TIoTBaseModel {
    var powerSwitch: String?
}

@objcMembers class TIoTWifiSoftAPModel: TIoTBaseModel {
    var connectApGuide: TIoTconnectApGuideModel?
    var hardwareGuide: TIoThardwareGuideModel?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["connectApGuide": TIoTconnectApGuideModel.classForCoder(),
                "hardwareGuide": TIoThardwareGuideModel.classForCoder()]
    }
}

@objcMembers class TIoTWifiSmartConfigModel: TIoTBaseModel {
    var hardwareGuide: TIoThardwareGuideModel?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["hardwareGuide": TIoThardwareGuideModel.classForCoder()]
    }
}

@objcMembers class TIoTconnectApGuideModel: TIoTBaseModel {
    var message: String?
    var apName: String?
}

@objcMembers class TIoThardwareGuideModel: TIoTBaseModel {
    var bgImg: String?
    var message: String?
    var btnText: String?
}





@objcMembers class TIoTDevicedListDataModel: TIoTBaseModel {
    var AliasName: String?
    var CreateTime: String?
    var DeviceId: String?
    var DeviceName: String?
    var DeviceType: String?
    var FamilyId: String?
    var IconUrl: String?
    var IconUrlGrid: String?
    var ProductId: String?
    var RoomId: String?
    var UpdateTime: String?
    var UserID: String?
    var Online: String?
    
}
