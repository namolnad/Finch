//
//  GitConfiguration.swift
//  FinchCore
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

public struct GitConfiguration {
    public private(set) var branchPrefix: String
    public private(set) var executablePath: String?
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
