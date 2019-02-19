//
//  ResolutionCommandsConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 2/3/19.
//

/**
 * Sub-configuration for shell commands used to resolve information
 * only available at run-time.
 */
public struct ResolutionCommandsConfiguration {
    /**
     * Optional command string to resolve a project's build
     * number at run-time.
     */
    public private(set) var buildNumber: String?

    /**
     * Optional command string to resolve the two versions you want
     * Finch to compare. Expects a single string with
     * two valid, space-separated versions.
     */
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
