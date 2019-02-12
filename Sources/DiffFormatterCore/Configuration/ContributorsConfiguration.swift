//
//  ContributorsConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public struct ContributorsConfiguration: Decodable {
    public let contributors: [Contributor]
    public let contributorHandlePrefix: String?
}

extension ContributorsConfiguration {
    public static let blank: ContributorsConfiguration = .init(contributors: [], contributorHandlePrefix: nil)
    public static let `default`: ContributorsConfiguration = .init(contributors: [], contributorHandlePrefix: "")
}

extension ContributorsConfiguration {
    var isBlank: Bool {
        return contributors.isEmpty &&
            (contributorHandlePrefix?.isEmpty == true)
    }
}
