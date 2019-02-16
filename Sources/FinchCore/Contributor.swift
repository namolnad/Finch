//
//  Contributor.swift
//  Finch
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public struct Contributor: Codable {
    public let emails: [String]
    public let handle: String
}

extension Contributor {
    static let example: Contributor = .init(
        emails: [
            "esme.squalor@example.com",
            "esmeDevAccount@github.com",
        ],
        handle: "GigiGeniveve"
    )
}
