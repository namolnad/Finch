//
//  GitConfiguration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct GitConfiguration: Codable {
    let branchPrefix: String?
    let executablePath: String?
}

extension GitConfiguration {
    static let blank: GitConfiguration = .init(branchPrefix: nil, executablePath: nil)
    static let `default`: GitConfiguration = .init(branchPrefix: "", executablePath: nil)
}

extension GitConfiguration: Blankable {
    var isBlank: Bool {
        return (branchPrefix?.isEmpty == true) &&
            (executablePath?.isEmpty == true)
    }
}
