//
//  ContributorsConfiguration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct ContributorsConfiguration: Decodable {
    let contributors: [Contributor]
    let contributorHandlePrefix: String?
}

extension ContributorsConfiguration {
    static let blank: ContributorsConfiguration = .init(contributors: [], contributorHandlePrefix: nil)
    static let `default`: ContributorsConfiguration = .init(contributors: [], contributorHandlePrefix: "@")
}

extension ContributorsConfiguration {
    var isBlank: Bool {
        return contributors.isEmpty &&
            (contributorHandlePrefix?.isEmpty == true)
    }
}
