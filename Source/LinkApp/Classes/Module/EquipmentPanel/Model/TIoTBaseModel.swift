//
//  TIoTBaseModel.swift
//  LinkApp
//
//  Created by eagleychen on 2020/10/26.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
//@_exported
import YYModel

@objc class TIoTBaseModel: NSObject, NSCoding, YYModel {

    func encode(with aCoder: NSCoder) {
        self.yy_modelEncode(with: aCoder)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.yy_modelInit(with: aDecoder)
    }

    override var description: String {
        return yy_modelDescription()
    }
}
