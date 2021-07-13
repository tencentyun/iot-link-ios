//
//  CallUserModel.swift
//  TXLiteAVDemo
//
//

import Foundation

struct CallingUserModel: Equatable {
    var avatarUrl: String = ""
    var name: String = ""
    var userId: String = ""
    var isEnter: Bool = false
    var isVideoAvaliable: Bool = false
    var volume: Float = 0
    
    static func == (lhs: CallingUserModel, rhs: CallingUserModel) -> Bool {
        if lhs.userId == rhs.userId {
            return true
        }
        return false
    }
}
