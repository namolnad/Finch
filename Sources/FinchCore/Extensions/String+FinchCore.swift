//
//  String+FinchCore.swift
//  FinchCore
//
//  Created by Dan Loman on 1/7/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import Foundation

/// :nodoc:
extension String {
    init(range: NSRange, in body: String) {
        guard let range = Range(range, in: body) else {
            self = body
            return
        }

        self.init(body[range])
    }
}

/// :nodoc:
extension String: LineOutputtable {
    func output(components: LineComponents, context: LineContext) -> String {
        return self
    }
}

/// :nodoc:
extension Array where Element == String {
    public func sorted(by pattern: Regex.Pattern) -> [String] {
        return sorted {
            guard let match1 = pattern.matches(in: $0).first else {
                return false
            }
            guard let match2 = pattern.matches(in: $1).first else {
                return false
            }

            return String(range: match1.range, in: $0) > String(range: match2.range, in: $1)
        }
    }
}
