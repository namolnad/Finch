//
//  Contributor.swift
//  Finch
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public struct Contributor: Codable {
    public let email: String
    public let handle: String
}

extension Contributor {
    static let example: Contributor = .init(
        email: "esme.squalor@example.com",
        handle: "GigiGeniveve"
    )
}
