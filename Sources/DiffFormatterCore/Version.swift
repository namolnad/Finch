//
//  Version.swift
//  DiffFormatter
//
//  Created by Dan Loman on 1/14/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import Foundation

public struct Version {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public init(_ versionComponents: [Int]) {
        self.init(
            major: versionComponents.first ?? 0,
            minor: versionComponents.count > 1 ? versionComponents[1] : 0,
            patch: versionComponents.count > 2 ? versionComponents[2] : 0
        )
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }
}
