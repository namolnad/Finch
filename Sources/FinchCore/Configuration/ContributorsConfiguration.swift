//
//  ContributorsConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

/**
 * Sub-configuration for the project's contributors.
 */
public struct ContributorsConfiguration {
    /**
     * List of the project's contributors.
     */
    public private(set) var contributors: [Contributor]

    /**
     * A custom prefix to precede all contributors' handles in the
     * final output. `@`, for example.
     */
    public private(set) var contributorHandlePrefix: String
}

/// :nodoc:
extension ContributorsConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case contributors = "contributor_list"
        case contributorHandlePrefix = "contributor_handle_prefix"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.contributorHandlePrefix = container.decode(forKey: .contributorHandlePrefix, default: "")
        self.contributors = container.decode(forKey: .contributors, default: [])
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if !contributorHandlePrefix.isEmpty {
            try container.encode(contributorHandlePrefix, forKey: .contributorHandlePrefix)
        }

        try container.encode(contributors, forKey: .contributors)
    }
}

/// :nodoc:
extension ContributorsConfiguration: SubConfiguration {
    public static let blank: ContributorsConfiguration = .init(
        contributors: [],
        contributorHandlePrefix: ""
    )

    public static var `default`: ContributorsConfiguration {
        .blank
    }
}

/// :nodoc:
extension ContributorsConfiguration: Mergeable {
    public func merge(into other: inout ContributorsConfiguration) {
        if !contributors.isEmpty {
            other.contributors = contributors
        }

        if !contributorHandlePrefix.isEmpty {
            other.contributorHandlePrefix = contributorHandlePrefix
        }
    }
}

/// :nodoc:
extension ContributorsConfiguration {
    static let example: ContributorsConfiguration = .init(
        contributors: [
            .example1,
            .example2
        ],
        contributorHandlePrefix: "@"
    )
}
