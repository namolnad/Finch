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
        guard let emailMatch = matches(pattern: "%%%(.*)%%%", body: line).first, emailMatch.numberOfRanges > 1 else {
                return nil // TODO: - Throw and warn of misconfiguration
        }
        guard let quipMatch = matches(pattern: "&&&(.*)&&&", body: line).last, quipMatch.numberOfRanges > 1 else {
                return nil // TODO: - Throw and warn of misconfiguration
        }

        return User(
            email: .init(range: emailMatch.range(at: 1), in: line),
            quipName: .init(range: quipMatch.range(at: 1), in: line)
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
