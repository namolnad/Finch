//
//  ContributorsConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

public struct ContributorsConfiguration {
    public private(set) var contributors: [Contributor]
    public private(set) var contributorHandlePrefix: String?
}

extension ContributorsConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case contributors = "contributor_list"
        case contributorHandlePrefix = "contributor_handle_prefix"
    }
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

extension ContributorsConfiguration {
    static let example: ContributorsConfiguration = .init(
        contributors: [.example],
        contributorHandlePrefix: "@"
    )
}
