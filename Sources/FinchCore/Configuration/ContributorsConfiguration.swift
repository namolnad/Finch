//
//  ContributorsConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

public struct ContributorsConfiguration: Decodable {
    public private(set) var contributors: [Contributor]
    public private(set) var contributorHandlePrefix: String?
}

extension ContributorsConfiguration: SubConfiguration {
    public static let blank: ContributorsConfiguration = .init(
        contributors: [],
        contributorHandlePrefix: nil
    )

    public static let `default`: ContributorsConfiguration = .init(
        contributors: [],
        contributorHandlePrefix: ""
    )
}

extension ContributorsConfiguration: Mergeable {
    public func merge(into other: inout ContributorsConfiguration) {
        if !contributors.isEmpty {
            other.contributors = contributors
        }

        if let contributorHandlePrefix = contributorHandlePrefix {
            other.contributorHandlePrefix = contributorHandlePrefix
        }
    }
}
