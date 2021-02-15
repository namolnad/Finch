//
//  Configuration.swift
//  FinchCore
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

/// :nodoc:
public protocol Mergeable {
    func merge(into other: inout Self)
}

/// :nodoc:
public protocol SubConfiguration {
    static var blank: Self { get }
    static var `default`: Self { get }
}

/**
 * A structure describing a project's configuration. Comprised of
 * multiple sub-configurations.
 */
public struct Configuration {
    /**
     * Sub-configuration for the project's contributors.
     */
    public private(set) var contributorsConfig: ContributorsConfiguration

    /**
     * Sub-configuration for the formatting of the overall output as well
     * as the input for tag delimiters.
     */
    public private(set) var formatConfig: FormatConfiguration

    /**
     * Sub-configuration for the project's Git setup.
     */
    public private(set) var gitConfig: GitConfiguration

    /// :nodoc:
    public private(set) var projectDir: String = ""

    /**
     * Sub-configuration for shell commands used to resolve information
     * only available at run-time.
     */
    public private(set) var resolutionCommandsConfig: ResolutionCommandsConfiguration
}

/// :nodoc:
extension Configuration: Codable {
    enum CodingKeys: String, CodingKey {
        case contributors
        case format
        case git
        case resolutionCommands = "resolution_commands"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.contributorsConfig = container.decode(forKey: .contributors, default: .blank)
        self.formatConfig = container.decode(forKey: .format, default: .default)
        self.gitConfig = container.decode(forKey: .git, default: .default)
        self.resolutionCommandsConfig = container.decode(forKey: .resolutionCommands, default: .blank)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(contributorsConfig, forKey: .contributors)
        try container.encode(formatConfig, forKey: .format)
        try container.encode(gitConfig, forKey: .git)
        try container.encode(resolutionCommandsConfig, forKey: .resolutionCommands)
    }
}

/// :nodoc:
extension Configuration: Mergeable {
    public func merge(into other: inout Configuration) {
        contributorsConfig.merge(into: &other.contributorsConfig)
        formatConfig.merge(into: &other.formatConfig)
        gitConfig.merge(into: &other.gitConfig)
        resolutionCommandsConfig.merge(into: &other.resolutionCommandsConfig)
    }
}

/// :nodoc:
extension Configuration {
    public static func `default`(projectDir: String) -> Configuration {
        .init(
            contributorsConfig: .default,
            formatConfig: .default,
            gitConfig: .default,
            projectDir: projectDir,
            resolutionCommandsConfig: .default
        )
    }

    public static func example(projectDir: String) -> Configuration {
        var example: Configuration = .default(projectDir: projectDir)

        ContributorsConfiguration
            .example
            .merge(into: &example.contributorsConfig)

        ResolutionCommandsConfiguration
            .example
            .merge(into: &example.resolutionCommandsConfig)

        return example
    }
}
