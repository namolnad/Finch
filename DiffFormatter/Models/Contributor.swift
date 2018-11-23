//
//  Contributor.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Contributor: Codable {
    let email: String
    let handle: String
}

extension Contributor {
    static let unknown: Contributor = .init(email: "_unknown", handle: "_unknown")
}
