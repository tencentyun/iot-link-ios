//
//  TIoTProductModel.swift
//  LinkApp
//
//  Created by eagleychen on 2020/10/26.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation

@objcMembers
class TIoTProductsModel: TIoTBaseModel {
    let _action = "AppGetProducts"
    
    var ProductId: String?
    var Name: String?
    var Description: String?
    var state: String?
    var DataTemplate: String?
    var AppTemplate: String?
    var NetType: String?
    var CategoryId: Int = 1
    var ProductType: Int = 0
    var UpdateTime: Int = 0
    
    func getDataTemplateModel() -> TIoTDataTemplateModel? {
        if let data = self.DataTemplate {
            
            let model = TIoTDataTemplateModel.yy_model(withJSON: data)
            return model
        }
        return nil
    }
}

@objcMembers class TIoTDataTemplateModel: TIoTBaseModel {
    var version: String?
    var profile: TIoTProfileModel?
    var properties: [TIoTPropertiesModel]?
    var events: Array<Any>?
    var actions: Array<Any>?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["profile": TIoTProfileModel.classForCoder(),
                "properties": TIoTPropertiesModel.classForCoder()]
    }
}

@objcMembers class TIoTPropertiesModel: TIoTBaseModel {
    var id: String?
    var ui: TIoTUIModel?
    var name: String?
    var desc: String?
    var required: String?
    var mode: String?
    var define: TIoTDefineModel?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["ui": TIoTUIModel.classForCoder(),
                "define": TIoTDefineModel.classForCoder()]
    }
}

@objcMembers class TIoTUIModel: TIoTBaseModel {
    var type: String?
    var icon: String?
}

@objcMembers class TIoTDefineModel: TIoTBaseModel {
    var type: String?
    var mapping: Dictionary<String, String>?
    var min : String?
    var max : String?
    var start : String?
    var step : String?
    var unit : String?
}
