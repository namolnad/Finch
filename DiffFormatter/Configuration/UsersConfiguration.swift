//
//  UsersConfiguration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct UsersConfiguration: Codable {
    let users: [User]
    let userHandlePrefix: String?
}

extension UsersConfiguration {
    static let blank: UsersConfiguration = .init(users: [], userHandlePrefix: nil)
    static let `default`: UsersConfiguration = .init(users: [], userHandlePrefix: "@")
}

extension UsersConfiguration: Blankable {
    var isBlank: Bool {
        return users.isEmpty &&
            (userHandlePrefix?.isEmpty == true)
    }
}
