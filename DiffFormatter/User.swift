//
//  User.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct User {
    let email: String
    let quipName: String
    var formattedQuipName: String {
        return "@" + quipName
    }
}

extension User {
    static func from(line: String) -> User? {
        guard let emailNSRange = matches(pattern: "%%%(.*)%%%", body: line).first?.range(at: 1),
            let emailRange = Range(emailNSRange, in: line) else {
                return nil // Should throw here and ensure range(at: 1) will be valid
        }
        guard let quipNSRange = matches(pattern: "&&&(.*)&&&", body: line).last?.range(at: 1),
            let quipRange = Range(quipNSRange, in: line) else {
                return nil // Should throw here and ensure range(at: 1) will be valid
        }

        return User(
            email: String(line[emailRange]),
            quipName: String(line[quipRange])
        )
    }
}

extension Array where Element == User {
    static func from(data: Data) -> [User] {
        guard let string = String(data: data, encoding: .utf8) else {
            return []
        }
        return string
            .components(separatedBy: "\n")
            .compactMap(User.from)
    }
}
