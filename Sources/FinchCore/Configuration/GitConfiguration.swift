//
//  GitConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

/**
 * Sub-configuration for the project's Git setup.
 */
public struct GitConfiguration {
    /**
     * An optional branch prefix for your project to precede versions
     * when comparing.
     * >  Defaults to ""
     *
     * #### Example
     * Running `finch compare --versions 6.10.0 6.11.0` with a branch
     * prefix of `origin/releases/` will result in the comparison
     * of `origin/releases/6.10.0...origin/releases/6.20.0`.
     */
    public private(set) var branchPrefix: String

    /**
     * If `which git` will not properly resolve the git executable you
     * wish to run, you can include a custom path to the correct executable.
     */
    public private(set) var executablePath: String?

    /**
     * The base url for your project's repository. Used as a prefix for
     * your commit and PR hyperlinks.
     */
    public private(set) var repoBaseUrl: String
}

/// :nodoc:
extension GitConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case branchPrefix = "branch_prefix"
        case executablePath = "executable_path"
        case repoBaseUrl = "repo_base_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.branchPrefix = container.decode(forKey: .branchPrefix, default: "")
        self.executablePath = container.optionalDecode(forKey: .executablePath)
        self.repoBaseUrl = container.decode(forKey: .repoBaseUrl, default: "")
    }
}

/// :nodoc:
extension GitConfiguration: SubConfiguration {
    public static let blank: GitConfiguration = .init(
        branchPrefix: "",
        executablePath: nil,
        repoBaseUrl: ""
    )

    public static var `default`: GitConfiguration { return .blank }
}

/// :nodoc:
extension GitConfiguration: Mergeable {
    public func merge(into other: inout GitConfiguration) {
        if !branchPrefix.isEmpty {
            other.branchPrefix = branchPrefix
        }

        if let executablePath = executablePath {
            other.executablePath = executablePath
        }

        if !repoBaseUrl.isEmpty {
            other.repoBaseUrl = repoBaseUrl
        }
    }
}
