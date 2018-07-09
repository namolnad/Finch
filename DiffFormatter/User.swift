//
//  User.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

enum User: String {
    case bonnieHoang = "bonnie.hoang@gmail.com"
    case danLoman = "daniel.h.loman@gmail.com"
    case joshSchroeder = "johosher@gmail.com"
    case mikeJablonski = "mike.jablonski.online@gmail.com"
    case minKim = "minho.kim@gmail.com"

    private var _quipName: String {
        switch self {
        case .bonnieHoang:
            return "Bonnie Hoang"
        case .danLoman:
            return "Dan Loman"
        case .joshSchroeder:
            return "Josh Schroeder"
        case .mikeJablonski:
            return "Mike Jablonski"
        case .minKim:
            return "Min Kim"
        }
    }

    var quipName: String {
        return "@" + _quipName
    }

    var email: String {
        return rawValue
    }
}
