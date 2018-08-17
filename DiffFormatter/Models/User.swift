//
//  User.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct User: Codable {
    let email: String
    private let userHandle: String

    var formattedUserHandle: String {
        return "@" + userHandle
    }
}
