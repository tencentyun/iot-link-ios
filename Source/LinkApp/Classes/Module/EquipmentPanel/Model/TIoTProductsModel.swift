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
        let model = TIoTDataTemplateModel.yy_model(withJSON: self.DataTemplate)
        return model
    }
}

@objcMembers class TIoTDataTemplateModel: TIoTBaseModel {
    var version: String?
    var profile: String?
    var properties: TIoTPropertiesModel?
    var events: Array<Any>?
    var actions: Array<Any>?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["properties": TIoTPropertiesModel.classForCoder()]
    }
}

@objcMembers class TIoTPropertiesModel: TIoTBaseModel {
    var id: String?
    var name: String?
    var desc: String?
    var required: Bool?
    var mode: String?
    var define: TIoTDefineModel?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["define": TIoTDefineModel.classForCoder()]
    }
}

@objcMembers class TIoTDefineModel: TIoTBaseModel {
    var type: String?
    var mapping: TIoTMappingModel?
    
    class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
        return ["mapping": TIoTMappingModel.classForCoder()]
    }
}

@objcMembers class TIoTMappingModel: TIoTBaseModel {
    var off: String?
    var on: String?
    
    class func modelCustomPropertyMapper() -> [String : Any]? {
        return ["off" :"0", "on": "1"]
    }
}
