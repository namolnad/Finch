//
//  Configuration.swift
//  FinchCore
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

public protocol Mergeable {
    func merge(into other: inout Self)
}

public protocol SubConfiguration {
    static var blank: Self { get }
    static var `default`: Self { get }
}

public struct Configuration {
    public private(set) var contributorsConfig: ContributorsConfiguration
    public private(set) var formatConfig: FormatConfiguration
    public private(set) var gitConfig: GitConfiguration
    public private(set) var projectDir: String = ""
    public private(set) var resolutionCommandsConfig: ResolutionCommandsConfiguration
}

extension Configuration: Decodable {
    enum CodingKeys: String, CodingKey {
        case contributors
        case format
        case git
        case resolutionCommands
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.contributorsConfig = container.decode(forKey: .contributors, default: .blank)
        self.formatConfig = container.decode(forKey: .format, default: .default)
        self.gitConfig = container.decode(forKey: .git, default: .default)
        self.resolutionCommandsConfig = container.decode(forKey: .resolutionCommands, default: .blank)
    }
}

extension Configuration: Mergeable {
    public func merge(into other: inout Configuration) {
        if !projectDir.isEmpty {
            other.projectDir = projectDir
        }
        contributorsConfig.merge(into: &other.contributorsConfig)
        formatConfig.merge(into: &other.formatConfig)
        gitConfig.merge(into: &other.gitConfig)
        resolutionCommandsConfig.merge(into: &other.resolutionCommandsConfig)
    }
}

extension Configuration {
    public static func `default`(projectDir: String) -> Configuration {
        return .init(
            contributorsConfig: .default,
            formatConfig: .default,
            gitConfig: .default,
            projectDir: projectDir,
            resolutionCommandsConfig: .default
        )
    }
}

extension Configuration {
    public var contributors: [Contributor] {
        return contributorsConfig.contributors
    }

    public var contributorHandlePrefix: String {
        return contributorsConfig.contributorHandlePrefix ?? ""
    }

    public var gitExecutablePath: String? {
        return gitConfig.executablePath
    }

    public var gitBranchPrefix: String {
        return gitConfig.branchPrefix
    }
}
