//
//  ResolutionCommandsConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 2/3/19.
//

public struct ResolutionCommandsConfiguration {
    public private(set) var buildNumber: String?
    public private(set) var versions: String?
}

/// :nodoc:
extension ResolutionCommandsConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case buildNumber = "build_number"
        case versions
    }
}

/// :nodoc:
extension ResolutionCommandsConfiguration: SubConfiguration {
    public static let blank: ResolutionCommandsConfiguration = .init(
        buildNumber: nil,
        versions: nil
    )

    public static var `default`: ResolutionCommandsConfiguration { return .blank }
}

/// :nodoc:
extension ResolutionCommandsConfiguration: Mergeable {
    public func merge(into other: inout ResolutionCommandsConfiguration) {
        if let buildNumber = buildNumber, !buildNumber.isEmpty {
            other.buildNumber = buildNumber
        }

        if let versions = versions, !versions.isEmpty {
            other.versions = versions
        }
    }
}

/// :nodoc:
extension ResolutionCommandsConfiguration {
    static let example: ResolutionCommandsConfiguration = .init(
        buildNumber: "/usr/bin/env bash -c 'git -C $PROJECT_DIR rev-list origin/releases/$NEW_VERSION --count'",
        versions: nil
    )
}
